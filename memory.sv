// Memory module for video data

module memory (
  input clock,
  input reset,
  input pixel_sync,
  
  // Write data in txt memory
  input [7:0]  write_data,
  input [12:0] write_address,
  input        write_enable,
  
  // Pixel sync
  input [10:0] x_pixel,
  input [10:0] y_pixel,
  
  // Output pixels
  output color_r,
  output color_g,
  output color_b
);

  assign color_r = x_pixel[7];
  assign color_g = x_pixel[7];
  assign color_b = x_pixel[7];

endmodule