/*------------------------------------------------------------------------------
--      File Name = time_manager.v                                            --
--                                                                            --
--      Design    = Second Signal Create                                      --
--                                                                            --
--      Revision  = 1.0         Date: 2012.04.26                               --
------------------------------------------------------------------------------*/   
module time_manager(
	//input
		CLK,
		RSTN,
	//output
		SEC_SIG
);

//--- input --------------------------------------------------------------
input CLK;
input RSTN;

//--- output -------------------------------------------------------------
output SEC_SIG;

//--- reg ----------------------------------------------------------------
reg [27:0] SEC_COUNT;
reg SEC_SIG;

	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
    		SEC_COUNT <= 28'd0;
		end
		else if( SEC_COUNT >= 28'd20000000 - 28'd1)begin
			SEC_COUNT <= 28'd0;
		end
  		else begin
    		SEC_COUNT <= SEC_COUNT + 28'd1;
		end
	end

	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
    		SEC_SIG <= 1'b0;
		end
  		else if( SEC_COUNT >= 28'd20000000 - 28'd1 )begin
    		SEC_SIG <= 1'b1;
		end
  		else begin
   	 		SEC_SIG <= 1'b0;
		end
	end

endmodule
