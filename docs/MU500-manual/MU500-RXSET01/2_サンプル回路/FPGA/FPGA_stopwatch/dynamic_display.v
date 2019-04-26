/*------------------------------------------------------------------------------
--      File Name = dynamic_display.v                                         --
--                                                                            --
--      Design    = 7SEG dynamic Dispaly                                      --
--                                                                            --
--      Revision  = 1.0         Date: 2012.5.8                                --
------------------------------------------------------------------------------*/
module	dynamic_display(
		// input
		CLK,
		RSTN,
		SEG_A_0,
		SEG_B_0,
		SEG_C_0,
		SEG_D_0,

		// output
		SEG_A,
		SEG_SEL
	);


parameter DEF_COUNT   = 28'h3000;

// ------ input --------------------------------------------
input	CLK;					// System Clock
input	RSTN;					// System Reset
input	[7:0] SEG_A_0,SEG_B_0,SEG_C_0,SEG_D_0;	// 7SEG Value

// ------ output -------------------------------------------
output	[7:0] SEG_A;				// 7SEG Display
output	[3:0] SEG_SEL;				//

// ------ wire ----------------------------------------------
reg	[7:0] SEG_A,SEG_B,SEG_C,SEG_D;		// 7SEG Display Wire


//--- reg ----------------------------------------------------------------------
reg	[27:0] SEC_COUNT;
reg	[3:0]  GATE;
reg	SEC_SIG;

wire	[3:0] SEG_SEL;


	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
			SEC_COUNT <= 28'd0;
		end
		else if( SEC_COUNT >= DEF_COUNT - 28'd1)begin
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
		else if( SEC_COUNT >= DEF_COUNT - 28'd1 )begin
			SEC_SIG <= 1'b1;
		end
		else begin
			SEC_SIG <= 1'b0;
		end
	end

	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
			GATE <= 4'b0001;
		end
		else if( SEC_SIG == 1'b1 )begin
			GATE[0] <= GATE[3];
			GATE[1] <= GATE[0];
			GATE[2] <= GATE[1];
			GATE[3] <= GATE[2];
		end
		else begin
			GATE <= GATE;
		end
	end

	always@( posedge CLK or negedge RSTN ) begin
		if( !RSTN )begin
			SEG_A <= 8'd0;
		end
		else begin
			case( GATE )
				4'd1: begin
					SEG_A <= SEG_A_0;
				end
				4'd2: begin
					SEG_A <= SEG_B_0;
				end
				4'd4: begin
					SEG_A <= SEG_C_0;
				end
				4'd8: begin
					SEG_A <= SEG_D_0;
				end
				default: begin
					SEG_A <= 8'd0;
				end
			endcase
		end
	end

assign	SEG_SEL = ~GATE;

endmodule
