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
  logic [7:0] tx, rx;
  assign tx = 7'h66;

  assign scl = scl_drive;
  assign sda = sda_drive;

  logic [6:0] device_address = 7'h42;
  logic [7:0] memory_address = 8'h67;
  logic [7:0] memory_value = 8'h66;

  i2c_peripheral DUT (
      .tx (tx),
      .scl(scl),
      .sda(sda),
      .rx (rx),
      .rw (rw)
  );

  assign scl_drive = clk;

  always begin
    clk = 0;
    #2;
    clk = 1;
    #2;
  end

  initial begin
    $display("Starting Testbench...");

    ////// TEST WRITING //////
    
    // Signal START
    sda_drive = 1; #7;
    sda_drive = 0; #1;

    // Write device address
    for (ii = 0; ii < 7; ii = ii + 1) begin
      sda_drive = device_address[ii]; #4;
    end
    sda_drive = 0'b0; #4; // Write W
    sda_drive = 1'bz; #4; // Wait for ACK

    // Write memory address
    for (ii = 0; ii < 8; ii = ii + 1) begin
      sda_drive = memory_address[ii]; #4;
    end
    sda_drive = 1'bz; #4; // Wait for ACK

    // Write memory value
    for (ii = 0; ii < 8; ii = ii + 1) begin
      sda_drive = memory_value[ii]; #4;
    end
    sda_drive = 1'bz; #4; // Wait for ACK

    // Signal STOP
    #3;
    sda_drive = 1;
    #101;

    ////// TEST READING //////

    // Signal START
    sda_drive = 1;
    #7
    sda_drive = 0;
    #1

    // Write device address
    for (ii = 0; ii < 7; ii = ii + 1) begin
      sda_drive = device_address[ii]; #4;
    end
    sda_drive = 1'b0; #4; // Write W
    sda_drive = 1'bz; #4; // Wait for ACK

    // Write memory address
    for (ii = 0; ii < 8; ii = ii + 1) begin
      sda_drive = memory_address[ii]; #4;
    end
    sda_drive = 1'bz; #4; // Wait for ACK

    // Send STOP and START again
    #3;
    sda_drive <= 1'b1; #4;
    sda_drive <= 1'b0; #1;


    // Write device address
    for (ii = 0; ii < 7; ii = ii + 1) begin
      sda_drive = device_address[ii]; #4;
    end
    sda_drive = 1'b1; #4; // Write W
    sda_drive = 1'bz; #4; // Wait for ACK

    sda_drive = 1'bz; #32;
    sda_drive = 1'b0; #4; // Send ACK
    
    // Signal STOP
    #3;
    sda_drive = 1;
    #100;
  end

  initial begin
    $dumpfile("i2c_peripheral_tb.vcd");
    $dumpvars(0);
  end

endmodule  // i2c_peripheral_tb
