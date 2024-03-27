module i2c_peripheral #(
    parameter ADDRESS = 7'h42
) (
    input logic [7:0] tx,
    input logic rst,

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
  } state;

  logic [2:0] counter, counter_p1, counter_n1;
  logic [7:0] rx_reg;
  logic start, stop;

  assign counter_p1 = counter + 1;
  assign counter_n1 = counter - 1;

  // Output Logic
  logic sda_out, output_enable;
  assign sda   = (output_enable == 1) ? sda_out : 1'bz;
  assign scl   = 1'bz;

  assign debug = rw;

  // Detect start/stop conditions
  always_ff @(negedge sda or posedge rst) begin : sda_fall
    if (rst) start <= 0;
    else begin
      if (state == IDLE && scl == 1 && rst == 0) start <= 1;
    end
  end

  always_ff @(posedge sda) begin : sda_rise
    if (start == 1 && scl == 1 && output_enable == 0) begin
      stop <= 1;
    end else stop <= 0;
  end

  // Handle TX/RX
  always_ff @(posedge scl or posedge rst) begin : scl_rise
    if (rst) begin
      counter <= 0;
      state   <= IDLE;
    end else begin
      if (start == 1 && state == IDLE) begin
        state   <= DEVICE_ADDRESS;
        rx_reg  <= {rx_reg[6:0], sda};
        counter <= counter_p1;
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
            rx_reg  <= {rx_reg[6:0], sda};
            counter <= counter_p1;
            if (counter == 7) begin
              state <= ACK;
            end
          end
          // Acknowledge device address recieved if we are the intended device
          ACK: begin
            if (ADDRESS == rx_reg[7:1]) begin
              rw <= rx_reg[0];
              if (rx_reg[0] == 0) begin
                counter <= 0;
                state   <= RX;
              end else begin
                counter <= 7;
                state   <= TX;
              end
            end else begin
              state <= IDLE;
            end
          end
          RX: begin
            rx_reg  <= {sda, rx_reg[7:1]};
            counter <= counter_p1;
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
            if (counter == 0) begin
              state <= CACK;
            end else begin
              counter <= counter_n1;
            end
          end
          // Get ACK/NACK from controller
          CACK: begin
            if (sda == 1) begin  // NACK
              counter <= 0;
              state   <= IDLE;
            end else begin  // ACK
              counter <= 7;
              state   <= TX;
            end
          end
          default: begin
          end
        endcase
      end
    end
  end

  // Output logic (this isn't a real state machine, but this is the closest thing to the output block)
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
        if (ADDRESS == rx_reg[7:1]) begin
          output_enable <= 1;
          sda_out <= 0;
        end else begin
          output_enable <= 0;
        end
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
