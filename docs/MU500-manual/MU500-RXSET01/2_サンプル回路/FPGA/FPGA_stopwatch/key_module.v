/*------------------------------------------------------------------------------
--      File Name = key_module.v                                              --
--                                                                            --
--      Design    = Key Module                                                --
--                                                                            --
--      Revision  = 1.0         Date: 2012.05.18                              --
-------------------------------------------------------------------------------*/

module key_module(
 		//input
		CLK, 
		RSTN,
		PSW_1D,

 		//output
		PSW_SIG
);

//------ input ----------------------------------------------------------------
input		CLK; 				// System Clock
input		RSTN;				// System Reset
input		PSW_1D;				// Push Switch 1 Delay

//------ output ---------------------------------------------------------------
output	PSW_SIG;			// Remove Chattering Signal(High pulse Signal)

//------ reg ------------------------------------------------------------------
reg		PSW_2D;				// Push Switch 2 Delay
reg	[1:0]		PSW_DIFF;	// Check Push Switch Change
reg	[18:0]	PSW_COUNT;	// 500,000 Clock Counter
reg	PSW_SIG;					// 

//---------------------------
// Delay Push Switch Signal
//---------------------------
	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
    		PSW_2D <= 1'b0;
		end

		else begin
    		PSW_2D <= PSW_1D;
		end
	end

//---------------------------
// Check Push Switch Change
//---------------------------
	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
	    	PSW_DIFF <= 2'd0;
		end

		else if(PSW_1D == 1 && PSW_2D == 1)begin
	    	PSW_DIFF <= 2'd0;
		end
	  	else if(PSW_1D == 0 && PSW_2D == 1)begin
	    	PSW_DIFF <= 2'd1;
		end
	  	else if(PSW_1D == 0 && PSW_2D == 0)begin
	    	PSW_DIFF <= 2'd2;
		end
	  	else begin
	    	PSW_DIFF <= 2'd3;
		end
	end

//---------------------------
//  Push Switch Counter
//---------------------------
	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
	    	PSW_COUNT <= 19'd0;
		end

	  	else if( PSW_DIFF == 2'd0)begin
	    	PSW_COUNT <= 19'd0;
		end
	  	else if( PSW_DIFF == 2'd1)begin
	    	PSW_COUNT <= 19'd1;
		end
	  	else if( PSW_DIFF == 2'd2)begin
	    	if( 19'd1 <= PSW_COUNT && PSW_COUNT < 19'd500000 )begin
	      		PSW_COUNT <= PSW_COUNT + 19'd1;
			end
	    	else begin
	      		PSW_COUNT <= 19'd0;
			end
		end
		else begin
			PSW_COUNT <= 19'd0;
		end
	end

//---------------------------
// Output Switch High pulse
//---------------------------
	always@( posedge CLK or negedge RSTN) begin
	  	if( RSTN == 1'b0 )begin
	    	PSW_SIG <= 1'b0;
		end
	  	else if( PSW_COUNT >= 19'd500000 )begin
	    	PSW_SIG = 1'b1;
		end
	  	else begin
	    	PSW_SIG = 1'b0;
		end
	end

endmodule
