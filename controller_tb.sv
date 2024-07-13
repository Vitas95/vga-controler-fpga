// Testbench for the controller module.
// The purpose of the current version of the testbench 
// is to display signals that are writing data from the 
// UART to the text memory. There is no self-check of 
// the timing. It must be rewritten to provide automation 
// without relying on manually inspecting the output.

`timescale 1ns/100ps

module controller_tb ();

// Simulation parameters
parameter CLK_PERIOD = 25.0;

logic       clock;
logic       reset;
logic [7:0] uart_data;
logic       uart_data_ready;
  
logic [7:0]  mem_data;
logic [12:0] mem_address;
logic        mem_write;

controller controller_dut (
  .clock(clock),
  .reset(reset),
  
  // UART connetcions
  .uart_data(uart_data),
  .uart_data_ready(uart_data_ready),
  
  // Memory output 
  .mem_data(mem_data),
  .mem_address(mem_address),
  .mem_write(mem_write)
);

// Clock signal
always #(CLK_PERIOD/2) clock = ~clock;

task init();
  clock           <= 1'b0;
  reset           <= 1'b0;
  uart_data       <= 8'b0000_0000;
  uart_data_ready <= 1'b0;
endtask

task reset_pulse();
  #(CLK_PERIOD);
  reset <= 1'b1;
  #(CLK_PERIOD);
  reset <= 1'b0;
endtask

task byte_received(
  input [7:0] tx_byte
);
  uart_data       <= tx_byte;
  uart_data_ready <= 1'b1;
  #(CLK_PERIOD*20);
  uart_data       <= 8'b0000_0000;
  uart_data_ready <= 1'b0;
endtask

// Main simulation cycle
initial begin
  init();
  reset_pulse();
  
  byte_received(8'b1010_1100);
  #(CLK_PERIOD*20);
  byte_received(8'b1010_1101);
  #(CLK_PERIOD*20);
  byte_received(8'b1010_1110);
end

endmodule