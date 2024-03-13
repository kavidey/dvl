module i2c_peripheral #(
    parameter ADDRESS = 7'b0101010
) (
    input logic clk,
    input logic [7:0] tx,
    input logic scl,

    inout logic sda,

    output logic adr,
    output logic [7:0] rx
);
  // State Variables
  enum int {
    IDLE,
    DEVICE_ADDRESS,
    REGISTER_ADDRESS,
    DATA
  } state, next_state;
  enum int {
    READ,
    WRITE
  } action, next_action;
  logic [3:0] counter, next_counter;

  // Output Logic
  logic output_enable;
  logic sda_out;
  assign sda = (output_enable == 1) ? sda_out : 1'bz;

  // Internal Logic
  logic [7:0] data;
endmodule
