// Button processing module. This module
// process the input signal from the button to avoid
// switch bouncing. 

module button(
  input clock,
  input reset,
  input button_i,
  output button_o
);

// Registers
reg [14:0] counter;
reg        rs_trigger;

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