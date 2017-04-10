//-----------------------------------------------------------------
//// Project Name : Exercise 2
//// : LFU
//// File Name : dut.v
//// Module Name : lfu
//// Function : Finds out the Least Frequently Used entry in the four
//// entries.
//// Note : 
//// Author : An Bui (HW1906)
////------------------------------------------------------------------
//// History
//// Version Date Author Description
////---------------------------------------------------------------

module lfu_finder ( clk, rst_n, new_buf_req,
        ref_buf_numbr, buf_num_replc ) ;

    input clk;
    input rst_n;
    input new_buf_req ;
    input [1:0] ref_buf_numbr ;

    output[1:0] buf_num_replc ;

    wire clk; 
    wire rst_n ;
    wire new_buf_req ;
    wire [1:0] ref_buf_numbr ;
    wire [1:0] buf_num_replc ;

    // internal signals
    reg [7:0] ref_seq ; // FF
    reg [7:0] next_ref_seq ; // non-FF

    reg [7:0] num_acc;
    reg [7:0] next_num_acc;

    wire [1:0] ref_numbr ;

    assign buf_num_replc = ref_seq[1:0] ;
    assign ref_numbr = ( new_buf_req == 1'b1 )?
            ref_seq[7:6] : ref_buf_numbr ;

    always @ ( posedge clk or negedge rst_n ) begin
        if ( rst_n == 1'b0 ) begin
            // initialize reference sequence
            // #0(old), #1, #2, and #3(new) order
            ref_seq <= 8'b11_10_01_00 ;
        end
        else begin
            ref_seq <= next_ref_seq ;
        end
    end
    
    always @ ( posedge clk or negedge rst_n ) begin
        if ( rst_n == 1'b0 ) begin
            num_acc <= 8'b01_01_01_01 ;
        end
        else begin
            num_acc <= next_num_acc ;
        end
    end

    always @ ( ref_seq[7:0] or ref_numbr ) begin
        case ( ref_numbr[1:0] )

            ref_seq[7:6] : begin
                new_ref_seq = { ref_seq[5:0], ref_seq[7:6] } ;
            end

            ref_seq[5:4] : begin
                new_ref_seq = { ref_seq[7:6], ref_seq[3:0],
                    ref_seq[5:4] } ;
            end

            ref_seq[3:2] : begin
                new_ref_seq = { ref_seq[7:4], ref_seq[1:0],
                    ref_seq[3:2] } ;
            end

            ref_ref_seq[1:0] : begin
                new_ref_seq = { ref_seq[7:2], ref_seq[1:0] } ;
            end

            default : begin
                new_ref_seq = 8'bxx_xx_xx_xx ;
            end

        endcase
    end
endmodule
