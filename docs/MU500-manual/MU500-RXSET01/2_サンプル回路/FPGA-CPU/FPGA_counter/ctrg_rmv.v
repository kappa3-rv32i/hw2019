/*------------------------------------------------------------------------------
--      File Name = strg_rmv.v                                                --
--                                                                            --
--      Design    = Chattering Module                                         --
--                                                                            --
--      Revision  = 1.0         Date: 2012.3.22                               --
------------------------------------------------------------------------------*/ 
	module ctrg_rmv( 
	// input
	  CLK, RSTN,
	  PSW,
	// output
	  PSW_SIG
	);

//------ input --------------------------------------------
	input  CLK,RSTN;
	input  [2:0] PSW;
//------ output -------------------------------------------
	output [2:0] PSW_SIG;
//------ reg ----------------------------------------------
	reg    [2:0] PSW_1D;

//******************** Start of Module ********************
	always@( posedge CLK or negedge RSTN ) begin
		if( RSTN == 1'b0 )begin
	    	PSW_1D <= 1'b000;
		end
	  	else begin
	    	PSW_1D <= PSW;
		end
	end

	key_module key_module1( 	
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[0]),
								.PSW_SIG(PSW_SIG[0])
							);

	key_module key_module2(
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[1]),
								.PSW_SIG(PSW_SIG[1])
							);

	key_module key_module3(
								.CLK(CLK),
								.RSTN(RSTN),
								.PSW_1D(PSW_1D[2]),
								.PSW_SIG(PSW_SIG[2])
							);


	endmodule
