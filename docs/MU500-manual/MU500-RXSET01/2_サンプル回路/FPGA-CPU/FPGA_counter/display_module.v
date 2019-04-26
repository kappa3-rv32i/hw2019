/*------------------------------------------------------------------------------
--      File Name = display_module.v                                          --
--                                                                            --
--      Design    = 7SEG Display Module                                       --
--                                                                            --
--      Revision  = 1.0         Date: 2012.3.22                              --
------------------------------------------------------------------------------*/
module display_module(
  	// input
  	CLK,RSTN,SEG_VAL,

  	// output
  	SEG
);

//----- input --------------------------------------------
input  CLK,RSTN;
input  [3:0] SEG_VAL;
//----- output -------------------------------------------
output [7:0] SEG;
//----- reg ----------------------------------------------
reg    [7:0] SEG;

	always@( posedge CLK or negedge RSTN ) begin
	  	if( !RSTN )begin
	    	SEG <= 8'b00000000;
		end
		else begin
	    	case( SEG_VAL )
	      		4'h0: SEG <= 8'b11111100;
	      		4'h1: SEG <= 8'b01100000;
	      		4'h2: SEG <= 8'b11011010;
	      		4'h3: SEG <= 8'b11110010;
	      		4'h4: SEG <= 8'b01100110;
	      		4'h5: SEG <= 8'b10110110;
	      		4'h6: SEG <= 8'b10111110;
	      		4'h7: SEG <= 8'b11100000;
	      		4'h8: SEG <= 8'b11111110;
	      		4'h9: SEG <= 8'b11110110;
			endcase
		end
	end

endmodule
