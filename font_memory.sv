
// Font memory module to display text

module font_memory (
  input clock,
  input reset,
  
  // Pixel sync
  input [10:0] pixel_x,
  input [10:0] pixel_y,
  input [6:0]  symbol_address,
  input        video_on,
  
  // Output pixels
  output [7:0] symbol_line
);

// Image parameters
localparam SYMB_HEIGHT     = 8;
localparam SYMB_WIDTH      = 8;
localparam IMAGE_MEM_DEPTH = 127;

// Registers
logic [7:0] font_mem [0:IMAGE_MEM_DEPTH*SYMB_HEIGHT];
logic [7:0] line;

// Initiate memory
initial begin
  $display("Loading ROM");
  $readmemb ("C:/Users/user/Documents/FPGA/Altera projects/vga-controler-fpga/memory_files/FontMemoryFile.txt", font_mem);
  $display("The ROM is loaded");
end

always @(posedge clock) begin
  line <= font_mem[{symbol_address,pixel_y[2:0]}];
end

assign symbol_line = video_on ? line : 8'b0000_0000;

endmodule