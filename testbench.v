
`timescale 1ns/100ps


module test_bndflsh ;

    parameter HALF_CYCLE = 5 ;
    parameter CYCLE = HALF_CYCLE * 2 ;
    parameter MX_LP = 16;

    reg clk, rst_n, flick ;
    wire [2:0] next_state ;
    wire [MX_LP-1:0] lamp ;

    // connect signals to flasher
    bound_flasher bound_flasher_01 (.clk(clk), .rst_n(rst_n), .flick(flick),.lamp(lamp)) ;

    always begin // clock generator
        clk = 1'b1 ;
        # HALF_CYCLE clk = 1'b0 ;
        # HALF_CYCLE ;
    end

    always @ ( posedge clk ) $strobe ("t= %d, rst_n=%b, clk=%b, flick=%b,lamp=%b",
                $stime, rst_n, clk, flick, lamp ) ;

    initial begin
//        rst_n = 1'b1;
//        #CYCLE rst_n = 0 ;
//        #(CYCLE * 3 ) rst_n = 1'b1 ;
        
                    rst_n = 1'b0;
        #(CYCLE*2)  rst_n = 1'b1;
        #(CYCLE*157)rst_n = 1'b0;
        #(CYCLE*4)  rst_n = 1'b1;
        #(CYCLE*45) rst_n = 1'b0;
        #(CYCLE*3)  rst_n = 1'b1;
    end
    
    initial begin // give value to control variable
//        flick = 1'b0 ;
//
//        # (CYCLE * 4 ) flick = 1'b1 ;
//        # (CYCLE * 2 ) flick = 1'b0 ;
//        # (CYCLE * 56 ) flick = 1'b1 ;
//        # (CYCLE * 2 ) flick = 1'b0 ;
//
//        #(CYCLE * 1000 ) $finish; 

                       flick = 1'b0 ;
        # (CYCLE * 2);
        # (CYCLE * 2)  flick = 1'b1; 
        # (CYCLE * 2)  flick = 1'b0;
        # (CYCLE * 60) flick = 1'b1; 
        # (CYCLE * 30) flick = 1'b0;
        # (CYCLE * 50) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 32) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 30) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0;
        # (CYCLE * 37) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 35) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 32) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0;
        # (CYCLE * 12) flick = 1'b1; 
        # (CYCLE * 35) flick = 1'b1; 
        # (CYCLE * 20) rst_n = 1'b0;
        # (CYCLE * 5 ) flick = 1'b0;
        # (CYCLE * 15) rst_n = 1'b1;
        # (CYCLE * 5 ) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 20) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 29) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 
        # (CYCLE * 12) flick = 1'b1; 
        # (CYCLE * 5)  flick = 1'b0; 

        # (CYCLE * 100) $finish;



    end
	
	/*initial begin
		$vcdplusfile ("bound_flasher.vpd");
		$vcdpluson ();
	end*/

endmodule

`include "DUT.v"
