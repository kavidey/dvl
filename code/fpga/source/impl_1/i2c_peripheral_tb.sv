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

  assign scl = scl_drive;
  assign sda = sda_drive;

  logic [6:0] device_address = 7'h42;
  logic       readWrite = 1'b0;  //write
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
    
    // Set SDA Low to start
    sda_drive = 1;
    #7
    sda_drive = 0;
    #1

    // Write address
    for (ii = 0; ii < 7; ii = ii + 1) begin
      $display("Address SDA %h to %h", sda, device_address[ii]);
      sda_drive = device_address[ii]; #4;
    end

    // Are we wanting to read or write to/from the device?
    $display("Read/Write %h SDA: %h", readWrite, sda_drive);
    sda_drive = readWrite; #4;

    // Next SDA will be driven by peripheral, so release it
    sda_drive = 1'bz; #4;

    $display("SDA: %h", sda);

    for (ii = 0; ii < 8; ii = ii + 1) begin
      $display("Data SDA %h to %h", sda, memory_address[ii]);
      sda_drive = memory_address[ii]; #4;
    end

    // Next SDA will be driven by peripheral, so release it
    sda_drive = 1'bz; #4;

    for (ii = 0; ii < 8; ii = ii + 1) begin
      $display("Data SDA %h to %h", sda, memory_value[ii]);
      sda_drive = memory_value[ii]; #4;
    end

    // Next SDA will be driven by peripheral, so release it
    sda_drive = 1'bz; #4;

    // Force SDA high again, we are done
    #3;
    sda_drive = 1;
    #100;
    // $finish();
  end

  initial begin
    $dumpfile("i2c_peripheral_tb.vcd");
    $dumpvars(0);
  end

endmodule  // i2c_peripheral_tb
