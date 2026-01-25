`timescale 1ns/1ps

// Simple testbench for ClockDivider
module ClockDividerTb;
  localparam int unsigned DIVIDE_BY = 10;

  logic clk;
  logic rstn;
  logic en;
  logic clk_out;

  // 100MHz input clock (10ns period)
  initial clk = 0;
  always #5 clk = ~clk;

  ClockDivider #(.DIVIDE_BY(DIVIDE_BY)) dut (
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .clk_out(clk_out)
  );

  int unsigned toggle_count;

  initial begin
    rstn = 0;
    en   = 0;
    toggle_count = 0;

    // release reset
    #25 rstn = 1;

    // enable divider
    #20 en = 1;

    // Observe some toggles
    repeat (40) begin
      @(posedge clk);
      if ($changed(clk_out)) toggle_count++;
    end

    $display("ClockDividerTb: observed %0d clk_out toggles", toggle_count);
    $finish;
  end

endmodule
