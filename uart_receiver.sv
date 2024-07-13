// This file contains a UART receiver. This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit. When receive is complete data_ready will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of clock)/(Frequency of UART)
// Example: 1 MHz clock, 9600 baud UART
// (1000000)/(9600) = 104

module uart_receiver 
#(
  parameter CLK_PER_BIT   = 104
)(
  input clock,
  input reset,
  input rx,
  output reg [7:0] data,
  output data_ready
);

// Parameters
localparam COUNTER_WIDTH = $clog2(CLK_PER_BIT);

//// Registers
reg [2:0]               current_state;
reg [2:0]               next_state;
reg [COUNTER_WIDTH-1:0] counter;      //	This counter will identify the center of the recieved bit
reg [3:0]               bit_counter;	// Count number of the recieved bits

// States of the state machine
parameter [2:0] IDLE      = 3'b000,
                START_BIT = 3'b001,
                DATA      = 3'b010,
                STOP_BIT  = 3'b011,
                CLEAR     = 3'b100;

////Conditions
wire start           = (rx == 0);
wire receiving_start = (counter == (CLK_PER_BIT/2 - 1));
wire next_bit        = (counter == (CLK_PER_BIT - 1));
wire receiving_stop  = (bit_counter == 8);
wire stop_bit        = (rx == 1) & next_bit;
wire reset_counter   = (receiving_start & current_state == START_BIT) | 
                       (next_bit        & next_state    == DATA     ) |
                       (stop_bit        & current_state == STOP_BIT );

// State machine
always @(*) begin
  case(current_state)
    IDLE: begin
      if (start) next_state = START_BIT;
      else next_state = IDLE;
    end
    
    START_BIT: begin
      if (receiving_start) begin
        if (start) next_state = DATA;
        else next_state = IDLE;
      end else next_state = START_BIT;
    end
    
    DATA: begin
      if (receiving_stop) next_state = STOP_BIT;
      else next_state = DATA;
    end
    
    STOP_BIT: begin
      if (stop_bit) next_state = CLEAR;
      else next_state = STOP_BIT;
    end
	 
    CLEAR: next_state = IDLE;
		
    default: next_state = IDLE;
  endcase
end

// Sequential part of the state machine
always @(posedge clock) begin
  if (reset) current_state <= IDLE;
  else current_state <= next_state;
end

// Main logic
always @(posedge clock) begin
  if(reset | next_state == IDLE) begin 
    data        <= 0;
    counter     <= 0;
    bit_counter <= 0;
  end else begin
    // Counter
    counter <= counter + 1'b1;
    if (reset_counter) counter <= 0;
    
    // Data reception
    if (next_state == DATA & next_bit) begin
      data        <= {rx,data[7:1]};
      bit_counter <= bit_counter + 1'b1;
    end
    
  end
end

// Pulse to write data to fifo
assign data_ready = (next_state == CLEAR);
		
endmodule