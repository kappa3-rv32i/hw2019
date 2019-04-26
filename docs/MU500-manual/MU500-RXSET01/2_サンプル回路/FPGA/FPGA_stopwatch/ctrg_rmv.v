/*------------------------------------------------------------------------------
--      File Name = ctrg_rmv.v                                                --
--                                                                            --
--      Design    = Remove Chattering Module                                  --
--                                                                            --
--      Revision  = 1.0         Date: 2012.05.21                              --
------------------------------------------------------------------------------*/ 
	module ctrg_rmv( 
		// input
	  	CLK, 
		RSTN,
	  	PSW,

		// output
	  	PSW_SIG
	);

//------ input --------------------------------------------
	input  	CLK;			// System Clock
	input  	RSTN;			// System Reset
	input  	[3:0] PSW;		// Push Switch

//------ output -------------------------------------------
	output 	[3:0] PSW_SIG;	// High Pulse Switch Signal

//------ reg ----------------------------------------------
	reg    	[3:0] PSW_1D;   // Delay Push Switch

//******************** Start of Module ********************

//---------------------------
// 		System Reset
//---------------------------
	always@( posedge CLK or negedge RSTN ) begin
		if( RSTN == 1'b0 )begin
	    	PSW_1D <= 1'b0000;
		end
	  	else begin
	    	PSW_1D <= PSW;
		end
	end

//---------------------------
// 		Push Switch 0
//---------------------------
	key_module key_module1( 	
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[0]),
								.PSW_SIG(PSW_SIG[0])
							);

//---------------------------
// 		Push Switch 1
//---------------------------
	key_module key_module2(
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[1]),
								.PSW_SIG(PSW_SIG[1])
							);

//---------------------------
// 		Push Switch 2
//---------------------------
	key_module key_module3(
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[2]),
								.PSW_SIG(PSW_SIG[2])
							);

//---------------------------
// 		Push Switch 3
//---------------------------
	key_module key_module4(
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[3]),
								.PSW_SIG(PSW_SIG[3])
							);

endmodule
