/*------------------------------------------------------------------------------
--      File Name = watch_body.v                                              --
--                                                                            --
--      Design    = StopWatch Main Block                                      --
--                                                                            --
--      Revision  = 1.0         Date: 2012.03.22                              --
------------------------------------------------------------------------------*/   

module watch_body (
  	//input
  	CLK,
  	RSTN,
  	RST_PULS,
	INC_PULS,
	DEC_PULS,

  	//output
  	SEG_A_VAL,
	SEG_B_VAL,
	SEG_C_VAL,
	SEG_D_VAL
);

//--- input --------------------------------------------------------------------
input  CLK;			// Clock 20MHz
input  RSTN;			// System Reset
input  RST_PULS;		// Reset Signal
input  INC_PULS;		// Increment Signal
input  DEC_PULS;		// Decrement Signal

//--- output -------------------------------------------------------------------
output [3:0] SEG_A_VAL,SEG_B_VAL,SEG_C_VAL,SEG_D_VAL;	// 7seg out

//--- reg ----------------------------------------------------------------------
reg  [3:0] COUNT_A, COUNT_B, COUNT_C, COUNT_D;				// Count Register
reg  CARRY_A, CARRY_B, CARRY_C;								// Carry Up Signal
reg  DOWN_A,  DOWN_B,  DOWN_C;								// Carry Down Signal

reg  [3:0] COUNT_A_1D, COUNT_A_2D,COUNT_A_3D;				// Delay Adjustment COUNT_A
reg  [3:0] COUNT_B_1D, COUNT_B_2D;							// Delay Adjustment COUNT_B
reg  [3:0] COUNT_C_1D;										// Delay Adjustment COUNT_C

//****************************** Start of Module ******************************
//-------------------------------------
//  OUTPUT COUNT_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_A <= 4'd0;
		end
		else if( RST_PULS == 1'b1 )begin
  			COUNT_A <= 4'd0;
		end

		else if( INC_PULS == 1'b1 )begin
			if( COUNT_A >= 4'd9 )begin
				COUNT_A <= 4'd0;
			end
			else begin
				COUNT_A <= COUNT_A + 4'd1;
			end
		end
		else if( DEC_PULS == 1'b1 )begin
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
 
//-------------------------------------
//  OUTPUT CARRY_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			CARRY_A <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
  			CARRY_A <= 1'b0;
		end

		else if( INC_PULS == 1'b1 )begin
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

//-------------------------------------
//   OUTPUT DOWN_A
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			DOWN_A <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
  			DOWN_A <= 1'b0;
		end

		else if( DEC_PULS == 1'b1 )begin
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

//-------------------------------------
//   OUTPUT COUNT_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_B <= 4'd0;
		end
		else if( RST_PULS == 1'b1 )begin
			COUNT_B <= 4'd0;
		end

		else if( CARRY_A == 1'b1 )begin
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

//-------------------------------------
//   OUTPUT CARRY_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			CARRY_B <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
			CARRY_B <= 1'b0;
		end
		else if( CARRY_A == 1'b1)begin
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

//-------------------------------------
//   OUTPUT DOWN_B
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			DOWN_B <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
			DOWN_B <= 1'b0;
		end
		
		else if( DOWN_A == 1'b1 )begin
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

//-------------------------------------
//   OUTPUT COUNT_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_C <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
			COUNT_C <= 4'd0;
		end

		else if( CARRY_B == 1'b1 )begin
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

//-------------------------------------
//   OUTPUT CARRY_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			CARRY_C <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
			CARRY_C <= 1'b0;
		end
		
		else if( CARRY_B == 1'b1)begin
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

//-------------------------------------
//   OUTPUT DOWN_C
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			DOWN_C <= 1'b0;
		end
		else if( RST_PULS == 1'b1 )begin
			DOWN_C <= 1'b0;
		end	
		else if( DOWN_B == 1'b1 )begin
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
		
//-------------------------------------
//   OUTPUT COUNT_D
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
 		if( !RSTN )begin
			COUNT_D <= 4'd0;
		end
		else if( RST_PULS == 1'b1 )begin
			COUNT_D <= 4'd0;
		end
		
		else if( CARRY_C == 1'b1 )begin
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

//-------------------------------------
//   Delay Adjustment
//-------------------------------------
	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_A_1D <= 4'd0;
			COUNT_A_2D <= 4'd0;
			COUNT_A_3D <= 4'd0;
		end
		else if( RST_PULS == 1'b1 )begin
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

	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_B_1D <= 4'd0;
			COUNT_B_2D <= 4'd0;
		end
		else if( RST_PULS == 1'b1)begin
			COUNT_B_1D <= 4'd0;
			COUNT_B_2D <= 4'd0;
		end
		else begin
			COUNT_B_1D <= COUNT_B;
			COUNT_B_2D <= COUNT_B_1D;
		end
	end

	always@( posedge CLK or negedge RSTN) begin
  		if( !RSTN )begin
			COUNT_C_1D <= 4'd0;
		end
		else if( RST_PULS == 1'b1)begin
			COUNT_C_1D <= 4'd0;
		end
		else begin
			COUNT_C_1D <= COUNT_C;
		end
	end

assign SEG_D_VAL = COUNT_A_3D;
assign SEG_C_VAL = COUNT_B_2D;
assign SEG_B_VAL = COUNT_C_1D;
assign SEG_A_VAL = COUNT_D;

endmodule
