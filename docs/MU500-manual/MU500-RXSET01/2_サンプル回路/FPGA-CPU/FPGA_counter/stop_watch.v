/*----------------------------------------------------------------------
--      File Name = stop_watch.v                                      --
--                                                                    --
--      Design    = Stop Watch Top Module                             --
--                                                                    --
--      Revision  = 1.0         Date: 2012.03.22                      --
--                                                                    --
-----------------------------------------------------------------------*/

module stop_watch (
	//--- System ---
		CLK,
		RSTN,

	//--- Switch ---
		PSW,
		RSW,

	//--- 
		SEG_A,

	// SEG_BCD
		SEG_SEL,
		//SEG_B,
		//SEG_C,
		//SEG_D,

	//--- LED ---
		LED,

		CYCLONE_A_OUT,
		CYCLONE_A,
		CYCLONE_B
		);

//--- input/output ----------------------------------------------------
    //--- System ---
	input	CLK;
	input	RSTN;

	input	[3:0]  PSW;
	input	[3:0]  RSW;


	//--- Stop Watch ---
	input	[6:0]   CYCLONE_A;
	output	CYCLONE_A_OUT;
	output	[3:0]	CYCLONE_B;

	output	[7:0]  SEG_A;

	//SEG_BCD
	output	[3:0]  SEG_SEL;
//	output	[7:0]  SEG_B;
//	output	[7:0]  SEG_C;
//	output	[7:0]  SEG_D;

	output	[4:0]  LED;

//--- wire ------------------------------------------------------------
	wire     [3:0] SEG_A_VAL;
	wire     [3:0] SEG_B_VAL;
	wire     [3:0] SEG_C_VAL;
	wire     [3:0] SEG_D_VAL;

	wire     [2:0] PSW_SIG;

	//SEG_BCD
	wire	[3:0]  SEG_SEL;
	wire	[7:0]  SEG_A_0;
	wire	[7:0]  SEG_B_0;
	wire	[7:0]  SEG_C_0;
	wire	[7:0]  SEG_D_0;

//************************** Start of Module ****************************

	assign  LED[0] = CYCLONE_A[0];
	assign  LED[1] = CYCLONE_A[1];
	assign  LED[2] = CYCLONE_A[2];
	assign  LED[3] = CYCLONE_A[3];

	assign  LED[4] = CYCLONE_A_OUT;		//10count
	assign  CYCLONE_B[0] = PSW[0];		//Low Active
	assign  CYCLONE_B[1] = PSW[1];		//
	assign  CYCLONE_B[2] = PSW[2];		//
	assign  CYCLONE_B[3] = PSW[3];		//

	assign  CYCLONE_A_OUT = ~SEG_D_VAL[3] & ~SEG_D_VAL[2] & ~SEG_D_VAL[1] & ~SEG_D_VAL[0] ; //0

	//--- Watch Body ---

	ctrg_rmv	ctrg_rmv1(
		//input
			.CLK(CLK), 
			.RSTN(RSTN),
			.PSW(CYCLONE_A[6:4]),

		//output
			.PSW_SIG(PSW_SIG)
			);

	watch_body	watch_body1(
		//input
			.CLK(CLK),
			.RSTN(RSTN),
			.RST_PULS(PSW_SIG[0]),
			.INC_PULS(PSW_SIG[1]),
			.DEC_PULS(PSW_SIG[2]),

		//output
			.SEG_A_VAL(SEG_A_VAL),
			.SEG_B_VAL(SEG_B_VAL),
			.SEG_C_VAL(SEG_C_VAL),
			.SEG_D_VAL(SEG_D_VAL)
			);

	//--- Time Display ---
	time_display	time_display1(
		//input
			.CLK(CLK),
			.RSTN(RSTN),
			.SEG_A_VAL(SEG_A_VAL),
			.SEG_B_VAL(SEG_B_VAL),
			.SEG_C_VAL(SEG_C_VAL),
			.SEG_D_VAL(SEG_D_VAL),

		//output
			//SEG_BCD
			.SEG_A(SEG_A_0),
			.SEG_B(SEG_B_0),
			.SEG_C(SEG_C_0),
			.SEG_D(SEG_D_0)
			//.SEG_A(SEG_A),
			//.SEG_B(SEG_B),
			//.SEG_C(SEG_C),
			//.SEG_D(SEG_D)
			);


	//--- dynamic_display ---
	dynamic_display	dynamic_display1(
		//input
			.CLK(CLK),
			.RSTN(RSTN),
			.RSW(RSW),
			.SEG_A_0(SEG_A_0),
			.SEG_B_0(SEG_B_0),
			.SEG_C_0(SEG_C_0),
			.SEG_D_0(SEG_D_0),

			//output
			.SEG_A(SEG_A),
			.SEG_SEL(SEG_SEL)
			);

endmodule
