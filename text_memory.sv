// Memory module to display text. It consists of a text
// memory module and font memory. Font memory is read-only
// and configured during the firmware of the FPGA. The font
// is an 8x8-bit font with 128 symbols. Symbol addressing 
// matches the 7-bit ASC II code. Text memory is read-and-write
// memory. Initial values may be configured from an external file
// or downloaded during the operation. Screen resolution and font
// size define the text memory size, simply how many integer
// numbers of symbols fit in one line or one column.

module text_memory(
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
localparam FONT_H                = 8;
localparam FONT_W                = 8;
localparam FONT_MEM_SIZE         = 127*FONT_H;
localparam H_DISPLAY             = 800;
localparam V_DISPLAY             = 600;
localparam COLUMN_COUNTER_LENGTH = H_DISPLAY/FONT_W;
localparam COLUMN_COUNTER_DEPTH  = $clog2(COLUMN_COUNTER_LENGTH);
localparam LINE_COUNTER_LENGTH   = V_DISPLAY/FONT_H;
localparam TEXT_MEM_LENGTH       = COLUMN_COUNTER_LENGTH*LINE_COUNTER_LENGTH;
localparam COUNTER_DEPTH         = $clog2(TEXT_MEM_LENGTH);

// Registers
logic [7:0]                      text_mem[TEXT_MEM_LENGTH-1:0];
logic [7:0]                      font_mem[FONT_MEM_SIZE-1:0];
logic [7:0]                      line;
logic [COLUMN_COUNTER_DEPTH-1:0] column_counter;
logic [COUNTER_DEPTH-1:0]        line_counter;
logic [COUNTER_DEPTH-1:0]        symbol_counter;
logic [6:0]                      symbol;
logic [7:0]                      symbol_line;
logic [6:0]                      symbol_address;
logic [2:0]                      pixel_x_q;
logic [2:0]                      pixel_x_q2;

// Conditions
logic reset_column_counter;
assign reset_column_counter = (column_counter == COLUMN_COUNTER_LENGTH);
logic reset_line_counter;
assign reset_line_counter   = (line_counter == TEXT_MEM_LENGTH);
logic inc_column_counter;
assign inc_column_counter   = (pixel_x[2:0] == 3'b111);
logic inc_line_counter;
assign inc_line_counter     = (pixel_y[2:0] == 3'b111) & inc_column_counter & (column_counter == COLUMN_COUNTER_LENGTH - 1'b1);


// Initiation of the text memory with the initial phrase
initial begin
  $display("Loading ROM");
  $readmemb ("C:/Users/user/Documents/FPGA/Altera projects/vga-controler-fpga/memory_files/TextMemory.txt", text_mem);
  $display("The ROM is loaded");
end

// Initiate of the font memory
initial begin
  $display("Loading ROM");
  $readmemb ("C:/Users/user/Documents/FPGA/Altera projects/vga-controler-fpga/memory_files/FontMemoryFile.txt", font_mem);
  $display("The ROM is loaded");
end
  
// Counters to adress the text memory
always @(posedge clock) begin
  if (reset | reset_column_counter) column_counter <= '0;
  else begin
    column_counter <= column_counter;
    if (inc_column_counter) column_counter <= column_counter + 1'b1;
  end
  
  if (reset | reset_line_counter) line_counter <= '0;
  else begin
    line_counter <= line_counter;
    if (inc_line_counter) line_counter <= line_counter + 100;
  end
end

assign symbol_counter = column_counter + line_counter;

// Operations with the text memory
always @(posedge clock) begin
  if (write_enable) text_mem[write_address] <= write_data;
  symbol <= text_mem[symbol_counter];
end

assign symbol_address = video_on ? symbol : 8'b0000_0000;

// Operations with font memory
always @(posedge clock) begin
  line <= font_mem[{symbol_address,pixel_y[2:0]}];
end

assign symbol_line = video_on ? line : 8'b0000_0000;

// Delay pixel count because memory read takes two clock cycles
always @(posedge clock) begin
  pixel_x_q  <= pixel_x[2:0];
  pixel_x_q2 <= pixel_x_q;
end

// Display pixels on a screen
assign color_r = symbol_line[3'b111 - pixel_x_q2];
assign color_g = color_r;
assign color_b = color_g;

endmodule