
//-----------------------------------------------------------------
//// Project Name : Exercise 1
//// : bound flasher
//// File Name : dut.v
//// Module Name : bound_flasher
//// Function : this logic flash lamps in sequence at every clock rise time
//// lamp will go up and down.
//// Note : 
//// Author : An Bui (HW1906)
////------------------------------------------------------------------
//// History
//// Version Date Author Description
////---------------------------------------------------------------

module sys_ctl ( clk, rst_n, flick, lp) ;

// parameters
    parameter INIT    = 3'b000 ; // initial state all lamp is off
    parameter ST_0_15 = 3'b001 ; // lamp turn ON  for lamp [0]  to lamp [15] 
    parameter ST_15_5 = 3'b010 ; // lamp turn OFF for lamp [15] to lamp [0]
    parameter ST_5_10 = 3'b011 ; // lamp turn ON  for lamp [5]  to lamp [10]
    parameter ST_10_0 = 3'b100 ; // lamp turn OFF for lamp [10] to lamp [0]
    parameter ST_0_5  = 3'b101 ; // lamp turn ON  for lamp [0]  to lamp [5]
    parameter ST_5_0  = 3'b110 ; // lamp turn OFF for lamp [5]  to lamp [0]

    parameter MX_LP   = 16     ; // number of lamps
    parameter KB_PT_1 = 5      ; // the first  kickback_point
    parameter KB_PT_2 = 0      ; // the second kickback_point
    parameter FF_DLY  = 1      ; // delay for FF to avoid racing

// port definition
    input clk, rst_n ;
    input flick ; // input signal to start system
    input [MX_LP-1:0] lp ;

    output go_up, go_dwn ;

    wire clk, rst_n ;
    wire flick ;
	reg [MX_LP-1:0] lp ; // lamps


//internal variables
    reg [2:0] f_state ; // FF for state
    reg [2:0] next_f_state ; // non-FF

    always @ ( posedge clk or negedge rst_n ) begin
        if ( rst_n==1'b0 ) begin // initialize state
            f_state[2:0] <= #FF_DLY INIT ;
            end
        else begin
            f_state[2:0] <= #FF_DLY next_f_state[2:0] ;
        end
    end

    always @ ( f_state or flick or lp ) begin
            case ( f_state[2:0] )

                    INIT    : begin
                            next_f_state[2:0] = ( flick )? ST_0_15 : f_state[2:0] ;
                    end

                    ST_0_15 : begin
                            next_f_state[2:0] = ( lp [MX_LP-1] )?  ST_15_5 : f_state[2:0] ;
                    end

                    ST_15_5 : begin
                        if ( (lp[KB_PT_1-1]==1)&&(lp[KB_PT_1]==0)) begin
                            next_f_state[2:0] = ( flick )? ST_0_15 : ST_5_10 ;
                        end
                        else begin
                            next_f_state[2:0] = f_state[2:0] ;
                        end
                    end

                    ST_5_10 : begin
                            next_f_state[2:0] = ( lp[10])? ST_10_0 : f_state[2:0] ;
                    end

                    ST_10_0 : begin
                        if ( lp[0]==0) begin
                            next_f_state[2:0] = ( flick )? ST_5_10 : ST_0_5 ;
                        end 
                        else if ( (lp[KB_PT_1-1]==1)&&(lp[KB_PT_1]==0)) begin
                            next_f_state[2:0] = ( flick )? ST_5_10 : f_state[2:0] ;
                        end 
                        else begin
                            next_f_state[2:0] = f_state[2:0] ;
                        end
                    end

                    ST_0_5  : begin
                            next_f_state[2:0] = ((lp[KB_PT_1]==1)&&(lp[KB_PT_1+1]==0)) ? ST_5_0 : f_state[2:0]  ;
                    end

                    ST_5_0  : begin
                            next_f_state[2:0] = ( lp[0] )? f_state[2:0]  : INIT ;
                    end

                    default : begin
                            next_f_state[2:0] = 3'bxxx ; // for debug
                    end
            endcase
    end

    always @ ( f_state or flick ) begin
            case ( f_state )
                    INIT 	: begin
                            lp = ( flick )? 16'h01 : 16'h01 ;
                    end

                    ST_0_15	: begin
                            lp = lp<<1;
							lp = lp | 16'h01;
                    end

					ST_15_5 : begin
                            lp = lp>>1;
                    end

                    ST_5_10	: begin
                            lp = lp<<1;
							lp = lp | 16'h01;
                    end
					
					ST_10_0	: begin
                            lp = lp>>1;
                    end
					
					ST_0_5	: begin
                            lp = lp<<1;
							lp = lp | 16'h01;
                    end
					
					ST_5_0	: begin
                            lp = lp>>1;
                    end

                    default : begin
                            lp = 1'bx ;
                    end
            endcase
    end
endmodule