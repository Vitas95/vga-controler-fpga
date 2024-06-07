// Testbenches

`timescale 1ns/100ps

module main_tb ();

// Simulation parameters
parameter CLK_PERIOD = 25.0;

logic clk_50;
logic v_sync;
logic h_sync;
logic color_r_o; 
logic color_g_o; 
logic color_b_o;

main #(
  .TESTBENCH(1)
) main_dut (
  .clock        (clk_50), // Clock signal from external crystal
  .reset_button (1'b1),   // Reset button, active low
  
  // UART input
  .uart_rx   (1'b1),      // Input for UART receiver
  
  // VGA outputs
  .v_sync    (v_sync),
  .h_sync    (h_sync),    // Syncroniastion signals
  .color_r_o (color_r_o), 
  .color_g_o (color_g_o), 
  .color_b_o (color_b_o) // 1-bit color signals
);

// Clock signal
always #(CLK_PERIOD/2) main_dut.clk_40 <= ~main_dut.clk_40;

// Initialisation
task init();
  main_dut.clk_40 <= 1'b0;
  main_dut.reset  <= 1'b0;
endtask

task reset_pulse();
  #(CLK_PERIOD/2);
  main_dut.reset <= 1'b1;
  #(CLK_PERIOD/2);
  main_dut.reset <= 1'b0;
endtask


initial begin
  init();
  reset_pulse();
end

endmodule