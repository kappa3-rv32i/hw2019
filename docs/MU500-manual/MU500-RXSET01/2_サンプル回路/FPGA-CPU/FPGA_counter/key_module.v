/*------------------------------------------------------------------------------
--      File Name = key_module.v                                              --
--                                                                            --
--      Design    = Key Module                                                --
--                                                                            --
--      Revision  = 1.0         Date: 2012.3.22                               --
------------------------------------------------------------------------------*/  

module key_module(
 //input
 CLK, RSTN,
 PSW_1D,

 //output
 PSW_SIG
);

//------ input ------------------------------------------------
input  CLK, RSTN, PSW_1D;

//------ output -----------------------------------------------
output PSW_SIG;

//------ reg --------------------------------------------------
reg  PSW_2D;
reg  [1:0] PSW_DIFF;
reg  [18:0] PSW_COUNT;


wire  PSW_SIG;

	always@( posedge CLK or negedge RSTN) begin
		if( !RSTN )begin
    		PSW_2D <= 1'b0;
		end
		else begin
    		PSW_2D <= PSW_1D;
		end
	end

      assign  PSW_SIG = ~PSW_1D & PSW_2D  ;

endmodule
