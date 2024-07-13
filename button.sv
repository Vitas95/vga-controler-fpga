// This module is for button processing connected
// to reset the FPGA manually. The module's input
// should be connected to the button through two 
// registers to avoid metastability. The output of
// the module is high when the button is pressed. 
// It stays high for some time after the button release. 
// The counter defines this period. 

module button(
  input clock,
  input reset,
  input button_i,
  output button_o
);

// To suppress contact bouncing, a counter register is 
// used to filter input noise from the button. It works
// like a digital capacitor, filtering the input signal.
// Suppose that after pressing the button, the transition 
// process in its circuit takes around 1 ms. In this case, 
// the size of this counter is defined as follows:  
//      0.001 * Frequency of clock
// For this module: 40 MHz Clock
//    0.001 * 40000000 = 40000 -> ceiling this value in the binary 
// form -> 65543 counts. This results in 15 bit depth 
localparam COUNTER_DEPTH = $clog2(unsigned'(0.001 * 40_000_000));

// Registers
reg [COUNTER_DEPTH-1:0] counter;
reg                     rs_trigger;

// Conditions
assign increment = button_i & ~&counter;
assign decrement = ~button_i & |counter;

always @(posedge clock) begin
  if (reset) begin
    counter <= '0;
  end else begin
  
    if (increment) counter <= counter + 15'b1;
    else if (decrement) counter <= counter - 15'b1;
  end
   
  if (&counter) rs_trigger <= 1'b1;
  else if (~|counter) rs_trigger <= 1'b0;

end

assign button_o = rs_trigger;

endmodule