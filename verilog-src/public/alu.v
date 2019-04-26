
// @file alu.v
// @breif RISC-V 用 ALU モジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// RISC-V の ALU
//
// [入出力]
// in1:   入力１(32ビット)
// in2:   入力２(32ビット)
// ctl:   機能コード(4ビット)
// out:   出力(32ビット)
module alu(input [31:0]      in1,
	   input [31:0]      in2,
	   input [ 3:0]      ctl,
	   output reg [31:0] out);

   // ALU の機能コード
   parameter [3:0] ALU_LUI = 4'b0000;
   parameter [3:0] ALU_EQ  = 4'b0010;
   parameter [3:0] ALU_NE  = 4'b0011;
   parameter [3:0] ALU_LT  = 4'b0100;
   parameter [3:0] ALU_GE  = 4'b0101;
   parameter [3:0] ALU_LTU = 4'b0110;
   parameter [3:0] ALU_GEU = 4'b0111;
   parameter [3:0] ALU_ADD = 4'b1000;
   parameter [3:0] ALU_SUB = 4'b1001;
   parameter [3:0] ALU_XOR = 4'b1010;
   parameter [3:0] ALU_OR  = 4'b1011;
   parameter [3:0] ALU_AND = 4'b1100;
   parameter [3:0] ALU_SLL = 4'b1101;
   parameter [3:0] ALU_SRL = 4'b1110;
   parameter [3:0] ALU_SRA = 4'b1111;

   // 符号付き演算のための別名
   wire signed [31:0] 	 sin1 = in1;
   wire signed [31:0] 	 sin2 = in2;

   always @ ( * ) begin
      case ( ctl )
	ALU_LUI: out = in2;
	ALU_EQ:  out = (in1 == in2) ?  32'b1 : 32'b0;
	ALU_NE:  out = (in1 == in2) ?  32'b0 : 32'b1;
	ALU_LT:  out = (sin1 < sin2) ? 32'b1 : 32'b0;
	ALU_GE:  out = (sin1 < sin2) ? 32'b0 : 32'b1;
	ALU_LTU: out = (in1 < in2) ?   32'b1 : 32'b0;
	ALU_GEU: out = (in1 < in2) ?   32'b0 : 32'b1;
	ALU_ADD: out = sin1 + sin2;
	ALU_SUB: out = sin1 - sin2;
	ALU_XOR: out = in1 ^ in2;
	ALU_OR:  out = in1 | in2;
	ALU_AND: out = in1 & in2;
	ALU_SLL: out = in1 << in2;
	ALU_SRL: out = in1 >> in2;
	ALU_SRA: out = sin1 >>> in2;
	default: out = in2;
      endcase // case ( ctl )
   end
endmodule // alu
