// Testbench for VGA signals. 
// The purpose of the current version of the testbench 
// is to display signals coming to the VGA output. There 
// is no self-check of the timing. It must be rewritten 
// to provide automation without relying on manually 
// inspecting the output.


`timescale 1ns/100ps

module main_tb ();

// Simulation parameters
parameter CLK_PERIOD = 25.0;

logic v_sync;
logic h_sync;
logic color_r_o; 
logic color_g_o; 
logic color_b_o;

main #(
  .TESTBENCH(1),
  .MODE(0)
) main_dut (
  .clock        (0), // Clock signal from external crystal
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
  main_dut.clk_40     <= 1'b0;
  main_dut.reset      <= 1'b0;
  main_dut.pll_locked <= 1'b0;
endtask

task reset_pulse();
  #(CLK_PERIOD);
  main_dut.reset <= 1'b1;
  #(CLK_PERIOD);
  main_dut.reset <= 1'b0;
endtask

initial begin
  init();
  reset_pulse();
end

endmodule