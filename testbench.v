`timescale 1ns/100ps


module test_bndflsh ;

    parameter HALF_CYCLE = 5 ;
    parameter CYCLE = HALF_CYCLE * 2 ;
    parameter MX_LP = 16;

    reg clk, rst_n, flick ;
    wire [2:0] next_state ;
    wire [MX_LP-1:0] lamp ;

    // connect signals to flasher
    bound_flasher bound_flasher_01 (.clk(clk), .rst_n(rst_n), .flick(flick),.a_lamp(lamp),
            .a_next_state(next_state)  ) ;

    always begin // clock generator
        clk = 1'b1 ;
        # HALF_CYCLE clk = 1'b0 ;
        # HALF_CYCLE ;
    end

    always @ ( posedge clk ) $strobe ("t= %d, rst_n=%b, clk=%b, flick=%b, next_st=%b, lamp=%b",
                $stime, rst_n, clk, flick,next_state, lamp ) ;

    initial begin
            rst_n = 1'b1;
       # CYCLE rst_n = 0 ;
        # (CYCLE * 3 ) rst_n = 1'b1 ;
    end
    
    initial begin // give value to control variable
        flick = 1'b0 ;

        # (CYCLE * 4 ) flick = 1'b1 ;
        # (CYCLE * 0.5 ) flick = 1'b0 ;
        #(CYCLE * 100 ) $finish; 
    end
endmodule

`include "dut.v"
