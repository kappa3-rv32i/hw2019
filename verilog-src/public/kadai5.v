
// @file kadai5.v
// @brief 課題5: 電卓のテスト用のトップモジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * プッシュボタン(4x4)をシンクロナイズを経由して calc の keys に接続する．
// * 右上隅のプッシュボタン(psw_a4)を calc の clear に接続する．
// * 右上隅ひとつ下のプッシュボタン(psw_b4)を calc の plust に接続する．
// * 右下隅のプッシュボタン(psw_d4)を calc の equal に接続する．
// * calc の ibuf を MU500-RK の7SEG-LEDに出力する．
// * calc の cbuf を MU500-7SEG のHグループの7SEG-LEDに出力する．
//
// [入出力]
// sys_clock: システムクロック
// reset:     リセット信号(負論理)
// clock:     CPUクロック
// psw_a0 ～ psw_d4: プッシュボタンスイッチ
// hex_a:     ロータリースイッチA
// hex_b:     ロータリースイッチB
// dip_a:     DIPスイッチA
// dip_b:     DIPスイッチB
// seg_x:     RKボードの7SEG(左4つ分)のセグメント
// sel_x:     RKボードの7SEG(左4つ分)の選択信号
// seg_y:     RKボードの7SEG(右4つ分)のセグメント
// sel_y:     RKボードの7SEG(右4つ分)の選択信号
// led_out:   RKボードのドットLED
// seg_a ～ seg_h: 7SEGボードの7SEGセグメント
// sel:       7SEGボードの選択信号
module kadai5(input        sys_clock,
	      input 	   reset,
	      input 	   clock,
	      input 	   psw_a0,
	      input 	   psw_a1,
	      input 	   psw_a2,
	      input 	   psw_a3,
	      input 	   psw_a4,
	      input 	   psw_b0,
	      input 	   psw_b1,
	      input 	   psw_b2,
	      input 	   psw_b3,
	      input 	   psw_b4,
	      input 	   psw_c0,
	      input 	   psw_c1,
	      input 	   psw_c2,
	      input 	   psw_c3,
	      input 	   psw_c4,
	      input 	   psw_d0,
	      input 	   psw_d1,
	      input 	   psw_d2,
	      input 	   psw_d3,
	      input 	   psw_d4,
	      input [3:0]  hex_a,
	      input [3:0]  hex_b,
	      input [7:0]  dip_a,
	      input [7:0]  dip_b,
	      output [7:0] seg_x,
	      output [3:0] sel_x,
	      output [7:0] seg_y,
	      output [3:0] sel_y,
	      output [7:0] led_out,
	      output [7:0] seg_a,
	      output [7:0] seg_b,
	      output [7:0] seg_c,
	      output [7:0] seg_d,
	      output [7:0] seg_e,
	      output [7:0] seg_f,
	      output [7:0] seg_g,
	      output [7:0] seg_h,
	      output [8:0] sel);

   // 7SEG-LED のセグメントの値を保持する信号線
   // 先頭に seg7 が付いているのは MU500-7SEG のLED用
   // 先頭に rk が付いているのは MU500-RK のLED用
   // MU500-RK のドットLED(led_out)は表示モジュールを介さずに直接ドライブする．
   wire [63:0] 		    seg7_a;
   wire [63:0] 		    seg7_b;
   wire [63:0] 		    seg7_c;
   wire [63:0] 		    seg7_d;
   wire [63:0] 		    seg7_e;
   wire [63:0] 		    seg7_f;
   wire [63:0] 		    seg7_g;
   wire [63:0] 		    seg7_h;
   wire [63:0] 		    seg7_dot64;
   wire [7:0] 		    rk_a;
   wire [7:0] 		    rk_b;
   wire [7:0] 		    rk_c;
   wire [7:0] 		    rk_d;
   wire [7:0] 		    rk_e;
   wire [7:0] 		    rk_f;
   wire [7:0] 		    rk_g;
   wire [7:0] 		    rk_h;

   // LED表示用のモジュール
   led_driver led_driver_inst(.sys_clock(sys_clock),
			      .reset(reset),
			      .seg7_a(seg7_a), .seg7_b(seg7_b),
			      .seg7_c(seg7_c), .seg7_d(seg7_d),
			      .seg7_e(seg7_e), .seg7_f(seg7_f),
			      .seg7_g(seg7_g), .seg7_h(seg7_h),
			      .seg7_dot64(seg7_dot64),
			      .rk_a(rk_a), .rk_b(rk_b),
			      .rk_c(rk_c), .rk_d(rk_d),
			      .rk_e(rk_e), .rk_f(rk_f),
			      .rk_g(rk_g), .rk_h(rk_h),
   			      .seg_a(seg_a), .seg_b(seg_b),
			      .seg_c(seg_c), .seg_d(seg_d),
			      .seg_e(seg_e), .seg_f(seg_f),
			      .seg_g(seg_g), .seg_h(seg_h),
			      .sel(sel),
			      .seg_x(seg_x),
			      .sel_x(sel_x),
			      .seg_y(seg_y),
			      .sel_y(sel_y));

   // シンクロナイザ
   // 未使用のキー用にも用意している．
   wire 		    out_a0;
   wire 		    out_a1;
   wire 		    out_a2;
   wire 		    out_a3;
   wire 		    out_a4;
   wire 		    out_b0;
   wire 		    out_b1;
   wire 		    out_b2;
   wire 		    out_b3;
   wire 		    out_b4;
   wire 		    out_c0;
   wire 		    out_c1;
   wire 		    out_c2;
   wire 		    out_c3;
   wire 		    out_c4;
   wire 		    out_d0;
   wire 		    out_d1;
   wire 		    out_d2;
   wire 		    out_d3;
   wire 		    out_d4;
   syncro syncro_a0(.clock(clock), .reset(reset), .in(psw_a0), .out(out_a0));
   syncro syncro_a1(.clock(clock), .reset(reset), .in(psw_a1), .out(out_a1));
   syncro syncro_a2(.clock(clock), .reset(reset), .in(psw_a2), .out(out_a2));
   syncro syncro_a3(.clock(clock), .reset(reset), .in(psw_a3), .out(out_a3));
   syncro syncro_a4(.clock(clock), .reset(reset), .in(psw_a4), .out(out_a4));
   syncro syncro_b0(.clock(clock), .reset(reset), .in(psw_b0), .out(out_b0));
   syncro syncro_b1(.clock(clock), .reset(reset), .in(psw_b1), .out(out_b1));
   syncro syncro_b2(.clock(clock), .reset(reset), .in(psw_b2), .out(out_b2));
   syncro syncro_b3(.clock(clock), .reset(reset), .in(psw_b3), .out(out_b3));
   syncro syncro_b4(.clock(clock), .reset(reset), .in(psw_b4), .out(out_b4));
   syncro syncro_c0(.clock(clock), .reset(reset), .in(psw_c0), .out(out_c0));
   syncro syncro_c1(.clock(clock), .reset(reset), .in(psw_c1), .out(out_c1));
   syncro syncro_c2(.clock(clock), .reset(reset), .in(psw_c2), .out(out_c2));
   syncro syncro_c3(.clock(clock), .reset(reset), .in(psw_c3), .out(out_c3));
   syncro syncro_c4(.clock(clock), .reset(reset), .in(psw_c4), .out(out_c4));
   syncro syncro_d0(.clock(clock), .reset(reset), .in(psw_d0), .out(out_d0));
   syncro syncro_d1(.clock(clock), .reset(reset), .in(psw_d1), .out(out_d1));
   syncro syncro_d2(.clock(clock), .reset(reset), .in(psw_d2), .out(out_d2));
   syncro syncro_d3(.clock(clock), .reset(reset), .in(psw_d3), .out(out_d3));
   syncro syncro_d4(.clock(clock), .reset(reset), .in(psw_d4), .out(out_d4));

   // 電卓本体
   wire [15:0] 		    keys;
   assign keys = {out_d3, out_d2, out_d1, out_d0,
		  out_c3, out_c2, out_c1, out_c0,
		  out_b3, out_b2, out_b1, out_b0,
		  out_a3, out_a2, out_a1, out_a0};
   wire [31:0] 		    ibuf;
   wire [31:0] 		    cbuf;
   calc calc_inst(.clock(clock), .reset(reset),
		  .keys(keys), .clear(out_a4),
		  .plus(out_b4), .equal(out_d4),
		  .ibuf(ibuf), .cbuf(cbuf));

   // RK用デコーダ
   wire [7:0] 		    dec_ibuf0;
   wire [7:0] 		    dec_ibuf1;
   wire [7:0] 		    dec_ibuf2;
   wire [7:0] 		    dec_ibuf3;
   wire [7:0] 		    dec_ibuf4;
   wire [7:0] 		    dec_ibuf5;
   wire [7:0] 		    dec_ibuf6;
   wire [7:0] 		    dec_ibuf7;
   decode_7seg decode_7seg_inst0(ibuf[ 3: 0], dec_ibuf0);
   decode_7seg decode_7seg_inst1(ibuf[ 7: 4], dec_ibuf1);
   decode_7seg decode_7seg_inst2(ibuf[11: 8], dec_ibuf2);
   decode_7seg decode_7seg_inst3(ibuf[15:12], dec_ibuf3);
   decode_7seg decode_7seg_inst4(ibuf[19:16], dec_ibuf4);
   decode_7seg decode_7seg_inst5(ibuf[23:20], dec_ibuf5);
   decode_7seg decode_7seg_inst6(ibuf[27:24], dec_ibuf6);
   decode_7seg decode_7seg_inst7(ibuf[31:28], dec_ibuf7);

   // 7SEG用デコーダ
   wire [7:0] 		    dec_cbuf0;
   wire [7:0] 		    dec_cbuf1;
   wire [7:0] 		    dec_cbuf2;
   wire [7:0] 		    dec_cbuf3;
   wire [7:0] 		    dec_cbuf4;
   wire [7:0] 		    dec_cbuf5;
   wire [7:0] 		    dec_cbuf6;
   wire [7:0] 		    dec_cbuf7;
   decode_7seg decode_7seg_inst8(cbuf[ 3: 0], dec_cbuf0);
   decode_7seg decode_7seg_inst9(cbuf[ 7: 4], dec_cbuf1);
   decode_7seg decode_7seg_inst10(cbuf[11: 8], dec_cbuf2);
   decode_7seg decode_7seg_inst11(cbuf[15:12], dec_cbuf3);
   decode_7seg decode_7seg_inst12(cbuf[19:16], dec_cbuf4);
   decode_7seg decode_7seg_inst13(cbuf[23:20], dec_cbuf5);
   decode_7seg decode_7seg_inst14(cbuf[27:24], dec_cbuf6);
   decode_7seg decode_7seg_inst15(cbuf[31:28], dec_cbuf7);

   assign rk_a = dec_ibuf7;
   assign rk_b = dec_ibuf6;
   assign rk_c = dec_ibuf5;
   assign rk_d = dec_ibuf4;
   assign rk_e = dec_ibuf3;
   assign rk_f = dec_ibuf2;
   assign rk_g = dec_ibuf1;
   assign rk_h = dec_ibuf0;

   // led_out は使わない．
   assign led_out = 8'b0;

   assign seg7_a = 64'b0;
   assign seg7_b = 64'b0;
   assign seg7_c = 64'b0;
   assign seg7_d = 64'b0;
   assign seg7_e = 64'b0;
   assign seg7_f = 64'b0;
   assign seg7_g = 64'b0;
   assign seg7_h = {dec_cbuf7, dec_cbuf6, dec_cbuf5, dec_cbuf4,
		    dec_cbuf3, dec_cbuf2, dec_cbuf1, dec_cbuf0};
   assign seg7_dot64 = 64'b0;

endmodule
