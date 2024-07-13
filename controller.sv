// This module provides control over UART data reception and 
// interaction with the text memory. UART reception contains 
// three bytes of data. The first two bytes of data are addressable
// in the text memory. The last byte is a character. Data is put
// into memory while all three bytes are received. 

module controller (
  input clock,
  input reset,
  
  // UART connetcions
  input [7:0] uart_data,
  input       uart_data_ready,
  
  // Memory output 
  output [7:0]  mem_data,
  output [12:0] mem_address,
  output        mem_write
);

// When some packets axidently consist of two bytes, the next 
// packet with three bytes will be received incorrectly. To avoid 
// failed reception, an abort counter was added. It aborts the 
// UART reception if not three bytes were received while it counts.

// Number of counts, as well as counter depth depends on the clock
// frequency and URAT baud rate and can be set as follow:
//      (Frequency of clock)/(baudrate of UART * number of bits)
// For this module: 40 MHz Clock, 9600 baud UART
// 40000000/9600 * 10 = 41666 -> ceiling this value in the binary 
// form -> 65536 counts. This results in 15 bit depth 
localparam ABORT_COUNT_DEPTH = $clog2(40_000_000/9600*10);

// Registers
logic [1:0]                    current_state, next_state;
logic [7:0]                    address_1, address_2;
logic [7:0]                    char;
logic [1:0]                    byte_counter;
logic [ABORT_COUNT_DEPTH-1:0]  abort_counter;
logic                          uart_data_ready_q, uart_data_ready_q2;
logic                          uart_data_received;

// Input signals processing
always @(posedge clock) begin
  uart_data_ready_q  <= uart_data_ready;
  uart_data_ready_q2 <= uart_data_ready_q;
end
assign uart_data_received = uart_data_ready_q & ~uart_data_ready_q2;

// States of the state machine
parameter [1:0] IDLE      = 2'b00,
                RECEIVING = 2'b01,
                WRITE_MEM = 2'b10;

// Conditions
logic all_bytes_received;
logic receive_byte;
logic abort_uart_reception;
assign all_bytes_received   = byte_counter == 2'd3;
assign receive_byte         = (next_state == RECEIVING) & uart_data_received;
assign abort_uart_reception = &abort_counter;

// Controller state machine
always @(*) begin
  case(current_state)
    IDLE: begin
      if (uart_data_received) next_state = RECEIVING;
      else next_state = IDLE;
    end
    
    RECEIVING: begin
      if (all_bytes_received) next_state = WRITE_MEM;
      else if (abort_uart_reception) next_state = IDLE;
      else next_state = RECEIVING;
    end
    
    WRITE_MEM: next_state = IDLE; 
    
    default: next_state = IDLE;
  endcase
end

// Sequential part of the state machine
always @(posedge clock) begin
  if (reset) current_state = IDLE;
  else current_state = next_state;
end


// Receiving bytes
always @(posedge clock) begin
  if (reset | next_state == IDLE) begin
    byte_counter  <= 0;
    abort_counter <= 0;
    char          <= 0;
    address_1     <= 0;
    address_2     <= 0;
  end else begin
    abort_counter <= abort_counter + 1'b1;
  
    if (receive_byte) begin
      char          <= uart_data;
      address_1     <= char;
      address_2     <= address_1;
      byte_counter  <= byte_counter + 1'b1;
      abort_counter <= 0;
    end 
  end
end

// Combining output signals for text memory
assign mem_address = {address_1[4:0], address_2};
assign mem_data    = char;
assign mem_write   = (next_state == WRITE_MEM);

endmodule