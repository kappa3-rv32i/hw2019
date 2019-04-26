/*------------------------------------------------------------------------------
--      File Name = stop_watch.v                                              --
--                                                                            --
--      Design    = Stop Watch Top Module                                     --
--                                                                            --
--      Revision  = 2.0         Date: 2012.05.22                              --
------------------------------------------------------------------------------*/

module stop_watch (
                    //--- System ---
                    CLK,
                    RSTN,

                    //--- Switch ---
                    PSW,

                    //--- 7SEG-LED ---
                    SEG_A,
                    SEG_SEL
                    );

//--- input -----------------------------------------------------------------
	input         CLK;		// System Clock
	input         RSTN;		// System Reset

	input  [3:0]  PSW;		// Push Switch

//--- output ----------------------------------------------------------------
	output [7:0]  SEG_A;	// 7SEG

	//SEG_SEL
	output	[3:0]  SEG_SEL;

//--- wire ------------------------------------------------------------------
	wire	[3:0] PSW_SIG;		// Push Switch

	wire	[3:0]	SEG_A_VAL;	// 7SEG_A_Value
	wire	[3:0]	SEG_B_VAL;	// 7SEG_B_value
	wire	[3:0]	SEG_C_VAL;	// 7SEG_C_value
	wire	[3:0]	SEG_D_VAL;	// 7SEG_D_value

	wire	[3:0]	SEG_SEL;
	wire	[7:0]	SEG_A_0;
	wire	[7:0]	SEG_B_0;
	wire	[7:0]	SEG_C_0;
	wire	[7:0]	SEG_D_0;

	wire	SEC_SIG;		// Second Signal

//***************************** Start of Module *****************************    //--- Remove Chataring Block ---
	ctrg_rmv    ctrg_rmv1(
                        //input
                        .CLK(CLK),
                        .RSTN(RSTN),
                        .PSW(PSW),

                         //output
                        .PSW_SIG(PSW_SIG)
                        );

    //--- Time Manager ---
	time_manager    time_manager1(
                        //input
                        .CLK(CLK),
                        .RSTN(RSTN),

                        //output
                        .SEC_SIG(SEC_SIG)
                        );

    //--- Watch Body ---
	watch_body    watch_body1(
                        //input
                        .CLK(CLK),
                        .RSTN(RSTN),
			.SEC_SIG(SEC_SIG),
                        .PSW_SIG(PSW_SIG),
 
                        //output
                        .SEG_A_VAL(SEG_A_VAL),
                        .SEG_B_VAL(SEG_B_VAL),
                        .SEG_C_VAL(SEG_C_VAL),
                        .SEG_D_VAL(SEG_D_VAL)
                        );

    //--- Time Display ---
	time_display    time_display1(
                        //input
                        .CLK(CLK),
                        .RSTN(RSTN),
                        .SEG_A_VAL(SEG_A_VAL),
                        .SEG_B_VAL(SEG_B_VAL),
                        .SEG_C_VAL(SEG_C_VAL),
                        .SEG_D_VAL(SEG_D_VAL),

                        //output
                        .SEG_A(SEG_A_0),
                        .SEG_B(SEG_B_0),
                        .SEG_C(SEG_C_0),
                        .SEG_D(SEG_D_0)
                        );

	//--- dynamic_display ---
	dynamic_display	dynamic_display1(
		//input
			.CLK(CLK),
			.RSTN(RSTN),
			.SEG_A_0(SEG_A_0),
			.SEG_B_0(SEG_B_0),
			.SEG_C_0(SEG_C_0),
			.SEG_D_0(SEG_D_0),

			//output
			.SEG_A(SEG_A),
			.SEG_SEL(SEG_SEL)
			);

endmodule
