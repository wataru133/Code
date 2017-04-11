`timescale 1ns/100ps
module test_lfu;
parameter HALF_CYCLE = 5;
parameter CYCLE = HALF_CYCLE*2;
reg clk;
reg rst_n;
reg new_buf_req;
reg [1:0]ref_buf_numbr;
wire [1:0]buf_num_replc;
lfu lfu_01(.clk(clk), .rst_n(rst_n), .new_buf_req(new_buf_req),.ref_buf_numbr(ref_buf_numbr), .buf_num_replc(buf_num_replc));
always begin
  clk = 1'b0;
  #HALF_CYCLE;
  clk = 1'b1;
  #HALF_CYCLE;
end

//-----RESET-----
initial begin
  #(HALF_CYCLE*3) rst_n = 1'b0;
  #HALF_CYCLE rst_n = 1'b1;
end

//-----REF_BUF_NUMBR-----
initial begin
  #(HALF_CYCLE*3);
  #CYCLE ref_buf_numbr = 2'b00;
  #(CYCLE*2) ref_buf_numbr = 2'b11;
  #CYCLE ref_buf_numbr = 2'b01;
  # (50*HALF_CYCLE) $finish;
end

//-----NEW_BUF_REQ-----
initial begin
  #(HALF_CYCLE*3);
  #(CYCLE*2) new_buf_req = 1'b1;
  #CYCLE new_buf_req = 1'b0;
  #(CYCLE*5) new_buf_req = 1'b1;
  #CYCLE new_buf_req = 1'b0;
end
always @ (posedge clk) begin
$strobe ("t= %d, clk=%b, rst_n=%b, new=%b,ref=%d, time=%b,replc=%d ", $stime, clk, rst_n, new_buf_req, ref_buf_numbr, lfu_01.acc_time, buf_num_replc) ;
end
endmodule
`include "dut.v"
