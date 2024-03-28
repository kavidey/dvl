// Modified from: https://edaplayground.com/x/6snM
`timescale 1 ns / 1 ps

// Define Module for Test Fixture
module i2c_peripheral_tb ();
  logic   clk;
  integer ii = 0;

  // Inputs
  wire scl, sda;
  logic scl_drive, sda_drive;
  logic rw;
  logic debug, rst;
  logic [7:0] tx, rx;
  assign tx  = 7'h66;

  assign rst = 0;

  assign scl = scl_drive;
  assign sda = sda_drive;

  logic [6:0] device_address = 7'h42;
  logic [7:0] memory_address = 8'h67;
  logic [7:0] memory_value = 8'h66;

  i2c_peripheral_clk DUT (
      .clk(clk),
      .rst(rst),
      .tx(tx),
      .scl(scl),
      .sda(sda),
      .rx(rx),
      .rw(rw),
      .debug(debug)
  );

  always begin
    clk = 0;
    #1;
    clk = 1;
    #1;
  end

  initial begin
    $display("Starting Testbench...");

    // Reset
    scl_drive = 1;
    #5;
    sda_drive = 0;
    #3;
    sda_drive = 1;
    #5;

    ////// TEST WRITING //////

    // Signal START
    // sda_drive = 1;
    // #7;
    // sda_drive = 0;
    // #1;

    // // Write device address
    // for (ii = 6; 0 <= ii; ii = ii - 1) begin
    //   sda_drive = device_address[ii];
    //   #4;
    // end
    // sda_drive = 0'b0;
    // #4;  // Write W
    // sda_drive = 1'bz;
    // #4;  // Wait for ACK

    // // Write memory address
    // for (ii = 0; ii < 8; ii = ii + 1) begin
    //   sda_drive = memory_address[ii];
    //   #4;
    // end
    // sda_drive = 1'bz;
    // #4;  // Wait for ACK

    // // Write memory value
    // for (ii = 0; ii < 8; ii = ii + 1) begin
    //   sda_drive = memory_value[ii];
    //   #4;
    // end
    // sda_drive = 1'bz;
    // #4;  // Wait for ACK

    // // Signal STOP
    // #3;
    // sda_drive = 1;
    // #101;

    ////// TEST READING //////

    // Signal START
    sda_drive = 1;
    #5 sda_drive = 0;
    #3

    // Write device address
    for (
        ii = 6; ii >= 0; ii = ii - 1
    ) begin
      scl_drive = 0;
      sda_drive = device_address[ii];
      #4;
      scl_drive = 1;
      #4;
    end
    // Write W
    scl_drive = 0;
    sda_drive = 1'b0;
    #4;
    scl_drive = 1;
    #4;

    // Wait for ACK
    scl_drive = 0;
    sda_drive = 1'bz;
    #4;
    scl_drive = 1;
    #4;

    // Write memory address
    for (ii = 7; ii >= 0; ii = ii - 1) begin
      scl_drive = 0;
      sda_drive = memory_address[ii];
      #4;
      scl_drive = 1;
      #4;
    end
    // Wait for ACK
    scl_drive = 0;
    sda_drive = 1'bz;
    #4;
    scl_drive = 1;
    #4;

    // Send STOP and START again
    sda_drive <= 1'b1;
    #7;
    sda_drive <= 1'b1;
    #6;
    sda_drive <= 1'b0;
    #3;


    // Write device address
    for (ii = 6; ii >= 0; ii = ii - 1) begin
      scl_drive = 0;
      sda_drive = device_address[ii];
      #4;
      scl_drive = 1;
      #4;
    end

    // Write R
    scl_drive = 0;
    sda_drive = 1'b1;
    #4;
    scl_drive = 1;
    #4;


    // Wait for ACK
    scl_drive = 0;
    sda_drive = 1'bz;
    #4;
    scl_drive = 1;
    #4;

    sda_drive = 1'bz;
    for (ii = 7; ii >= 0; ii = ii - 1) begin
      scl_drive = 0;
      #4;
      scl_drive = 1;
      #4;
    end
    scl_drive = 0;
    sda_drive = 1'b1;
    #4;
    scl_drive = 1;
    #4;

    // Signal STOP
    #7;
    sda_drive = 1;
    #100;
  end

  initial begin
    $dumpfile("i2c_peripheral_tb.vcd");
    $dumpvars(0);
  end

endmodule  // i2c_peripheral_tb
