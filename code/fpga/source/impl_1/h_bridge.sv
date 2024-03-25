/*
 * Author:    Kavi Dey, kdey@hmc.edu
 * Created:   3/20/24
 */

`include "dvl_params.sv"

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

  always_comb begin : output_logic
    case (state)
      `HB_HIGHZ: begin
        hlh = 0;
        hll = 0;
        hrh = 0;
        hrl = 0;
      end
      `HB_DAMP: begin
        hlh = 0;
        hll = 1;
        hrh = 0;
        hrl = 1;
      end
      `HB_OSCL: begin
        hlh = clkdiv;
        hll = ~clkdiv;
        hrh = ~clkdiv;
        hrl = clkdiv;
      end
      default: begin
        hlh = 0;
        hll = 0;
        hrh = 0;
        hrl = 0;
      end
    endcase
  end
endmodule
