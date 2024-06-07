// Controller module

module controller (
  input clock,
  input reset,
  
  // Memory output
  output [7:0]  data,
  output [12:0] address,
  output        write
);

  assign data    = 0;
  assign address = 0;
  assign write   = 0;

endmodule