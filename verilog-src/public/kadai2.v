
// @file kadai2.v
// @breif 課題2: add4 のテスト用トップモジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * 2つのロータリースイッチ(hex_a, hex_b)を2つの入力に接続する．
// * 右上隅のプッシュボタン(psw_a4)をキャリー入力に接続する．
// * MU500-7SEG の A0 と A2 に入力の値を表示する．
// * MU500-7SEG の A4 にキャリー入力の値を表示する．
// * MU500-7SEG の B6 にキャリー出力の値を表示する．
// * MU500-7SEG の B7 に出力の値を表示する．
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
module kadai2(input        sys_clock,
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

   // add4 のインスタンス
   wire [3:0] 		    in1, in2;
   wire 		    cin;
   wire [3:0] 		    out;
   wire 		    cout;
   add4 add4_inst(.a(in1), .b(in2), .cin(cin), .s(out), .cout(cout));

   assign in1 = hex_a;
   assign in2 = hex_b;
   assign cin = ~psw_a4;

   wire [7:0] 		    dec_out1;
   decode_7seg decode1(.in(in1), .out(dec_out1));

   wire [7:0] 		    dec_out2;
   decode_7seg decode2(.in(in2), .out(dec_out2));

   wire [7:0] 		    dec_out3;
   decode_7seg decode3(.in({7'b0, cin}), .out(dec_out3));

   wire [7:0] 		    dec_out4;
   decode_7seg decode4(.in(out), .out(dec_out4));

   wire [7:0] 		    dec_out5;
   decode_7seg decode5(.in({7'b0, cout}), .out(dec_out5));

   // MU500-RK の LED は未使用
   assign rk_a = 8'b0;
   assign rk_b = 8'b0;
   assign rk_c = 8'b0;
   assign rk_d = 8'b0;
   assign rk_e = 8'b0;
   assign rk_f = 8'b0;
   assign rk_g = 8'b0;
   assign rk_h = 8'b0;
   assign led_out = 8'b0;

   assign seg7_a = {dec_out1, 8'b0, dec_out2, 8'b0, dec_out3, 24'b0};
   assign seg7_b = {48'b0, dec_out5, dec_out4};
   assign seg7_c = 64'b0;
   assign seg7_d = 64'b0;
   assign seg7_e = 64'b0;
   assign seg7_f = 64'b0;
   assign seg7_g = 64'b0;
   assign seg7_h = 64'b0;
   assign seg7_dot64 = 64'b0;

endmodule
