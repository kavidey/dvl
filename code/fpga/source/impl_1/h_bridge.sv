/*
 * Author:    Kavi Dey, kdey@hmc.edu
 * Created:   3/20/24
 */

module h_bridge (
    input logic clk,
    rst,
    input logic [1:0] state,
    output logic hlh,
    hll,
    hrh,
    hrl
);

  // Divide 48 MHz by 2^6 to get 0.75 MHz
  logic [5:0] counter;
  always @(posedge clk) counter <= counter + 1;
  assign clkdiv = counter[5];

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
  assign hlh = clkdiv;
  assign hll = ~clkdiv;
  assign hrh = ~clkdiv;
  assign hrl = clkdiv;
endmodule
