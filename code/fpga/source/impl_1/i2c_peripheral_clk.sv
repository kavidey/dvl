module i2c_peripheral_clk #(
    parameter ADDRESS = 7'h42
) (
    input logic rst,
    clk,
    input logic [7:0] tx,

    inout logic scl,
    inout logic sda,

    output logic [7:0] rx,
    output logic debug,
    output logic rw  // 0 is read, 1 is write
);
  enum logic [2:0] {
    IDLE,
    DEVICE_ADDRESS,
    ACK,
    RX,
    ACK2,
    TX,
    CACK  // controller acknowledge
  }
      state, next_state;

  enum logic {
    START,
    STOP
  }
      startstop, next_startstop;

  logic [3:0] counter, next_counter, counter_p1, counter_n1;
  assign counter_p1 = counter + 1;
  assign counter_n1 = counter - 1;

  logic [7:0] rx_reg, next_rx_reg;
  logic [7:0] next_rx;

  logic next_rw;
  logic sda_out, next_sda_out, output_enable, next_output_enable;
  assign sda   = (output_enable == 1) ? sda_out : 1'bz;
  assign scl   = 1'bz;

  assign debug = sda;

  logic sda_negedge, sda_posedge, scl_posedge, scl_negedge;
  logic sda_last, sda_curr, scl_last, scl_curr;

  assign sda_negedge = sda_last & ~sda_curr;
  assign sda_posedge = sda_curr & ~sda_last;

  assign scl_negedge = scl_last & ~scl_curr;
  assign scl_posedge = scl_curr & ~scl_last;

  always_ff @(posedge clk) begin : update_state_logic
    if (rst) begin
      sda_curr <= 0;
      sda_last <= 0;
      scl_curr <= 0;
      scl_last <= 0;
      state <= IDLE;
      rx_reg <= 0;
      rw <= 0;
    end else begin
      scl_curr <= scl;
      scl_last <= scl_curr;
      sda_curr <= sda;
      sda_last <= sda_curr;
      state <= next_state;
      rx_reg <= next_rx_reg;
      rx <= next_rx;
      counter <= next_counter;
      sda_out <= next_sda_out;
      output_enable <= next_output_enable;
      rw <= next_rw;
    end
  end

  always_comb begin : next_state_logic
    next_rx_reg = rx_reg;
    next_rx = rx;
    next_counter = counter;
    next_sda_out = sda_out;
    next_output_enable = output_enable;
    next_rw = rw;
    if (sda_posedge & scl & (~output_enable)) begin
      next_state = IDLE;
    end else begin
      case (state)
        IDLE: begin
          if (sda_negedge & scl) next_state = DEVICE_ADDRESS;
          else next_state = IDLE;
          next_rx_reg = 0;
          next_counter = 0;
          next_output_enable = 0;
        end
        DEVICE_ADDRESS: begin
          next_output_enable = 0;

          // If done receiving address, check if its correct
          if (counter == 8) begin
            next_counter = 0;
            if (rx_reg[7:1] == ADDRESS) begin
              next_state = ACK;
            end else begin
              next_state = IDLE;
            end

            // If not done receiving address, continue
          end else begin
            if (scl_posedge) begin
              next_rx_reg  = {rx_reg[6:0], sda};
              next_counter = counter_p1;
            end
            next_state = DEVICE_ADDRESS;
          end
        end
        ACK: begin
          if (scl_negedge) begin
            // On the first negative edge, write ACK
            if (counter == 0) begin
              next_output_enable = 1;
              next_sda_out = 0;
              next_counter = counter_p1;
              next_state = ACK;
              // On the second negative edge, release ACK and transition to next state
            end else begin
              if (rx_reg[0] == 0) begin
                next_output_enable = 0;
                next_counter = 0;
                next_state = RX;
                next_rw = 1;
              end else begin
                next_output_enable = 1;
                next_sda_out = tx[7];
                next_counter = 8;
                next_state = TX;
                next_rw = 0;
              end
            end
          end else begin
            next_state = ACK;
          end
        end
        RX: begin
          next_output_enable = 0;
          if (counter == 8) begin
            next_state = ACK2;
            next_rx = rx_reg;
          end else begin
            next_state = RX;
            if (scl_posedge) begin
              next_rx_reg  = {rx_reg[6:0], sda};
              next_counter = counter_p1;
            end
          end
        end
        ACK2: begin
          if (scl_negedge) begin
            next_counter = 0;
            next_output_enable = 1;
            next_sda_out = 0;
            next_state = ACK2;
          end else if (scl_posedge) begin
            next_state = RX;
          end else begin
            next_state = ACK2;
          end
        end
        TX: begin
          next_output_enable = 1;
          if (scl_negedge) begin
            next_sda_out = tx[counter_n1[2:0]];
            if (counter == 0) begin
              next_output_enable = 0;
              next_state = CACK;
            end else begin
              next_state = TX;
            end
          end else if (scl_posedge) begin
            next_counter = counter_n1;
            next_state   = TX;
          end
        end
        CACK: begin
          next_output_enable = 0;
          next_counter = 0;
          if (scl_posedge) begin
            if (sda == 1) begin
              next_state = IDLE;
            end else begin
              next_state   = TX;
              next_counter = 7;
            end
          end else begin
            next_state = CACK;
          end
        end
        default: begin
          next_state = IDLE;
        end
      endcase
    end
  end

endmodule
