/*------------------------------------------------------------------------------
--      File Name = time_display.v                                            --
--                                                                            --
--      Design    = Time Dispaly                                              --
--                                                                            --
--      Revision  = 1.0         Date: 2012.04.19                              --
------------------------------------------------------------------------------*/
module time_display(
		// input
		CLK,
		RSTN,
		SEG_A_VAL,
		SEG_B_VAL,
		SEG_C_VAL,
		SEG_D_VAL,

		// output
		SEG_A,
		SEG_B,
		SEG_C,
		SEG_D
);

// ------ input --------------------------------------------
input  	CLK;		// System Clock
input  	RSTN;		// System Reset
input  	[3:0] SEG_A_VAL,SEG_B_VAL,SEG_C_VAL,SEG_D_VAL;	// 7SEG Value

// ------ output -------------------------------------------
output [7:0] SEG_A,SEG_B,SEG_C,SEG_D;		// 7SEG Display

// ------ wire ----------------------------------------------
wire    [7:0] SEG_A,SEG_B,SEG_C,SEG_D;		// 7SEG Display Wire

//---------------------------
//  7SEG_0
//---------------------------
display_module dm1(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_A_VAL),
				.SEG(SEG_A)
				);

//---------------------------
//  7SEG_1
//---------------------------
display_module dm2(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_B_VAL),
				.SEG(SEG_B)
				);

//---------------------------
//  7SEG_2
//---------------------------
display_module dm3(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_C_VAL),
				.SEG(SEG_C)
				);

//---------------------------
//  7SEG_3
//---------------------------
display_module dm4(
				.CLK(CLK),
				.RSTN(RSTN),
				.SEG_VAL(SEG_D_VAL),
				.SEG(SEG_D)
				);

endmodule
