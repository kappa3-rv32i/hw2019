
// @file debugger.v
// @breif デバッグ用モジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * HEX_A, HEX_B の値に従って 7SEG-LED にレジスタ・メモリの値を表示する．
// * HEX_A, HEX_B の値に従って入力バッファの値をレジスタ・メモリに設定する．
// * メモリアドレスの指定用に MAR レジスタを持つ．
//
// HEX_A, HEX_B
//     0,     - | PC
//     1,     - | IR
//     2,     - | A
//     3,     - | B
//     4,     - | C
//     5,     - | 未使用
//     6,     d | reg[d]
//     7,     d | reg[d + 16]
//     8,     - | MAR
//     9,     - | memory
//
// [入出力]
// sys_clock:  システムクロック
// reset:      リセット
// clock:      クロック
// input_val:  入力された値
// button1:    psw_b4 が押された時に1になる信号
// button2:    psw_c4 が押された時に1になる信号
// button3:    psw_d4 が押された時に1になる信号
// run:        run 信号
// step_phase: step_phase 信号
// step_inst:  step_inst 信号
// hex_a:      ロータリースイッチA
// hex_b:      ロータリースイッチB
// dip_a:      DIPスイッチA
// dip_b:      DIPスイッチB
// pc_out:     PCの値
// pc_ld:      PCのデバッグ用書き込みイネーブル
// ir_out:     IRの値
// ir_ld:      IRのデバッグ用書き込みイネーブル
// reg_out:    レジスタファイルの値
// reg_addr:   レジスタファイルのデバッグ用アドレス
// reg_ld:     レジスタファイルのデバッグ用書き込みイネーブル
// a_out:      Aレジスタの値
// a_ld:       Aレジスタの書き込みイネーブル
// b_out:      Bレジスタの値
// b_ld:       Bレジスタの書き込みイネーブル
// c_out:      Cレジスタの値
// c_ld:       Cレジスタの書き込みイネーブル
// mem_addr:   メモリアドレス
// mem_out:    メモリから読み出した値
// mem_read:   メモリの読み出しイネーブル
// mem_write:  メモリの書き込みイネーブル
// seg7_a:     MU500-7SEGボードのAグループのセグメント(8ビット x 8個)
// seg7_b:     MU500-7SEGボードのBグループのセグメント(8ビット x 8個)
// seg7_c:     MU500-7SEGボードのCグループのセグメント(8ビット x 8個)
// seg7_d:     MU500-7SEGボードのDグループのセグメント(8ビット x 8個)
// seg7_e:     MU500-7SEGボードのEグループのセグメント(8ビット x 8個)
// seg7_f:     MU500-7SEGボードのFグループのセグメント(8ビット x 8個)
// seg7_g:     MU500-7SEGボードのGグループのセグメント(8ビット x 8個)
// seg7_h:     MU500-7SEGボードのHグループのセグメント(8ビット x 8個)
module debugger(input         sys_clock,
		input 	      reset,
		input 	      clock,
		input [31:0]  input_val,
		input 	      button1,
		input 	      button2,
		input 	      button3,
		output 	      run,
		output 	      step_phase,
		output 	      step_inst,
		input [3:0]   cstate,
		input 	      running,
		input [3:0]   hex_a,
		input [3:0]   hex_b,
		input [7:0]   dip_a,
		input [7:0]   dip_b,
		input [31:0]  pc_out,
		output 	      pc_ld,
		input [31:0]  ir_out,
		output 	      ir_ld,
		input [31:0]  reg_out,
		output [4:0]  reg_addr,
		output 	      reg_ld,
		input [31:0]  a_out,
		output 	      a_ld,
		input [31:0]  b_out,
		output 	      b_ld,
		input [31:0]  c_out,
		output 	      c_ld,
		output [31:0] mem_addr,
		input [31:0]  mem_out,
		output [31:0] mem_read,
		output [31:0] mem_write,
		output [63:0] seg7_a,
		output [63:0] seg7_b,
		output [63:0] seg7_c,
		output [63:0] seg7_d,
		output [63:0] seg7_e,
		output [63:0] seg7_f,
		output [63:0] seg7_g,
		output [63:0] seg7_h,
		output [7:0]  led_out);

   // 'P' のパタン
   parameter [7:0] PAT_P = 8'b1100_1110;
   // 'c' のパタン
   parameter [7:0] PAT_C = 8'b0001_1010;
   // 'I' のパタン
   parameter [7:0] PAT_I = 8'b0110_0000;
   // 'r' のパタン
   parameter [7:0] PAT_R = 8'b0000_1010;
   // 'a' のパタン
   parameter [7:0] PAT_A = 8'b1111_1010;
   // 'b' のパタン
   parameter [7:0] PAT_B = 8'b0011_1110;
   // 'n' のパタン
   parameter [7:0] PAT_N = 8'b0010_1010;
   // 'd' のパタン
   parameter [7:0] PAT_D = 8'b0111_1010;
   // '0' のパタン
   parameter [7:0] PAT_0 = 8'b1111_1100;
   // '1' のパタン
   parameter [7:0] PAT_1 = 8'b0110_0000;
   // '2' のパタン
   parameter [7:0] PAT_2 = 8'b1101_1010;
   // '3' のパタン
   parameter [7:0] PAT_3 = 8'b1111_0010;
   // '4' のパタン
   parameter [7:0] PAT_4 = 8'b0110_0110;
   // '5' のパタン
   parameter [7:0] PAT_5 = 8'b1011_0110;
   // '6' のパタン
   parameter [7:0] PAT_6 = 8'b1011_1110;
   // '7' のパタン
   parameter [7:0] PAT_7 = 8'b1110_0000;
   // '8' のパタン
   parameter [7:0] PAT_8 = 8'b1111_1110;
   // '9' のパタン
   parameter [7:0] PAT_9 = 8'b1110_0110;

   // PCのパタン
   parameter [63:0] PAT_PC = {32'b0, PAT_P, PAT_C, 16'b0};

   // IRのパタン
   parameter [63:0] PAT_IR = {32'b0, PAT_I, PAT_R, 16'b0};

   // aのパタン
   parameter [63:0] PAT_AREG = {32'b0, PAT_A, 24'b0};

   // bのパタン
   parameter [63:0] PAT_BREG = {32'b0, PAT_B, 24'b0};

   // cのパタン
   parameter [63:0] PAT_CREG = {32'b0, PAT_C, 24'b0};

   // MARのパタン
   parameter [63:0] PAT_MAR = {32'b0, PAT_N, PAT_N, PAT_A, PAT_R};

   // MEMのパタン
   parameter [63:0] PAT_MEM = {32'b0, PAT_N, PAT_N, PAT_D, PAT_R};

   // R00 のパタン
   parameter [63:0] PAT_R00 = {32'b0, PAT_R, PAT_0, PAT_0, 8'b0};

   // R01 のパタン
   parameter [63:0] PAT_R01 = {32'b0, PAT_R, PAT_0, PAT_1, 8'b0};

   // R02 のパタン
   parameter [63:0] PAT_R02 = {32'b0, PAT_R, PAT_0, PAT_2, 8'b0};

   // R03 のパタン
   parameter [63:0] PAT_R03 = {32'b0, PAT_R, PAT_0, PAT_3, 8'b0};

   // R04 のパタン
   parameter [63:0] PAT_R04 = {32'b0, PAT_R, PAT_0, PAT_4, 8'b0};

   // R05 のパタン
   parameter [63:0] PAT_R05 = {32'b0, PAT_R, PAT_0, PAT_5, 8'b0};

   // R06 のパタン
   parameter [63:0] PAT_R06 = {32'b0, PAT_R, PAT_0, PAT_6, 8'b0};

   // R07 のパタン
   parameter [63:0] PAT_R07 = {32'b0, PAT_R, PAT_0, PAT_7, 8'b0};

   // R08 のパタン
   parameter [63:0] PAT_R08 = {32'b0, PAT_R, PAT_0, PAT_8, 8'b0};

   // R09 のパタン
   parameter [63:0] PAT_R09 = {32'b0, PAT_R, PAT_0, PAT_9, 8'b0};

   // R10 のパタン
   parameter [63:0] PAT_R10 = {32'b0, PAT_R, PAT_1, PAT_0, 8'b0};

   // R11 のパタン
   parameter [63:0] PAT_R11 = {32'b0, PAT_R, PAT_1, PAT_1, 8'b0};

   // R12 のパタン
   parameter [63:0] PAT_R12 = {32'b0, PAT_R, PAT_1, PAT_2, 8'b0};

   // R13 のパタン
   parameter [63:0] PAT_R13 = {32'b0, PAT_R, PAT_1, PAT_3, 8'b0};

   // R14 のパタン
   parameter [63:0] PAT_R14 = {32'b0, PAT_R, PAT_1, PAT_4, 8'b0};

   // R15 のパタン
   parameter [63:0] PAT_R15 = {32'b0, PAT_R, PAT_1, PAT_5, 8'b0};

   // R16 のパタン
   parameter [63:0] PAT_R16 = {32'b0, PAT_R, PAT_1, PAT_6, 8'b0};

   // R17 のパタン
   parameter [63:0] PAT_R17 = {32'b0, PAT_R, PAT_1, PAT_7, 8'b0};

   // R18 のパタン
   parameter [63:0] PAT_R18 = {32'b0, PAT_R, PAT_1, PAT_8, 8'b0};

   // R19 のパタン
   parameter [63:0] PAT_R19 = {32'b0, PAT_R, PAT_1, PAT_9, 8'b0};

   // R20 のパタン
   parameter [63:0] PAT_R20 = {32'b0, PAT_R, PAT_2, PAT_0, 8'b0};

   // R21 のパタン
   parameter [63:0] PAT_R21 = {32'b0, PAT_R, PAT_2, PAT_1, 8'b0};

   // R22 のパタン
   parameter [63:0] PAT_R22 = {32'b0, PAT_R, PAT_2, PAT_2, 8'b0};

   // R23 のパタン
   parameter [63:0] PAT_R23 = {32'b0, PAT_R, PAT_2, PAT_3, 8'b0};

   // R24 のパタン
   parameter [63:0] PAT_R24 = {32'b0, PAT_R, PAT_2, PAT_4, 8'b0};

   // R25 のパタン
   parameter [63:0] PAT_R25 = {32'b0, PAT_R, PAT_2, PAT_5, 8'b0};

   // R26 のパタン
   parameter [63:0] PAT_R26 = {32'b0, PAT_R, PAT_2, PAT_6, 8'b0};

   // R27 のパタン
   parameter [63:0] PAT_R27 = {32'b0, PAT_R, PAT_2, PAT_7, 8'b0};

   // R28 のパタン
   parameter [63:0] PAT_R28 = {32'b0, PAT_R, PAT_2, PAT_8, 8'b0};

   // R29 のパタン
   parameter [63:0] PAT_R29 = {32'b0, PAT_R, PAT_2, PAT_9, 8'b0};

   // R30 のパタン
   parameter [63:0] PAT_R30 = {32'b0, PAT_R, PAT_3, PAT_0, 8'b0};

   // R31 のパタン
   parameter [63:0] PAT_R31 = {32'b0, PAT_R, PAT_3, PAT_1, 8'b0};

   // 表示ページを計算する関数
   function page_func(input [3:0] hex_a);
      page_func = ~(hex_a[3:2] == 2'b00);
   endfunction // page_func

   // 4ビットの数字から7SEG-LEDのセグメント信号を作るデコード関数
   function [7:0] decode_func(input [3:0] in);
      // 1つの 7SEG LED に表示するパタン
      // 最下位ビットはドット
      parameter [7:0] SEG_0 = 8'b1111_1100;
      parameter [7:0] SEG_1 = 8'b0110_0000;
      parameter [7:0] SEG_2 = 8'b1101_1010;
      parameter [7:0] SEG_3 = 8'b1111_0010;
      parameter [7:0] SEG_4 = 8'b0110_0110;
      parameter [7:0] SEG_5 = 8'b1011_0110;
      parameter [7:0] SEG_6 = 8'b1011_1110;
      parameter [7:0] SEG_7 = 8'b1110_0000;
      parameter [7:0] SEG_8 = 8'b1111_1110;
      parameter [7:0] SEG_9 = 8'b1111_0110;
      parameter [7:0] SEG_A = 8'b1110_1110;
      parameter [7:0] SEG_B = 8'b0011_1110;
      parameter [7:0] SEG_C = 8'b0001_1010;
      parameter [7:0] SEG_D = 8'b0111_1010;
      parameter [7:0] SEG_E = 8'b1001_1110;
      parameter [7:0] SEG_F = 8'b1000_1110;
      case ( in )
	4'h0: decode_func = SEG_0;
	4'h1: decode_func = SEG_1;
	4'h2: decode_func = SEG_2;
	4'h3: decode_func = SEG_3;
	4'h4: decode_func = SEG_4;
	4'h5: decode_func = SEG_5;
	4'h6: decode_func = SEG_6;
	4'h7: decode_func = SEG_7;
	4'h8: decode_func = SEG_8;
	4'h9: decode_func = SEG_9;
	4'hA: decode_func = SEG_A;
	4'hB: decode_func = SEG_B;
	4'hC: decode_func = SEG_C;
	4'hD: decode_func = SEG_D;
	4'hE: decode_func = SEG_E;
	4'hF: decode_func = SEG_F;
      endcase
   endfunction // decode

   // 8桁のデコード関数
   function [63:0] decode8_func(input [31:0] in);
      decode8_func = {decode_func(in[31:28]),
		      decode_func(in[27:24]),
		      decode_func(in[23:20]),
		      decode_func(in[19:16]),
		      decode_func(in[15:12]),
		      decode_func(in[11: 8]),
		      decode_func(in[ 7: 4]),
		      decode_func(in[ 3: 0])};
   endfunction // decode8_func

   // Aセグメント用の関数
   function [63:0] a_func(input page);
      a_func = page ? PAT_CREG : PAT_PC;
   endfunction // a_func

   // Cセグメント用の関数
   function [63:0] c_func(input page,
			  input [4:0] reg_addr);
      if ( page == 1'b0 ) begin
	 c_func = PAT_IR;
      end
      else begin
	 case ( reg_addr )
	   0: c_func = PAT_R00;
	   1: c_func = PAT_R01;
	   2: c_func = PAT_R02;
	   3: c_func = PAT_R03;
	   4: c_func = PAT_R04;
	   5: c_func = PAT_R05;
	   6: c_func = PAT_R06;
	   7: c_func = PAT_R07;
	   8: c_func = PAT_R08;
	   9: c_func = PAT_R09;
	  10: c_func = PAT_R10;
	  11: c_func = PAT_R11;
	  12: c_func = PAT_R12;
	  13: c_func = PAT_R13;
	  14: c_func = PAT_R14;
	  15: c_func = PAT_R15;
	  16: c_func = PAT_R16;
	  17: c_func = PAT_R17;
	  18: c_func = PAT_R18;
	  19: c_func = PAT_R19;
	  20: c_func = PAT_R20;
	  21: c_func = PAT_R21;
	  22: c_func = PAT_R22;
	  23: c_func = PAT_R23;
	  24: c_func = PAT_R24;
	  25: c_func = PAT_R25;
	  26: c_func = PAT_R26;
	  27: c_func = PAT_R27;
	  28: c_func = PAT_R28;
	  29: c_func = PAT_R29;
	  30: c_func = PAT_R30;
	  31: c_func = PAT_R31;
	 endcase
      end
   endfunction // c_func

   // Eセグメント用の関数
   function [63:0] e_func(input page);
      e_func = page ? PAT_MAR : PAT_AREG;
   endfunction // e_func

   // Gセグメント用の関数
   function [63:0] g_func(input page);
      g_func = page ? PAT_MEM : PAT_BREG;
   endfunction // g_func

   // Bセグメント用の関数
   function [63:0] b_func(input        page,
			  input [31:0] in1,
			  input [31:0] in2);
      b_func = decode8_func(page ? in2 : in1);
   endfunction // b_func

   // 各セグメントの点滅信号を作る．
   function [63:0] blink_func(input sel,
			      input blink);
      blink_func = {64{~sel | blink}};
   endfunction // blink_func

   // MAR
   reg [31:0] 		    mar;
   wire 		    mar_ld;
   wire 		    mar_inc;
   wire 		    mar_dec;
   always @ ( posedge clock or negedge reset ) begin
      if ( !reset ) begin
	 mar <= 32'b0;
      end
      else if ( mar_ld ) begin
	 mar <= input_val;
      end
      else if ( mar_inc ) begin
	 mar <= mar + 32'd4;
      end
      else if ( mar_dec ) begin
	 mar <= mar - 32'd4;
      end
   end

   // 点滅用のカウンタ
   reg [23:0] seg7_blink_count;
   // 点滅信号
   wire blink;
   assign blink = seg7_blink_count[23] | ~input_mode;

   // 点滅用の状態遷移
   // blink が 約 1.2 秒の間隔で点滅する．
   always @ ( posedge sys_clock or negedge reset ) begin
      if ( !reset ) begin
	 seg7_blink_count <= 24'b0;
      end
      else begin
	 seg7_blink_count <= seg7_blink_count + 24'b1;
      end
   end

   assign reg_addr = {(hex_a == 4'b0111), hex_b};

   // 0: 1ページ目，1: 2ページ目
   wire  			       page;
   // PC が書き込み対象として選択されている．
   wire 			       pc_sel;
   // IR が書き込み対象として選択されている．
   wire 			       ir_sel;
   // Aレジスタが書き込み対象として選択されている．
   wire 			       a_sel;
   // Bレジスタが書き込み対象として選択されている．
   wire 			       b_sel;
   // Cレジスタが書き込み対象として選択されている．
   wire 			       c_sel;
   // レジスタファイルが書き込み対象として選択されている．
   wire 			       reg_sel;
   // MARが書き込み対象として選択されている．
   wire 			       mar_sel;
   // メモリが書き込み対象として選択されている．
   wire 			       mem_sel;
   // 入力モード
   wire 			       input_mode;

   assign page   = page_func(hex_a);
   assign pc_sel = (hex_a == 4'b0000);
   assign ir_sel = (hex_a == 4'b0001);
   assign a_sel  = (hex_a == 4'b0010);
   assign b_sel  = (hex_a == 4'b0011);
   assign c_sel  = (hex_a == 4'b0100);
   assign reg_sel = (hex_a[3:1] == 3'b011);
   assign mar_sel = (hex_a == 4'b1000);
   assign mem_sel = (hex_a == 4'b1001);

   // dip-Aの0ビット目が入力モードのスイッチ
   // ただし負論理なので注意
   assign input_mode = ~dip_a[0];

   assign seg7_a = a_func(page);
   assign seg7_b = b_func(page, pc_out, c_out)   & blink_func(pc_sel | c_sel, blink);
   assign seg7_c = c_func(page, reg_addr);
   assign seg7_d = b_func(page, ir_out, reg_out) & blink_func(ir_sel | reg_sel, blink);
   assign seg7_e = e_func(page);
   assign seg7_f = b_func(page, a_out, mar)      & blink_func(a_sel | mar_sel, blink);
   assign seg7_g = g_func(page);
   assign seg7_h = b_func(page, b_out, mem_out)  & blink_func(b_sel | mem_sel, blink);

   assign run        = !input_mode & button1;
   assign step_phase = !input_mode & button2;
   assign step_inst  = !input_mode & button3;
   assign pc_ld      =  input_mode & button3 & pc_sel;
   assign ir_ld      =  input_mode & button3 & ir_sel;
   assign a_ld       =  input_mode & button3 & a_sel;
   assign b_ld       =  input_mode & button3 & b_sel;
   assign c_ld       =  input_mode & button3 & c_sel;
   assign reg_ld     =  input_mode & button3 & reg_sel;
   assign mar_ld     =  input_mode & button3 & mar_sel;
   assign mar_inc    =  input_mode & button1;
   assign mar_dec    =  input_mode & button2;
   assign mem_addr   = mar;
   assign mem_write  =  input_mode & button3 & mem_sel;
   assign mem_read   =  input_mode & ~button3 & mem_sel;

   assign led_out = {cstate, 3'b0, running};


endmodule // debugger
