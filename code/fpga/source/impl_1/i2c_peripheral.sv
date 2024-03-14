module i2c_peripheral #(
    parameter ADDRESS = 7'h42
) (
    input logic [7:0] tx,

    inout logic scl,
    inout logic sda,

    output logic [7:0] rx,
    output logic rw  // 0 is read, 1 is write
);
  enum int {
    IDLE,
    DEVICE_ADDRESS,
    ACK,
    RX,
    ACK2,
    TX,
    CACK  // controller acknowledge
  } state;

  logic [3:0] counter;
  logic [7:0] rx_reg;
  logic start, stop;

  // Output Logic
  logic sda_out, output_enable;
  assign sda = (output_enable == 1) ? sda_out : 1'bz;
  assign scl = 1'bz;


  always_ff @(negedge sda) begin : sda_fall
    if (state == IDLE && scl == 1) begin
      start <= 1;
    end else if (state == IDLE) start <= 0;
  end

  always_ff @(posedge sda) begin : sda_rise
    if (start == 1 && scl == 1) begin
      stop <= 1;
    end else stop <= 0;
  end

  always_ff @(posedge scl) begin : scl_rise
    if (start == 1 && state == IDLE) begin
      state   <= DEVICE_ADDRESS;
      rx_reg  <= {sda, rx_reg[7:1]};
      counter <= counter + 1;
      if (counter == 7) begin
        state <= ACK;
      end
    end else if (stop == 1) begin
      state   <= IDLE;
      counter <= 0;
    end else begin
      case (state)
        IDLE: begin  // I think this is unreachable?
          counter <= 0;
        end
        // state can't be modified in multiple always_ff blocks, the "first"
        // we need to enter the first state in a special way, this is done
        // above in the if statement
        DEVICE_ADDRESS: begin
          rx_reg  <= {sda, rx_reg[7:1]};
          counter <= counter + 1;
          if (counter == 7) begin
            state <= ACK;
          end
        end
        ACK: begin
          if (ADDRESS == rx_reg[6:0]) begin
            counter <= 0;
            rw <= rx_reg[7];
            if (rx_reg[7] == 0) state <= RX;
            else state <= TX;
          end else begin
            state <= IDLE;
          end
        end
        RX: begin
          rx_reg  <= {sda, rx_reg[7:1]};
          counter <= counter + 1;
          if (counter == 7) begin
            state <= ACK2;
          end
        end
        ACK2: begin
          state <= RX;
          counter <= 0;
          rx <= rx_reg;
        end
        TX: begin
          counter <= counter + 1;
          if (counter == 7) begin
            state <= CACK;
          end
        end
        CACK: begin
          counter <= 0;
          if (sda == 0) begin  // NACK
            state <= IDLE;
          end else begin  // ACK
            state <= TX;
          end
        end
        default: begin
        end
      endcase
    end
  end

  // this is kind of like the output logic of the state machine
  always_ff @(negedge scl) begin : scl_fall
    case (state)
      IDLE: begin
        output_enable <= 0;
        sda_out <= 0;
      end
      DEVICE_ADDRESS: begin
        output_enable <= 0;
      end
      ACK: begin
        output_enable <= 1;
        sda_out <= 0;
      end
      RX: begin
        output_enable <= 0;
      end
      ACK2: begin
        output_enable <= 1;
        sda_out <= 0;
      end
      TX: begin
        output_enable <= 1;
        sda_out <= tx[counter];
      end
      CACK: begin
        output_enable <= 0;
      end
      default: begin
        output_enable <= 0;
        sda_out <= 0;
      end
    endcase
  end
endmodule
