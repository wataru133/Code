//-----------------------------------------------------------------
// Project Name : Rensas RTL coding training, DesignWS_P1
// 
// File Name : dut.v
// Module Name : lfu
// Function : finds out the Least Frequently Used entry in the four
// Author : QuangNguyen
// Version:0
//-----------------------------------------------------------------
module lfu ( clk, rst_n, new_buf_req, ref_buf_numbr, buf_num_replc);

//-----INPUT SIGNALS-----
input clk;
input rst_n;
input new_buf_req;
input [1:0]ref_buf_numbr;
wire clk;
wire rst_n;
wire new_buf_req;
wire [1:0]ref_buf_numbr;

//-----OUTPUT SIGNALS-----
output [1:0]buf_num_replc;
wire [1:0]buf_num_replc;

//-----EXTERNAL SIGNALS-----
reg [7:0]acc_ti;
reg [1:0]next_buf_num_replc;
reg [1:0]f_buf_num_replc;

//-----FF FOR BUF_NUM_REPLC-----
assign buf_num_replc = f_buf_num_replc;
always @ (posedge clk or negedge rst_n) begin
  if (rst_n = 1'b0) begin
    f_buf_num_repcl <= 2'b00;
  end
    f_buf_num_replc <= next_buf_num_replc;
  else begin
  end
end

//-----COUTERN ACCESS TIME-----
always @ (posedge new_buf_req or ref_buf_numbr) begin
  if (new_buf_req) begin
  end
  else begin
    case(ref_buf_numbr)
      2'b00:begin
          acc_ti[1:0] = (acc_ti[1:0] == 2'b11) ? 2'b11 : (acc_ti[1:0] + 2'b01);
//        if (acc_ti[1:0] == 2'b11) begin
//          acc_ti[1:0] = 2'b11;
//        end
//        else begin
//          acc_ti[1:0] = acc_ti[1:0] + 2'b01;
//        end
      end
      2'b01:begin
          acc_ti[3:2] = (acc_ti[3:2] == 2'b11) ? 2'b11: (acc_ti[3:2] + 2'b01);
//        if (acc_ti[3:2] == 2'b11) begin
//          acc_ti[3:2] = 2'b11;
//        end
//        else begin
//          acc_ti[3:2] = acc_ti[3:2] + 2'b01;
//        end
      end
      2'b10:begin
          acc_ti[5:4] = (acc_ti[5:4] == 2'b11) ? 2'b11: (acc_ti[5:4] + 2'b01);
//        if (acc_ti[5:4] == 2'b11) begin
//          acc_ti[5:4] = 2'b11;
//        end
//        else begin
//          acc_ti[5:4] = acc_ti[5:4] + 2'b01;
//        end
      end
      2'b11:begin
          acc_ti[7:6] = (acc_ti[7:6] == 2'b11) ? 2'b11: (acc_ti[7:6] + 2'b01);
//        if (acc_ti[7:6] == 2'b11) begin
//          acc_ti[7:6] = 2'b11;
//        end
//        else begin
//          acc_ti[7:6] = acc_ti[7:6] + 2'b01;
//        end
      end
      default: begin
        acc_ti[7:0] = 8'b0;
      end
    endcase
  end
end
always @ (acc_ti) begin
  if () begin
  end
  else if () begin
  end
  else if () begin
  end
  else begin
  end
end
endmodule
