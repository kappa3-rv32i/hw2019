/*------------------------------------------------------------------------------
--      File Name = watch_body.v                                              --
--                                                                            --
--      Design    = StopWatch Main Block                                      --
--                                                                            --
--      Revision  = 1.0         Date: 2012.04.19                              --
------------------------------------------------------------------------------*/

	module watch_body (
	  		//input
	  		CLK,
	  		RSTN,
	  		PSW_SIG,
	  		SEC_SIG,

	  		//output
	  		SEG_A_VAL,
			SEG_B_VAL,
			SEG_C_VAL,
			SEG_D_VAL
	);

//--- input --------------------------------------------------------------------
input  CLK;				// Clock 10MHz
input  RSTN;			// System Reset
input  [3:0] PSW_SIG;	// 0:Start / Stop  1:Reset  2:Increment  3:Decrement
input  SEC_SIG;			// Second Signal

//--- output -------------------------------------------------------------------
output [3:0] SEG_A_VAL,SEG_B_VAL,SEG_C_VAL,SEG_D_VAL;	// 7seg out

//--- reg ----------------------------------------------------------------------
reg  MOVE_FLG;											// 0:Stop Mode   1:Moveing Mode

reg  PLUS_A, MINUS_A;									// Count Up Signal
reg  [3:0] COUNT_A, COUNT_B, COUNT_C, COUNT_D;			// Count Register
reg  CARRY_A, CARRY_B, CARRY_C;							// Carry Up Signal
reg  DOWN_A,  DOWN_B,  DOWN_C;							// Carry Down Signal
reg  SEC_SIG_1D,SEC_SIG_2D,SEC_SIG_3D;					// Delay Second Signal

reg  [3:0] COUNT_A_1D, COUNT_A_2D,COUNT_A_3D;			// Delay Control COUNT_A
reg  [3:0] COUNT_B_1D, COUNT_B_2D;						// Delay Control COUNT_B
reg  [3:0] COUNT_C_1D;									// Delay Control COUNT_C

//****************************** Start of Module ******************************
//-------------------
//    Change Mode
//-------------------
	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN ) begin
			MOVE_FLG <= 1'b0;
	  	end

	  	else if( PSW_SIG[0] == 1'b1) begin
	    	 MOVE_FLG <= ~MOVE_FLG;
	  	end
      	else if( PSW_SIG[1] == 1'b1 )begin
			MOVE_FLG <= 1'b0;
		end
	 	else begin
	    	 MOVE_FLG <= MOVE_FLG;
	  	end
	end

//-------------------------
// Count Up Signal Create
//-------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			PLUS_A  <= 1'b0;
     		MINUS_A <= 1'b0;
		end

    	else if( PSW_SIG[2] == 1'b1 )begin
      		PLUS_A  <= 1'b1;
			MINUS_A <= 1'b0;
    	end
		else if( PSW_SIG[3] == 1'b1 )begin
      		PLUS_A  <= 1'b0;
			MINUS_A <= 1'b1;
		end
		else begin
			PLUS_A  <= 1'b0;
			MINUS_A <= 1'b0;
		end
	end
	
//-------------------------------------
//  OUTPUT COUNT_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_A <= 4'd0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
  			COUNT_A <= 4'd0;
		end

		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( PLUS_A == 1'b1 )begin
				if( COUNT_A >= 4'd9 )begin
					COUNT_A <= 4'd0;
				end
				else begin
					COUNT_A <= COUNT_A + 4'd1;
				end
			end
			else if( MINUS_A == 1'b1 )begin
				if( COUNT_A <= 4'd0 )begin
					COUNT_A <= 4'd9;
				end
				else begin
					COUNT_A <= COUNT_A - 4'd1;
				end
			end
			else begin
				COUNT_A <= COUNT_A;
			end
		end
		
		// Moving Mode
		else begin
			if( SEC_SIG == 1'b1 )begin
				if( COUNT_A >= 4'd9 )begin
					COUNT_A <= 4'd0;
				end
				else begin
					COUNT_A <= COUNT_A + 4'd1;
				end
			end
			else begin
				COUNT_A <= COUNT_A;
			end
		end
	end

//-------------------------------------
//  OUTPUT CARRY_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			CARRY_A <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
  			CARRY_A <= 1'b0;
		end

		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( PLUS_A == 1'b1 )begin
				if( COUNT_A >= 4'd9 )begin
					CARRY_A <= 1'b1;
				end
				else begin
					CARRY_A <= 1'b0;
				end
			end
			else begin
				CARRY_A <= 1'b0;
			end
		end

		// Moving Mode
		else begin
			if( SEC_SIG == 1'b1 )begin
				if( COUNT_A >= 4'd9 )begin
					CARRY_A <= 1'b1;
				end
				else begin
					CARRY_A <= 1'b0;
				end
			end
			else begin
				CARRY_A <= 1'b0;
			end
		end
	end

//-------------------------------------
//   OUTPUT DOWN_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			DOWN_A <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
  			DOWN_A <= 1'b0;
		end

		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( MINUS_A == 1'b1 )begin
				if( COUNT_A <= 4'd0 )begin
					DOWN_A <= 1'b1;
				end
				else begin
					DOWN_A <= 1'b0;
				end
			end
			else begin
				DOWN_A <= 1'b0;
			end
		end
		
		// Moving Mode
		else begin
			DOWN_A <= 1'b0;
		end
	end

//-------------------------------------
//   OUTPUT COUNT_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_B <= 4'd0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			COUNT_B <= 4'd0;
		end

		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( CARRY_A == 1'b1 )begin
				if( COUNT_B >= 4'd9 )begin
					COUNT_B <= 4'd0;
				end
				else begin
					COUNT_B <= COUNT_B + 4'd1;
				end
			end
			else if( DOWN_A == 1'b1 )begin
				if( COUNT_B <= 4'd0 )begin
					COUNT_B <= 4'd9;
				end
				else begin
					COUNT_B <= COUNT_B - 4'd1;
				end
			end
			else begin
				COUNT_B <= COUNT_B;
			end
		end
		
		// Moving mode
		else begin							
			if( SEC_SIG_1D == 1'b1 )begin
				if( CARRY_A == 1'b1 )begin
					if( COUNT_B >= 4'd9 )begin
						COUNT_B <= 1'b0;
					end
					else begin
						COUNT_B <= COUNT_B + 4'd1;
					end
				end
				else begin
					COUNT_B <= COUNT_B;
				end
			end
			else begin
				COUNT_B <= COUNT_B;
			end
		end
	end


//-------------------------------------
//   OUTPUT CARRY_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			CARRY_B <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			CARRY_B <= 1'b0;
		end
		
		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( CARRY_A == 1'b1)begin
				if( COUNT_B >= 4'd9 )begin
						CARRY_B <= 1'b1;
				end
				else begin
					CARRY_B <= 1'b0;
				end
			end
			else begin
				CARRY_B <= 1'b0;
			end
		end

		// Moving Mode
		else begin
			if( SEC_SIG_1D == 1'b1 )begin
				if( CARRY_A == 1'b1 )begin
					if( COUNT_B >= 4'd9 )begin
						CARRY_B <= 1'b1;
					end
					else begin
						CARRY_B <= 1'b0;
					end
				end
				else begin
					CARRY_B <= 1'b0;
				end
			end
			else begin
				CARRY_B <= 1'b0;
			end
		end
	end

//-------------------------------------
//   OUTPUT DOWN_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			DOWN_B <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			DOWN_B <= 1'b0;
		end
		
		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( DOWN_A == 1'b1 )begin
				if( COUNT_B <= 4'd0 )begin
					DOWN_B <= 1'b1;
				end
				else begin
					DOWN_B <= 1'b0;
				end
			end
			else begin
				DOWN_B <= 1'b0;
			end
		end
		
		// Moving Mode
		else begin
			DOWN_B <= 1'b0;
		end
	end

//-------------------------------------
//   OUTPUT COUNT_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_C <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			COUNT_C <= 4'd0;
		end

		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( CARRY_B == 1'b1 )begin
				if( COUNT_C >= 4'd9 )begin
					COUNT_C <= 4'd0;
				end
				else begin
					COUNT_C <= COUNT_C + 4'd1;
				end
			end
			else if( DOWN_B == 1'b1 )begin
				if( COUNT_C <= 4'd0 )begin
					COUNT_C <= 4'd9;
				end
				else begin
					COUNT_C <= COUNT_C - 4'd1;
				end
			end
			else begin
				COUNT_C <= COUNT_C;
			end
		end
		
		// Moving mode
		else begin
			if( SEC_SIG_2D == 1'b1 )begin
				if( CARRY_B == 1'b1 )begin
					if( COUNT_C >= 4'd9 )begin
						COUNT_C <= 1'b0;
					end
					else begin
						COUNT_C <= COUNT_C + 4'd1;
					end
				end
				else begin
					COUNT_C <= COUNT_C;
				end
			end
			else begin
				COUNT_C <= COUNT_C;
			end
		end
	end

//-------------------------------------
//   OUTPUT CARRY_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			CARRY_C <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			CARRY_C <= 1'b0;
		end
		
		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( CARRY_B == 1'b1)begin
				if( COUNT_C >= 4'd9 )begin
						CARRY_C <= 1'b1;
				end
				else begin
					CARRY_C <= 1'b0;
				end
			end
			else begin
				CARRY_C <= 1'b0;
			end
		end
		
		// Moving Mode
		else begin
			if( SEC_SIG_2D == 1'b1 )begin
				if( CARRY_B == 1'b1 )begin
					if( COUNT_C >= 4'd9 )begin
						CARRY_C <= 1'b1;
					end
					else begin
						CARRY_C <= 1'b0;
					end
				end
				else begin
					CARRY_C <= 1'b0;
				end
			end
			else begin
				CARRY_C <= 1'b0;
			end
		end
	end

//-------------------------------------
//   OUTPUT DOWN_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			DOWN_C <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			DOWN_C <= 1'b0;
		end
		
		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( DOWN_B == 1'b1 )begin
				if( COUNT_C <= 4'd0 )begin
					DOWN_C <= 1'b1;
				end
				else begin
					DOWN_C <= 1'b0;
				end
			end
			else begin
				DOWN_C <= 1'b0;
			end
		end
		
		// Moving Mode
		else begin
			DOWN_C <= 1'b0;
		end
	end

//-------------------------------------
//   OUTPUT COUNT_D
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
 		if( !RSTN )begin
			COUNT_D <= 4'd0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			COUNT_D <= 4'd0;
		end
		
		// Stop Mode
		else if( MOVE_FLG == 1'b0 )begin
			if( CARRY_C == 1'b1 )begin
				if( COUNT_D >= 4'd9 )begin
					COUNT_D <= 4'd0;
				end
				else begin
					COUNT_D <= COUNT_D + 4'd1;
				end
			end
			else if( DOWN_C == 1'b1 )begin
				if( COUNT_D <= 1'b0 )begin
					COUNT_D <= 4'd9;
				end
				else begin
					COUNT_D <= COUNT_D - 4'd1;
				end
			end
			else begin
				COUNT_D <= COUNT_D;
			end
		end

		// Moving Mode
		else begin
			if( SEC_SIG_3D == 1'b1 )begin
				if( CARRY_C == 1'b1 )begin
					if( COUNT_D >= 4'd9 )begin
						COUNT_D <= 4'd0;
					end
					else begin
						COUNT_D <= COUNT_D + 4'd1;
					end
				end
				else begin
					COUNT_D <= COUNT_D;
				end
			end
			else begin
				COUNT_D <= COUNT_D;
			end
		end
	end



//-------------------------------------
//   Delay Control COUNT_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_A_1D <= 4'd0;
			COUNT_A_2D <= 4'd0;
			COUNT_A_3D <= 4'd0;
		end
		else if( PSW_SIG[1] == 1'b1 )begin
			COUNT_A_1D <= 4'd0;
			COUNT_A_2D <= 4'd0;
			COUNT_A_3D <= 4'd0;
		end
		else begin
			COUNT_A_1D <= COUNT_A;
			COUNT_A_2D <= COUNT_A_1D;
			COUNT_A_3D <= COUNT_A_2D;
		end
	end

//-------------------------------------
//   Delay Control COUNT_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_B_1D <= 4'd0;
			COUNT_B_2D <= 4'd0;
		end
		else if( PSW_SIG[1] == 1'b1)begin
			COUNT_B_1D <= 4'd0;
			COUNT_B_2D <= 4'd0;
		end
		else begin
			COUNT_B_1D <= COUNT_B;
			COUNT_B_2D <= COUNT_B_1D;
		end
	end

//-------------------------------------
//   Delay Control COUNT_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_C_1D <= 4'd0;
		end
		else if( PSW_SIG[1] == 1'b1)begin
			COUNT_C_1D <= 4'd0;
		end
		else begin
			COUNT_C_1D <= COUNT_C;
		end
	end

//-------------------------------------
//   Delay Control SEC_SIG
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			SEC_SIG_1D <= 1'b0;
			SEC_SIG_2D <= 1'b0;
			SEC_SIG_3D <= 1'b0;
		end
		else if( PSW_SIG[1] == 1'b1)begin
			SEC_SIG_1D <= 1'b0;
			SEC_SIG_2D <= 1'b0;
			SEC_SIG_3D <= 1'b0;
		end
		else begin
			SEC_SIG_1D <= SEC_SIG;
			SEC_SIG_2D <= SEC_SIG_1D;
			SEC_SIG_3D <= SEC_SIG_2D;
		end
	end

assign SEG_D_VAL = COUNT_A_3D;
assign SEG_C_VAL = COUNT_B_2D;
assign SEG_B_VAL = COUNT_C_1D;
assign SEG_A_VAL = COUNT_D;

endmodule
