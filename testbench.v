module test_lfu_finder ;

//    initial begin
//        $vcdplusfile ("testbench.vpd");
//	$vcdpluson ();
//    end

    parameter HF_CYCL = 5 ;
    parameter CYCL = HF_CYCL*2 ;

    reg     clk;
    reg     rst_n ;
    reg     b_rq ;
    reg     [1:0] ref ;
    wire    [1:0] rplc ;

    lfu lfu_01( .clk( clk ), .rst_n( rst_n ),
        .new_buf_req( b_rq ), .ref_buf_numbr( ref ),
        .buf_num_replc( rplc ));

    always begin // clock generator
        clk = 1'b0 ; #HF_CYCL ;
        clk = 1'b1 ; #HF_CYCL ;
    end

    initial begin 
                    rst_n = 1'b1 ;
        #(CYCL*2)   rst_n = 1'b0 ;
        # CYCL      rst_n = 1'b1 ;
    end

   // always @ ( posedge clk ) begin
     //   $strobe("t=%d, rst_n=%b, new_buf_req=%b, ref_buf_num= %d, buf_num_replc=%d, buf0=%d, buf1=%d, buf2=%d, buf3=%d , seq=%b",
    //    $stime, rst_n, b_rq, ref, rplc, lfu.buf_0_cnt,  lfu.buf_1_cnt, lfu.buf_2_cnt,
    //            lfu.buf_3_cnt, lfu.ref_seq,) ;
  //  end

    initial begin
                    b_rq = 1'b0;
       // #(CYCL*3)   b_rq = 1'b1;
       // # CYCL      b_rq = 1'b0;
       // #(CYCL*5)   b_rq = 1'b1;
       // # CYCL      b_rq = 1'b0;
       // #(CYCL*2)   b_rq = 1'b1;
       // # CYCL      b_rq = 1'b0;
       // #(CYCL*11)  b_rq = 1'b1;
       // # CYCL      b_rq = 1'b0;
    end

    initial begin
              ref = 2'bxx;
        #(CYCL*3) ref = 2'b00;
        #CYCL ref = 2'b01;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b11;
        #CYCL ref = 2'b01;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b11;
        #CYCL ref = 2'b01;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b01;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b11;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b11;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b11;
        #CYCL ref = 2'b01;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b01;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b11;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b10;
        #CYCL ref = 2'b00;
        #CYCL ref = 2'b11;
        #CYCL $finish;
    end

endmodule

`include "dut.v"
