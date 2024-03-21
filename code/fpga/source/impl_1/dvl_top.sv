/*
 * Author:    Kavi Dey, kdey@hmc.edu
 * Created:   3/14/24
 */

module dvl_top (
    input logic [9:0] adc,
    input rst,

    inout logic sda,
    inout logic scl,

    output logic txrx,
    output logic hlh,
    hll,
    hrh,
    hrl
);

  logic hsclk, core_clk, clk;
  HSOSC #(
      .CLKHF_DIV(2'b00)
  ) hf_osc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF  (hsclk)
  );

  sysclk_pll clk_pll (
      .ref_clk_i(hsclk),
      .rst_n_i(rst),
      .outcore_o(clk),
      .outglobal_o(core_clk)
  );

  logic reset_active_high;
  assign reset_active_high = ~rst;

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

  dvl_pkg::h_bridge_state_t hstate;
  assign hstate = dvl_pkg::OSCL;
  h_bridge h_bridge(hsclk, reset_active_high, hstate, hlh, hll, hrh, hrl);
endmodule
