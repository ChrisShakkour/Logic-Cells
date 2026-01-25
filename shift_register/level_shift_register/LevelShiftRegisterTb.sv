`timescale 1ns/1ps

// Testbench for LevelShiftRegister
module LevelShiftRegisterTb;
  parameter int unsigned W_DATA = 8;
  parameter int unsigned DEPTH = 4;

  logic clk;
  logic rstn;
  logic soft_reset;
  logic data_valid;
  logic [W_DATA-1:0] data_in;
  logic [W_DATA-1:0] data_out;

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Instantiate DUT
  LevelShiftRegister #(.W_DATA(W_DATA), .DEPTH(DEPTH)) dut (
    .clk(clk),
    .rstn(rstn),
    .soft_reset(soft_reset),
    .data_valid(data_valid),
    .data_in(data_in),
    .data_out(data_out)
  );

  // Simple stimulus
  initial begin
    rstn = 0; soft_reset = 0; data_valid = 0; data_in = '0;
    #20 rstn = 1; // release reset
    #10;

    // Shift in a few values
    repeat (8) begin
      data_valid = 1;
      data_in = $urandom_range(0, (1<<W_DATA)-1);
      #10;
    end

    data_valid = 0;
    #50 $display("Final data_out = %0h", data_out);
    $finish;
  end

endmodule
