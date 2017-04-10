//-----------------------------------------------------------------
//// Project Name : Exercise 1
//// : lfu
//// File Name : dut.v
//// Module Name : lfu
//// Function : finds out the Least Frequently Used entry in the four.
//// Note : 
//// Author : An Bui (HW1906)
////------------------------------------------------------------------
//// History
//// Version Date Author Description
////---------------------------------------------------------------

module lfu ( clk, rst_n, new_buf_req, ref_buf_numbr, buf_num_replc);

input clk;
input rst_n;
input new_buf_req;
input [1:0]ref_buf_numbr;

output [1:0]buf_num_replc;

wire clk;
wire rst_n;
wire new_buf_req;
wire [1:0]ref_buf_numbr;

wire [1:0]buf_num_replc;

reg [1:0]buf_0_cnt;
reg [1:0]buf_1_cnt;
reg [1:0]buf_2_cnt;
reg [1:0]buf_3_cnt;

always @ (posedge clk or negedge rst_n) begin
    if (rst_n==0) begin
	    buf_0_cnt = 2'b01;
        buf_1_cnt = 2'b01;
        buf_2_cnt = 2'b01;
        buf_3_cnt = 2'b01;		
    end
    else begin
        buf_0_cnt = buf_0_cnt;
        buf_1_cnt = buf_1_cnt;
        buf_2_cnt = buf_2_cnt;
        buf_3_cnt = buf_3_cnt;
    end
end






