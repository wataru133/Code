module bound_flasher (clk, rst_n, flick, lamp);
parameter MAX_LP = 16;
parameter TN_PT_MAX = 15;
parameter TN_PT_10 = 10;
parameter TN_PT_5 = 5;
parameter FF_DL = 1;
parameter TN_PT_VALUE = 16'b11111; //turning point value
parameter INTL = 3'd0;
parameter UP_0_15 = 3'd1;
parameter DOW_15_5 = 3'd2;
parameter UP_5_10 = 3'd3;
parameter DOW_10_0 = 3'd4;
parameter UP_0_5 = 3'd5;
parameter DOW_5_0 = 3'd6;
parameter UP_0_10 = 3'd7;
input clk, rst_n, flick;
output [MAX_LP - 1:0] lamp;
wire clk, rst_n,flick;
reg [MAX_LP - 1:0] lamp;
reg [2:0] state, next_state;
reg [15:0] next_lamp;
//-------------------FF FOR STATE-----------------------------
always @( posedge clk or negedge rst_n) 
begin
 if ( rst_n == 1'b0) begin
  state <= #FF_DL INTL;
 end
 else begin
  state <= #FF_DL next_state;
 end
end
//--------------------CONTROL STATE----------------------------
always @(state or flick or lamp) 
begin
 case (state) 
    INTL:begin
     next_state = (flick)? UP_0_15 : state;
    end
    UP_0_15:begin
     next_state = (lamp[14]) ? DOW_15_5 : state;
    end
    DOW_15_5:begin
     next_state = (lamp[6]==1'b0) ? UP_5_10 : state;
    end
    UP_5_10:begin
		if (lamp[9]) begin
			next_state = DOW_10_0;
		end
		else begin
			if (lamp[(MAX_LP-1):0] == TN_PT_VALUE) begin
				next_state = (flick) ? UP_0_15 : state;
			end
			else begin
				next_state = state;
			end
		end
    end
    DOW_10_0:begin
		if (lamp[1] == 1'b0) begin
			next_state = UP_0_5;
		end
		else begin
			if (lamp[(MAX_LP-1):0] == TN_PT_VALUE) begin
				next_state = (flick) ? UP_0_10 : state;
			end
			else begin
				next_state = state;
			end
		end
    end
    UP_0_5:begin
		if (lamp[4]) begin
			next_state = DOW_5_0;
		end
		else begin
			if (lamp[(MAX_LP-1):0] == 16'b0) begin
				next_state = (flick) ? UP_0_10 : state;
			end
			else begin
				next_state = state;
			end
		end
    end
    DOW_5_0:begin
     next_state = (lamp[1] == 1'b0) ? INTL : state;
    end
    UP_0_10:begin
     next_state = (lamp[9]) ? DOW_10_0 : state;
    end
    default: begin
     next_state = 3'b0;
    end
 endcase
end
//-------------------FF FOR LAMP-----------------------------
always @(posedge clk or negedge rst_n) 
begin
	if ( rst_n == 1'b0)
		begin
			lamp <= #FF_DL {MAX_LP {1'b0}};
		end
	else
		begin
			lamp <= #FF_DL next_lamp;
		end
end
//-------------------CONTROL LAMP-----------------------------
always @(state or flick or lamp) 
begin
	case (state) 
		INTL:begin
				next_lamp = (flick) ? {lamp[14:0],1'b1}: 16'b0;
			end
		UP_0_15:begin
				next_lamp = {lamp[14:0],1'b1};
		end
		DOW_15_5:begin
				next_lamp = {1'b0, lamp[15:1]};
			end
		UP_5_10:begin
				next_lamp = {lamp[14:0],1'b1};
			end
		DOW_10_0:begin
					if (lamp[(MAX_LP -1):0] == TN_PT_VALUE) begin
						next_lamp = (flick) ? {lamp[14:0],1'b1} : {1'b0, lamp[15:1]};
					end
					else begin
						next_lamp = {1'b0, lamp[15:1]};
					end
			end
		UP_0_5:begin
				next_lamp = {lamp[14:0],1'b1};
			end
		DOW_5_0:begin
				next_lamp = {1'b0, lamp[15:1]};
			end
		UP_0_10:begin
				next_lamp = {lamp[14:0],1'b1};
			end
		default: begin
				next_lamp = 16'h0;
			end
	endcase
end
endmodule
