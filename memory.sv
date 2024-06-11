// Memory module for video data

module memory (
  input clock,
  input reset,
  
  // Write data in txt memory
  input [7:0]  write_data,
  input [12:0] write_address,
  input        write_enable,
  
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
localparam IMAGE_MEM_LENGTH = H_IMAGE*V_IMAGE-1;
localparam IMAGE_MEM_DEPTH  = $clog2(IMAGE_MEM_LENGTH);

// Registers
logic [2:0] pixel;
logic [2:0] mem [0:IMAGE_MEM_LENGTH];
logic [IMAGE_MEM_DEPTH-1:0] pixel_counter;

// Conditions
logic count_pixels;
logic reset_pixel_counter;
assign count_pixels = (pixel_x < H_IMAGE) & (pixel_y < V_IMAGE) & video_on;
assign reset_pixel_counter = (pixel_counter == IMAGE_MEM_LENGTH);

// Initiate memory
initial begin
  $display("Loading ROM");
  $readmemb ("image_mem/MemoryFile.txt", mem);
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
  
always @(posedge clock) begin
  if (count_pixels) pixel <= mem[pixel_counter];
  else pixel <= 3'b000;
end
  
assign color_r = pixel[2];
assign color_g = pixel[1];
assign color_b = pixel[0];
  
endmodule