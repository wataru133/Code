//-----------------------------------------------------------------
// Project Name : Rensas RTL coding training, DesignWS_P1
// 
// File Name : dut.v
// Module Name : lfu
// Function : finds out the Least Frequently Used entry in the four
// Author : QuangNguyen
// Version:1.1
//-----------------------------------------------------------------
module lfu ( clk, rst_n, new_buf_req, ref_buf_numbr, buf_num_replc);
parameter INTL = 8'b01010101;
parameter MAX = 8'hFF;
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
reg control;
reg [7:0]acc_time;
reg [7:0]next_acc_time;
reg [1:0]next_buf_num_replc;
reg [1:0]f_buf_num_replc;
assign buf_num_replc = f_buf_num_replc;

//-----FF FOR BUF_NUM_REPLC-----
always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    f_buf_num_replc <= 2'b00;
  end
  else begin
    f_buf_num_replc <= next_buf_num_replc;
  end
end

//-----FF FOR BUF_NUM_REPLC-----
always @ (posedge clk or negedge rst_n) begin
  if (rst_n == 1'b0) begin
    acc_time  <= INTL;
  end
  else begin
    acc_time  <= next_acc_time;
  end
end


//-----COUTERN ACCESS TIME-----
always @ (new_buf_req or ref_buf_numbr) begin
  if (new_buf_req) begin
    control = 1'b1;
    if ((acc_time[1:0] <= acc_time[7:6]) &&
        (acc_time[1:0] <= acc_time[5:4]) &&
        (acc_time[1:0] <= acc_time[3:2]) ) begin
      next_acc_time[7:2] = acc_time[7:2];
      next_acc_time[1:0] = 2'b01;
    end
    else if ((acc_time[3:2] <= acc_time[7:6]) &&
             (acc_time[3:2] <= acc_time[5:4])  ) begin
      next_acc_time[7:4] = acc_time[7:4];
      next_acc_time[3:2] = 2'b01;
      next_acc_time[1:0] = acc_time[1:0];
    end
    else if ((acc_time[5:4] <= acc_time[7:6])) begin
      next_acc_time[7:6] = acc_time[7:6];
      next_acc_time[5:4] = 2'b01;
      next_acc_time[3:0] = acc_time[3:0];
    end
    else begin
      next_acc_time[7:6] = 2'b01;
      next_acc_time[5:0] = acc_time[5:0];
    end
  end
  else begin
    if (control) begin
      control = 1'b0;
    end
    else begin
      if (acc_time == MAX) begin
        next_acc_time = INTL;
      end
      else begin
        next_acc_time = acc_time;
      end
      case (ref_buf_numbr)
        2'b00:begin
            next_acc_time[7:2] = acc_time[7:2];
            next_acc_time[1:0] = (acc_time[1:0] == 2'b11) ? 2'b11 : (acc_time[1:0] + 2'b01);
        end
        2'b01:begin
            next_acc_time[7:4] = acc_time[7:4];
            next_acc_time[3:2] = (acc_time[3:2] == 2'b11) ? 2'b11 : (acc_time[3:2] + 2'b01);
            next_acc_time[1:0] =  acc_time[1:0];
        end
        2'b10:begin
            next_acc_time[7:6] = acc_time[7:6];
            next_acc_time[5:4] = (acc_time[5:4] == 2'b11) ? 2'b11 : (acc_time[5:4] + 2'b01);
            next_acc_time[3:0] = acc_time[3:0];
        end
        2'b11:begin
           next_acc_time[7:6] = (acc_time[7:6] == 2'b11) ? 2'b11 : (acc_time[7:6] + 2'b01);
           next_acc_time[5:0] = acc_time[5:0];
        end
        default: begin
           next_acc_time[7:0] = 8'b0;
        end
      endcase
    end
  end
end

//-----CONTROL OUTPUT-----
always @ (new_buf_req) begin
  if (new_buf_req) begin
    if ((acc_time[1:0] <= acc_time[7:6]) &&
        (acc_time[1:0] <= acc_time[5:4]) &&
        (acc_time[1:0] <= acc_time[3:2]) ) begin
      next_buf_num_replc = 2'b00;
    end
    else if ((acc_time[3:2] <= acc_time[7:6]) &&
             (acc_time[3:2] <= acc_time[5:4]) ) begin
      next_buf_num_replc = 2'b01;
    end
    else if ((acc_time[5:4] <= acc_time[7:6])) begin
      next_buf_num_replc = 2'b10;
    end
    else begin
      next_buf_num_replc = 2'b11;
    end
  end
  else begin
    next_buf_num_replc = f_buf_num_replc;
  end
end
endmodule
