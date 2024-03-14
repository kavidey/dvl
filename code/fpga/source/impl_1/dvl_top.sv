/*
 * Author:    Kavi Dey, kdey@hmc.edu
 * Created:   3/14/24
 */

module dvl_top (
    input [9:0] adc,

    inout sda,
    inout scl,

    output txrx
);

  logic [7:0] tx, rx;
  logic rw;

  assign tx = 8'h21;

  i2c_peripheral #(7'h42) i2c_peripheral (
      .tx (tx),
      .scl(scl),
      .sda(sda),
      .rx (rx),
      .rw (rw)
  );
endmodule
