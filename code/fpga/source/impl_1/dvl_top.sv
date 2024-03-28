/*
 * Author:    Kavi Dey, kdey@hmc.edu
 * Created:   3/14/24
 */

`include "dvl_params.sv"

module dvl_top (
    // input logic [9:0] adc,
    input logic rst,

    inout logic sda,
    inout logic scl,

    output logic txrx,
    output logic hlh,
    hll,
    hrh,
    hrl,
    output logic debug
);

  logic hsclk;  //, core_clk, clk;
  HSOSC #(
      .CLKHF_DIV(2'b00)
  ) hf_osc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF  (hsclk)
  );

  assign txrx = rst;

  logic reset_active_low;
  assign reset_active_low = ~rst;

  //   sysclk_pll clk_pll (
  //       .ref_clk_i(hsclk),
  //       .rst_n_i(rst),
  //       .outcore_o(clk),
  //       .outglobal_o(core_clk)
  //   );

  logic [7:0] tx, rx;
  logic rw;

  assign tx = 8'b00000000;

  i2c_peripheral_clk #(7'h42) i2c_peripheral_clk (
      .clk(clk),
      .rst(rst),
      .tx(tx),
      .scl(scl),
      .sda(sda),
      .rx(rx),
      .rw(rw),
      .debug(debug)
  );

  logic [1:0] hstate = `HB_OSCL;
  h_bridge h_bridge (
      hsclk,
      rst,
      hstate,
      hlh,
      hll,
      hrh,
      hrl
  );
endmodule
