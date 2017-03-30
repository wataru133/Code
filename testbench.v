module testbench ;
parameter HALF_CYCLE = 5 ;
parameter CYCLE = HALF_CYCLE * 2 ;
parameter MAX_LP = 16;
reg clk, rst_n, flick ;
wire [MAX_LP-1:0] lamp ;
// connect signals to flasher
bound_flasher bound_flasher_01 (.clk(clk), .rst_n(rst_n), .flick(flick), .lamp(lamp) ) ;
// connection end
always begin // clock generator
	clk = 1'b0 ;
	# HALF_CYCLE;
	clk = 1'b1 ;
	# HALF_CYCLE ;
end
always @ ( posedge clk ) begin
	$strobe ("t= %d, rst_n=%b, clk=%b, flick=%b, state= %d, lamp=%b",$stime, rst_n, clk, flick,bound_flasher_01.state, lamp ) ;
end
initial begin
//-------------------(1) normal case-------------------------------------------------------
	#4 rst_n = 1'b1;
	#HALF_CYCLE rst_n = 1'b0 ;
	#HALF_CYCLE rst_n = 1'b1;

/*//-------------------(2.1) reset for up_0_15------------------------------------------------
	#4 rst_n = 1'b1;
        #HALF_CYCLE rst_n = 1'b0 ;
        #HALF_CYCLE rst_n = 1'b1;
	#115	    rst_n = 1'b0;
	#HALF_CYCLE rst_n = 1'b1;*/

/*//-------------------(2.2) reset for dow_15_5------------------------------------------------
        #4 rst_n = 1'b1;
        #HALF_CYCLE rst_n = 1'b0 ;
        #HALF_CYCLE rst_n = 1'b1;
        #215        rst_n = 1'b0;
        #HALF_CYCLE rst_n = 1'b1;*/

/*//-------------------(2.3) reset for up_5_10------------------------------------------------
        #4 rst_n = 1'b1;
        #HALF_CYCLE rst_n = 1'b0 ;
        #HALF_CYCLE rst_n = 1'b1;
        #315        rst_n = 1'b0;
        #HALF_CYCLE rst_n = 1'b1;*/

/*//-------------------(2.4) reset for dow_10_0------------------------------------------------
        #4 rst_n = 1'b1;
        #HALF_CYCLE rst_n = 1'b0 ;
        #HALF_CYCLE rst_n = 1'b1;
        #395        rst_n = 1'b0;
        #HALF_CYCLE rst_n = 1'b1;*/

/*//-------------------(2.5) reset for up_0_5------------------------------------------------
        #4 rst_n = 1'b1;
        #HALF_CYCLE rst_n = 1'b0 ;
        #HALF_CYCLE rst_n = 1'b1;
        #495        rst_n = 1'b0;
        #HALF_CYCLE rst_n = 1'b1;*/

/*//-------------------(2.6) reset for dow_5_0------------------------------------------------
        #4 rst_n = 1'b1;
        #HALF_CYCLE rst_n = 1'b0 ;
        #HALF_CYCLE rst_n = 1'b1;
        #545        rst_n = 1'b0;
        #HALF_CYCLE rst_n = 1'b1;*/

/*//--------------------(4)combination--------------------------------------------------------
	##4 rst_n = 1'b1;
        #(HALF_CYCLE*3.5) rst_n = 1'b0 ;
        #(HALF_CYCLE*2.5) rst_n = 1'b1;
        #(HALF_CYCLE*7.5) rst_n = 1'b0;
        #(HALF_CYCLE*4.5) rst_n = 1'b1;
	#(HALF_CYCLE*5.5) rst_n = 1'b0;
	#(HALF_CYCLE*0.5) rst_n = 1'b1;*/

end
initial begin
/*//-------------------(1) normal case-------------------------------------------------------
 	#(HALF_CYCLE*3) flick = 1'b1;
	#HALF_CYCLE flick= 1'b0;
	#(CYCLE *100) $finish;*/

//---------------------(3.1) flick = 1 for case DOW_15_5-----------------------------------
	#(HALF_CYCLE*3) flick = 1'b1;
        #(CYCLE *100) $finish;

/*//---------------------(3.2) flick = 1 for case DOW_10_5 kickback point lam[5]--------------
	#(HALF_CYCLE*3) flick = 1'b1;
        #HALF_CYCLE flick= 1'b0;
	#345 flick = 1'b1;
        #(CYCLE *100) $finish;*/

/*//---------------------(3.3) flick = 1 for case DOW_10_5 kickback point lam[0]-----------------
        #(HALF_CYCLE*3) flick = 1'b1;
        #HALF_CYCLE flick= 1'b0;
        #415 flick = 1'b1;
        #(CYCLE *100) $finish;*/

/*//---------------------(4) combination-----------------------------------------------------
	#(HALF_CYCLE*3) flick = 1'b1;
        #HALF_CYCLE flick= 1'b0;
        #(CYCLE*2.5) flick = 1'b1;
	#(CYCLE*6.5) flick = 1'b0;
	#(HALF*11.4) flick = 1'b1;
	#(CYCLE*50) $finish;*/

end
/*initial begin
	$vcdplusfile ("bound_flasher.vpd");
	$vcdpluson ();
end*/
endmodule
`include "DUT2.v"
