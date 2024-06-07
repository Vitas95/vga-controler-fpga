// UART receiver

module uart_receiver(
  input clock,
  input reset,
  input rx,
  output reg [7:0] data,
  output reg       data_ready
);

always @(posedge clock) begin
  data       <= 0;
  data_ready <= 0;
end

endmodule