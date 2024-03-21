/*
 * Author:    Kavi Dey, kdey@hmc.edu
 * Created:   3/20/24
 */

module h_bridge (
    input logic clk,
    rst,
    input dvl_pkg::h_bridge_state_t state,

    output logic hlh,
    hll,
    hrh,
    hrl
);

  // Divide 48 MHz by 2^6 to get 0.75 MHz
  logic [5:0] din;
  logic [5:0] clkdiv;
  dff dff_inst0 (
      .clk(clk),
      .rst(rst),
      .D  (din[0]),
      .Q  (clkdiv[0])
  );
  genvar i;
  generate
    for (i = 1; i < 6; i = i + 1) begin : dff_gen_label
      dff dff_inst (
          .clk(clkdiv[i-1]),
          .rst(rst),
          .D  (din[i]),
          .Q  (clkdiv[i])
      );
    end
  endgenerate
  ;
  //   always_comb begin : output_logic
  //     case (state)
  //       dvl_pkg::HIGHZ: begin
  //         hlh = 0;
  //         hll = 0;
  //         hrh = 0;
  //         hrl = 0;
  //       end
  //       dvl_pkg::DAMP: begin
  //         hlh = 0;
  //         hll = 1;
  //         hrh = 0;
  //         hrl = 1;
  //       end
  //       dvl_pkg::OSCL: begin
  //         hlh = clk;
  //         hll = ~clk;
  //         hrh = ~clk;
  //         hrl = clk;
  //       end
  //       default: begin
  //         hlh = 0;
  //         hll = 0;
  //         hrh = 0;
  //         hrl = 0;
  //       end
  //     endcase
  //   end
  assign hlh = clkdiv[5];
  assign hll = ~clkdiv[5];
  assign hrh = ~clkdiv[5];
  assign hrl = clkdiv[5];
endmodule
