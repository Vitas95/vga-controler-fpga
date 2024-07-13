// Memory module to display the image.
// Contains the memory that fits the image. It is read-only
// and configured during the firmware of the FPGA. As the number
// of memory cells is limited, the image size is much smaller
// than the screen resolution. The image is displayed on 
// the top left side of the screen.

module image_memory (
  input clock,
  input reset,
  
  // Pixel sync
  input [10:0] pixel_x,
  input [10:0] pixel_y,
  input        video_on,
  
  // Output pixels
  output color_r,
  output color_g,
  output color_b
);

// Image parameters
localparam H_IMAGE          = 240;
localparam V_IMAGE          = 320;
localparam IMAGE_MEM_LENGTH = H_IMAGE*V_IMAGE;
localparam IMAGE_MEM_DEPTH  = $clog2(IMAGE_MEM_LENGTH);

// Registers
logic [2:0] pixel;
logic [2:0] mem [IMAGE_MEM_LENGTH-1:0];
logic [IMAGE_MEM_DEPTH-1:0] pixel_counter;

// Conditions
logic count_pixels;
logic reset_pixel_counter;
assign count_pixels = (pixel_x < H_IMAGE) & (pixel_y < V_IMAGE) & video_on;
assign reset_pixel_counter = (pixel_counter == IMAGE_MEM_LENGTH);

// Initiate memory
initial begin
  $display("Loading ROM");
  $readmemb ("memory_files/ImageMemoryFile.txt", mem);
  $display("The ROM is loaded");
end

// Pixel counter to adress the memory
always @(posedge clock) begin
  if (reset | reset_pixel_counter) pixel_counter <= '0;
  else begin
    pixel_counter <= pixel_counter;
    if (count_pixels) pixel_counter <= pixel_counter + 1'b1;
  end
end

// Read memory
always @(posedge clock) begin
  pixel <= mem[pixel_counter];
end
  
assign color_r = count_pixels ? pixel[2] : 1'b0;
assign color_g = count_pixels ? pixel[1] : 1'b0;
assign color_b = count_pixels ? pixel[0] : 1'b0;
  
endmodule