// VGA synchronization module for 800x600 screen resolution. 
// The generator forms a signal for vertical and horizontal 
// synchronization. Also generates video control signal allow 
// to output video signal in right moment of time. Signals 
// pixel_x and pixel_y help to provide reads from memory 
// modules pixel by pixel.

module vga_sync_gen(
  input clock,
  input reset,
  
  // VGA outputs
  output v_sync,
  output h_sync,
  output video_on,
  
  // Memory outputs
  output [10:0] pixel_x, pixel_y
);

// Constants for VGA synchronisation 
localparam H_DISPLAY = 800;
localparam H_FRONT   = 40;
localparam H_SYNC    = 128;
localparam H_BACK    = 88;
localparam H_TOTAL       = H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1;
localparam H_BEFORE_SYNC = H_DISPLAY + H_FRONT - 1;
localparam H_AFTER_SYNC  = H_DISPLAY + H_FRONT + H_SYNC;

localparam V_DISPLAY = 600;
localparam V_FRONT   = 1;
localparam V_SYNC    = 4;
localparam V_BACK    = 23;
localparam V_TOTAL       = V_DISPLAY + V_FRONT + V_SYNC + V_BACK - 1;
localparam V_BEFORE_SYNC = V_DISPLAY + V_FRONT - 1;
localparam V_AFTER_SYNC  = V_DISPLAY + V_FRONT + V_SYNC;

// Registers
logic [10:0] h_counter, v_counter;

// Vertical and horysontal counters
always @(posedge clock) begin
  if (reset) begin
    h_counter <= '0;
    v_counter <= '0;
  end else begin
    if (h_counter == H_TOTAL) begin
      h_counter <= '0;
      if (v_counter == V_TOTAL) begin
        v_counter <= '0;
      end else begin
        v_counter <= v_counter + 1'b1;
      end
    end else begin
      h_counter <= h_counter + 1'b1;
    end
  end
end

//Synchronisation signals
assign h_sync = ~((h_counter <= H_BEFORE_SYNC) | (h_counter >= H_AFTER_SYNC));
assign v_sync = ~((v_counter <= V_BEFORE_SYNC) | (v_counter >= V_AFTER_SYNC));

// Region where video is displayed
assign video_on = (h_counter < H_DISPLAY) & (v_counter < V_DISPLAY);

// Counters to the memory
assign pixel_x = video_on ? h_counter : 11'b0;
assign pixel_y = video_on ? v_counter : 11'b0;

endmodule

