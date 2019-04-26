/*------------------------------------------------------------------------------
--      File Name = time_display.v                                            --
--                                                                            --
--      Design    = 7Segment LED Display Block                                --
--                                                                            --
--      Revision  = 1.0         Date: 2012.03.22                              --
------------------------------------------------------------------------------*/

 module time_display(
// input
CLK,RSTN,
SEG_A_VAL,SEG_B_VAL,SEG_C_VAL,SEG_D_VAL,
// output
SEG_A,SEG_B,SEG_C,SEG_D
);

// ------ input --------------------------------------------
input  CLK , RSTN;
input  [3:0] SEG_A_VAL,SEG_B_VAL,SEG_C_VAL,SEG_D_VAL;
// ------ output -------------------------------------------
output [7:0] SEG_A,SEG_B,SEG_C,SEG_D;
// ------ wire ----------------------------------------------
wire    [7:0] SEG_A,SEG_B,SEG_C,SEG_D;

display_module dm1(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_A_VAL),
				.SEG(SEG_A)
				);
				
display_module dm2(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_B_VAL),
				.SEG(SEG_B)
				);

display_module dm3(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_C_VAL),
				.SEG(SEG_C)
				);

display_module dm4(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_D_VAL),
				.SEG(SEG_D)
				);

endmodule
