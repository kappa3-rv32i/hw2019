
// @file regfile.v
// @breif 32ビット x 32個のレジスタファイル
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * 32 ビットのレジスタを31個持つ(x1, x2, ..., x30, x31)
// * 読み出しは２ポート(rs1, rs2)あり，それぞれ独立にアクセス可能
// * 書き込みは1ポート(rd)
// * それぞれのポートにアクセスするためにはアドレス(5ビット)をセットする．
// * レジスタのアドレス(番号)0は特殊で読み出すと 32'h0 を返す．
//   書き込みは無視される．JAL 命令などでどのレジスタにも内容を
//   書き込みたくない場合に使用される．
// * 読み出しは随時可．
// * reset が 0 になったら全てのレジスタの内容を 32'h0 にする．
// * 通常の書き込みは dbg_modeを0かつld信号を1にする．
// * dbg_mode が 1かつdbg_ld が 1 の時，dbg_addr で指定されたレジスタに
//   dbg_in の値を書き込む．
// * dbg_out には常に dbg_addr で指定されたレジスタの内容が出力される．
//
// [入出力]
// clock:    クロック信号(立ち上がりエッジ)
// reset:    リセット信号(0でリセット)
// rs1_addr: rs1 のアドレス(5ビット)
// rs2_addr: rs2 のアドレス(5ビット)
// rd_addr:  rd のアドレス(5ビット)
// in:       書き込みデータ(32ビット)
// ld:       書き込み信号
// rs1_out:  rs1 の読み出しデータ(32ビット)
// rs2_out:  rs2 の読み出しデータ(32ビット)
// dbg_mode: デバックモード
// dbg_in:   デバッグ用書き込みデータ
// dbg_addr: デバッグ用アドレス(5ビット)
// dbg_ld:   デバッグ用書き込み信号
// dbg_out:  デバッグ用読み出しデータ
module regfile(input 	     clock,
	       input 	     reset,

	       input [4:0]   rs1_addr,
	       input [4:0]   rs2_addr,
	       input [4:0]   rd_addr,

	       input [31:0]  in,
	       input 	     ld,

	       output [31:0] rs1_out,
	       output [31:0] rs2_out,

	       // デバッグ関係
	       input 	     dbg_mode,
	       input [31:0]  dbg_in,
	       input [4:0]   dbg_addr,
	       input 	     dbg_ld,
	       output [31:0] dbg_out);

   // レジスタファイルの本体
   reg [31:0] reg01;
   reg [31:0] reg02;
   reg [31:0] reg03;
   reg [31:0] reg04;
   reg [31:0] reg05;
   reg [31:0] reg06;
   reg [31:0] reg07;
   reg [31:0] reg08;
   reg [31:0] reg09;
   reg [31:0] reg10;
   reg [31:0] reg11;
   reg [31:0] reg12;
   reg [31:0] reg13;
   reg [31:0] reg14;
   reg [31:0] reg15;
   reg [31:0] reg16;
   reg [31:0] reg17;
   reg [31:0] reg18;
   reg [31:0] reg19;
   reg [31:0] reg20;
   reg [31:0] reg21;
   reg [31:0] reg22;
   reg [31:0] reg23;
   reg [31:0] reg24;
   reg [31:0] reg25;
   reg [31:0] reg26;
   reg [31:0] reg27;
   reg [31:0] reg28;
   reg [31:0] reg29;
   reg [31:0] reg30;
   reg [31:0] reg31;

   // レジスタの値を読み出す関数
   function [31:0] select_reg(input [4:0] addr,
			      input [31:0] reg01,
			      input [31:0] reg02,
			      input [31:0] reg03,
			      input [31:0] reg04,
			      input [31:0] reg05,
			      input [31:0] reg06,
			      input [31:0] reg07,
			      input [31:0] reg08,
			      input [31:0] reg09,
			      input [31:0] reg10,
			      input [31:0] reg11,
			      input [31:0] reg12,
			      input [31:0] reg13,
			      input [31:0] reg14,
			      input [31:0] reg15,
			      input [31:0] reg16,
			      input [31:0] reg17,
			      input [31:0] reg18,
			      input [31:0] reg19,
			      input [31:0] reg20,
			      input [31:0] reg21,
			      input [31:0] reg22,
			      input [31:0] reg23,
			      input [31:0] reg24,
			      input [31:0] reg25,
			      input [31:0] reg26,
			      input [31:0] reg27,
			      input [31:0] reg28,
			      input [31:0] reg29,
			      input [31:0] reg30,
			      input [31:0] reg31);
      begin
	 case ( addr )
	   0:  select_reg = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	   1:  select_reg = reg01;
	   2:  select_reg = reg02;
	   3:  select_reg = reg03;
	   4:  select_reg = reg04;
	   5:  select_reg = reg05;
	   6:  select_reg = reg06;
	   7:  select_reg = reg07;
	   8:  select_reg = reg08;
	   9:  select_reg = reg09;
	   10: select_reg = reg10;
	   11: select_reg = reg11;
	   12: select_reg = reg12;
	   13: select_reg = reg13;
	   14: select_reg = reg14;
	   15: select_reg = reg15;
	   16: select_reg = reg16;
	   17: select_reg = reg17;
	   18: select_reg = reg18;
	   19: select_reg = reg19;
	   20: select_reg = reg20;
	   21: select_reg = reg21;
	   22: select_reg = reg22;
	   23: select_reg = reg23;
	   24: select_reg = reg24;
	   25: select_reg = reg25;
	   26: select_reg = reg26;
	   27: select_reg = reg27;
	   28: select_reg = reg28;
	   29: select_reg = reg29;
	   30: select_reg = reg30;
	   31: select_reg = reg31;
	 endcase // case ( addr )
      end
   endfunction // select_reg

   // 各レジスタの書き込みを行う．
   always @ ( negedge reset or posedge clock ) begin
      if ( !reset ) begin
	 reg01 <= 32'h0;
	 reg02 <= 32'h0;
	 reg03 <= 32'h0;
	 reg04 <= 32'h0;
	 reg05 <= 32'h0;
	 reg06 <= 32'h0;
	 reg07 <= 32'h0;
	 reg08 <= 32'h0;
	 reg09 <= 32'h0;
	 reg10 <= 32'h0;
	 reg11 <= 32'h0;
	 reg12 <= 32'h0;
	 reg13 <= 32'h0;
	 reg14 <= 32'h0;
	 reg15 <= 32'h0;
	 reg16 <= 32'h0;
	 reg17 <= 32'h0;
	 reg18 <= 32'h0;
	 reg19 <= 32'h0;
	 reg20 <= 32'h0;
	 reg21 <= 32'h0;
	 reg22 <= 32'h0;
	 reg23 <= 32'h0;
	 reg24 <= 32'h0;
	 reg25 <= 32'h0;
	 reg26 <= 32'h0;
	 reg27 <= 32'h0;
	 reg28 <= 32'h0;
	 reg29 <= 32'h0;
	 reg30 <= 32'h0;
	 reg31 <= 32'h0;
      end
      else if ( dbg_mode && dbg_ld ) begin
	 case ( dbg_addr )
	   0:  ; // なにもしない
	   1:  reg01 <= dbg_in;
	   2:  reg02 <= dbg_in;
	   3:  reg03 <= dbg_in;
	   4:  reg04 <= dbg_in;
	   5:  reg05 <= dbg_in;
	   6:  reg06 <= dbg_in;
	   7:  reg07 <= dbg_in;
	   8:  reg08 <= dbg_in;
	   9:  reg09 <= dbg_in;
	   10: reg10 <= dbg_in;
	   11: reg11 <= dbg_in;
	   12: reg12 <= dbg_in;
	   13: reg13 <= dbg_in;
	   14: reg14 <= dbg_in;
	   15: reg15 <= dbg_in;
	   16: reg16 <= dbg_in;
	   17: reg17 <= dbg_in;
	   18: reg18 <= dbg_in;
	   19: reg19 <= dbg_in;
	   20: reg20 <= dbg_in;
	   21: reg21 <= dbg_in;
	   22: reg22 <= dbg_in;
	   23: reg23 <= dbg_in;
	   24: reg24 <= dbg_in;
	   25: reg25 <= dbg_in;
	   26: reg26 <= dbg_in;
	   27: reg27 <= dbg_in;
	   28: reg28 <= dbg_in;
	   29: reg29 <= dbg_in;
	   30: reg30 <= dbg_in;
	   31: reg31 <= dbg_in;
	 endcase // case ( dbg_addr )
      end
      else if ( !dbg_mode && ld ) begin
	 case ( rd_addr )
	   0:  ; // なにもしない
	   1:  reg01 <= in;
	   2:  reg02 <= in;
	   3:  reg03 <= in;
	   4:  reg04 <= in;
	   5:  reg05 <= in;
	   6:  reg06 <= in;
	   7:  reg07 <= in;
	   8:  reg08 <= in;
	   9:  reg09 <= in;
	   10: reg10 <= in;
	   11: reg11 <= in;
	   12: reg12 <= in;
	   13: reg13 <= in;
	   14: reg14 <= in;
	   15: reg15 <= in;
	   16: reg16 <= in;
	   17: reg17 <= in;
	   18: reg18 <= in;
	   19: reg19 <= in;
	   20: reg20 <= in;
	   21: reg21 <= in;
	   22: reg22 <= in;
	   23: reg23 <= in;
	   24: reg24 <= in;
	   25: reg25 <= in;
	   26: reg26 <= in;
	   27: reg27 <= in;
	   28: reg28 <= in;
	   29: reg29 <= in;
	   30: reg30 <= in;
	   31: reg31 <= in;
	 endcase // case ( rd_addr )
      end
   end

   assign rs1_out = select_reg(rs1_addr,
			       reg01, reg02, reg03, reg04, reg05, reg06, reg07,
			       reg08, reg09, reg10, reg11, reg12, reg13, reg14,
			       reg15, reg16, reg17, reg18, reg19, reg20, reg21,
			       reg22, reg23, reg24, reg25, reg26, reg27, reg28,
			       reg29, reg30, reg31);

   assign rs2_out = select_reg(rs2_addr,
			       reg01, reg02, reg03, reg04, reg05, reg06, reg07,
			       reg08, reg09, reg10, reg11, reg12, reg13, reg14,
			       reg15, reg16, reg17, reg18, reg19, reg20, reg21,
			       reg22, reg23, reg24, reg25, reg26, reg27, reg28,
			       reg29, reg30, reg31);

   assign dbg_out = select_reg(dbg_addr,
			       reg01, reg02, reg03, reg04, reg05, reg06, reg07,
			       reg08, reg09, reg10, reg11, reg12, reg13, reg14,
			       reg15, reg16, reg17, reg18, reg19, reg20, reg21,
			       reg22, reg23, reg24, reg25, reg26, reg27, reg28,
			       reg29, reg30, reg31);

endmodule // regfile
