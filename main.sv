// This module combines all othe modues together

module main #(
  parameter TESTBENCH = 0
)(
  input clock,        // Clock signal from external crystal
  input reset_button, // Reset button, active low
  
  // UART input
  input uart_rx,      // Input for UART receiver
  
  // VGA outputs
  output v_sync, h_sync,           // Syncroniastion signals
  output color_r_o, color_g_o, color_b_o // 1-bit color signals
);

// Registers
logic reset_button_q, reset_button_q2;
logic uart_rx_q, uart_rx_q2;
logic reset_b_q;
logic pll_locked_q;
logic clk_40;
logic reset;

// Connections between the modules
logic [7:0]  uart_data;
logic        reset_b;
logic        reset_b_pulse;
logic        pll_locked;
logic        pll_locked_pulse;
logic [12:0] mem_address;
logic [7:0]  mem_data;
logic [10:0] pixel_x;
logic [10:0] pixel_y;
logic [18:0] pixel_counter;

// Input signal procesing
always @(posedge clk_40) begin
  reset_button_q  <= ~reset_button;
  reset_button_q2 <= reset_button_q;
  uart_rx_q       <= uart_rx;
  uart_rx_q2      <= uart_rx_q;
end

// Pll is used in design only. When it's a 
// testbench, the clock should be driven manually.
generate
  if (TESTBENCH == 0)
    pll pll_m (
      .inclk0 (clock),
      .c0 (clk_40),
	    .locked (pll_locked)
    );
  else 
  assign pll_locked = 0;
endgenerate

// Creating the reset signal
always @(posedge clk_40) begin
  reset_b_q    <= reset_b;
  pll_locked_q <= pll_locked;
end

assign pll_locked_pulse = pll_locked & ~pll_locked_q;
assign reset_b_pulse    = reset_b & ~reset_b_q;
assign reset            = reset_b_pulse | pll_locked_pulse;

button reset_buton_m (
  .clock (clk_40),
  .reset (reset),
  .button_i (reset_button_q2),
  .button_o (reset_b)
);

uart_receiver uart_receiver_m(
  .clock (clk_40),
  .reset (reset),
  .rx (uart_rx_q2),
  .data (uart_data),
  .data_ready (uart_data_ready)
);

controller controller_m (
  .clock (clk_40),
  .reset (reset),
  
  // Memory output
  .data (mem_data),
  .address (mem_address),
  .write (write_enable)
);

memory memory_m (
  .clock (clk_40),
  .reset (reset),
  
  // Write data in txt memory
  .write_data (mem_data),
  .write_address (mem_address),
  .write_enable (write_enable),
  
  // Pixel sync
  .pixel_x(pixel_x),
  .pixel_y(pixel_y),
  .video_on(video_on),
  
  // Output pixels
  .color_r (color_r),
  .color_g (color_g),
  .color_b (color_b)
);

vga_sync_gen vga_sync_gen_m(
  .clock (clk_40),
  .reset (reset),
  
  // VGA outputs
  .v_sync   (v_sync),
  .h_sync   (h_sync),
  .video_on (video_on),
  
  // Memory outputs
  .pixel_x (pixel_x),
  .pixel_y (pixel_y)
);

// Output video signal in active time of the display
assign color_r_o = video_on ? color_r : 0;
assign color_g_o = video_on ? color_g : 0; 
assign color_b_o = video_on ? color_b : 0;

endmodule