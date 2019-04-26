
// @file phasegen_test.v
// @brief phasegen のテスト用トップモジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * psw_b4 を run ボタンに割り当てる．
// * psw_c4 を step_phase ボタンに割り当てる．
// * psw_d4 を step_inst ボタンに割り当てる．
// * 7SEG-LED の H7, H6, H5, H4 を IF, DE, EX, WB に出力する．
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
module phasegen_test(input        sys_clock,
		     input 	  reset,
		     input 	  clock,
		     input 	  psw_a0,
		     input 	  psw_a1,
		     input 	  psw_a2,
		     input 	  psw_a3,
		     input 	  psw_a4,
		     input 	  psw_b0,
		     input 	  psw_b1,
		     input 	  psw_b2,
		     input 	  psw_b3,
		     input 	  psw_b4,
		     input 	  psw_c0,
		     input 	  psw_c1,
		     input 	  psw_c2,
		     input 	  psw_c3,
		     input 	  psw_c4,
		     input 	  psw_d0,
		     input 	  psw_d1,
		     input 	  psw_d2,
		     input 	  psw_d3,
		     input 	  psw_d4,
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
   wire 		    out_b4;
   wire 		    out_c4;
   wire 		    out_d4;
   syncro syncro_b4(.clock(clock), .reset(reset), .in(psw_b4), .out(out_b4));
   syncro syncro_c4(.clock(clock), .reset(reset), .in(psw_c4), .out(out_c4));
   syncro syncro_d4(.clock(clock), .reset(reset), .in(psw_d4), .out(out_d4));

   assign rk_a = 8'b0;
   assign rk_b = 8'b0;
   assign rk_c = 8'b0;
   assign rk_d = 8'b0;
   assign rk_e = 8'b0;
   assign rk_f = 8'b0;
   assign rk_g = 8'b0;
   assign rk_h = 8'b0;

   // phasegen
   wire [3:0] 		    cstate;
   phasegen pg_inst(.clock(clock),
		    .reset(reset),
		    .run(out_b4),
		    .step_phase(out_c4),
		    .step_inst(out_d4),
		    .cstate(cstate));

   wire [7:0] 		    h7;
   wire [7:0] 		    h6;
   wire [7:0] 		    h5;
   wire [7:0] 		    h4;

   assign h7 = cstate[0] ? 8'b0000_0010 : 8'b0000_0000;
   assign h6 = cstate[1] ? 8'b0000_0010 : 8'b0000_0000;
   assign h5 = cstate[2] ? 8'b0000_0010 : 8'b0000_0000;
   assign h4 = cstate[3] ? 8'b0000_0010 : 8'b0000_0000;

   assign seg7_a = 64'b0;
   assign seg7_b = 64'b0;
   assign seg7_c = 64'b0;
   assign seg7_d = 64'b0;
   assign seg7_e = 64'b0;
   assign seg7_f = 64'b0;
   assign seg7_g = 64'b0;
   assign seg7_h = {h7, h6, h5, h4, 32'b0};
   assign seg7_dot64 = 64'b0;

   assign led_out = {cstate[3], cstate[2], cstate[1], cstate[0], clock, ~clock, 2'b00};

endmodule
