
// @file kappa3_light.v
// @brief KAPPA3-LIGHTのトップモジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * KAPPA3-LIGHT にデバッガを付加したもの．
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
module kappa3_light(input        sys_clock,
		    input 	 reset,
		    input 	 clock,
		    input 	 psw_a0,
		    input 	 psw_a1,
		    input 	 psw_a2,
		    input 	 psw_a3,
		    input 	 psw_a4,
		    input 	 psw_b0,
		    input 	 psw_b1,
		    input 	 psw_b2,
		    input 	 psw_b3,
		    input 	 psw_b4,
		    input 	 psw_c0,
		    input 	 psw_c1,
		    input 	 psw_c2,
		    input 	 psw_c3,
		    input 	 psw_c4,
		    input 	 psw_d0,
		    input 	 psw_d1,
		    input 	 psw_d2,
		    input 	 psw_d3,
		    input 	 psw_d4,
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

   // clock の2倍のクロック
   reg 			    clock2;
   always @ ( posedge clock ) begin
      clock2 = clock2 ^ 1'b1;
   end

   // シンクロナイザ
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
   syncro syncro_a0(.clock(clock2), .reset(reset), .in(psw_a0), .out(out_a0));
   syncro syncro_a1(.clock(clock2), .reset(reset), .in(psw_a1), .out(out_a1));
   syncro syncro_a2(.clock(clock2), .reset(reset), .in(psw_a2), .out(out_a2));
   syncro syncro_a3(.clock(clock2), .reset(reset), .in(psw_a3), .out(out_a3));
   syncro syncro_a4(.clock(clock2), .reset(reset), .in(psw_a4), .out(out_a4));
   syncro syncro_b0(.clock(clock2), .reset(reset), .in(psw_b0), .out(out_b0));
   syncro syncro_b1(.clock(clock2), .reset(reset), .in(psw_b1), .out(out_b1));
   syncro syncro_b2(.clock(clock2), .reset(reset), .in(psw_b2), .out(out_b2));
   syncro syncro_b3(.clock(clock2), .reset(reset), .in(psw_b3), .out(out_b3));
   syncro syncro_b4(.clock(clock2), .reset(reset), .in(psw_b4), .out(out_b4));
   syncro syncro_c0(.clock(clock2), .reset(reset), .in(psw_c0), .out(out_c0));
   syncro syncro_c1(.clock(clock2), .reset(reset), .in(psw_c1), .out(out_c1));
   syncro syncro_c2(.clock(clock2), .reset(reset), .in(psw_c2), .out(out_c2));
   syncro syncro_c3(.clock(clock2), .reset(reset), .in(psw_c3), .out(out_c3));
   syncro syncro_c4(.clock(clock2), .reset(reset), .in(psw_c4), .out(out_c4));
   syncro syncro_d0(.clock(clock2), .reset(reset), .in(psw_d0), .out(out_d0));
   syncro syncro_d1(.clock(clock2), .reset(reset), .in(psw_d1), .out(out_d1));
   syncro syncro_d2(.clock(clock2), .reset(reset), .in(psw_d2), .out(out_d2));
   syncro syncro_d3(.clock(clock2), .reset(reset), .in(psw_d3), .out(out_d3));
   syncro syncro_d4(.clock(clock2), .reset(reset), .in(psw_d4), .out(out_d4));

   // キーエンコーダ
   wire [15:0] 		    keys;
   wire 		    key_in;
   wire [3:0] 		    key_val;
   assign keys = {out_d3, out_d2, out_d1, out_d0,
		  out_c3, out_c2, out_c1, out_c0,
		  out_b3, out_b2, out_b1, out_b0,
		  out_a3, out_a2, out_a1, out_a0};
   keyenc keyenc_inst(.keys(keys), .key_in(key_in), .key_val(key_val));

   // キー入力バッファ
   wire [31:0] 		    dbg_in;
   wire 		    button1;
   wire 		    button2;
   wire 		    button3;
   keybuf keybuf_inst(.clock(clock2), .reset(reset),
		      .key_in(key_in), .key_val(key_val),
		      .clear(out_a4), .out(dbg_in));

   // 7SEG-LED デコーダ x 8
   wire [7:0] 		    dec_out0;
   wire [7:0] 		    dec_out1;
   wire [7:0] 		    dec_out2;
   wire [7:0] 		    dec_out3;
   wire [7:0] 		    dec_out4;
   wire [7:0] 		    dec_out5;
   wire [7:0] 		    dec_out6;
   wire [7:0] 		    dec_out7;
   decode_7seg decode_7seg_inst0(dbg_in[ 3: 0], dec_out0);
   decode_7seg decode_7seg_inst1(dbg_in[ 7: 4], dec_out1);
   decode_7seg decode_7seg_inst2(dbg_in[11: 8], dec_out2);
   decode_7seg decode_7seg_inst3(dbg_in[15:12], dec_out3);
   decode_7seg decode_7seg_inst4(dbg_in[19:16], dec_out4);
   decode_7seg decode_7seg_inst5(dbg_in[23:20], dec_out5);
   decode_7seg decode_7seg_inst6(dbg_in[27:24], dec_out6);
   decode_7seg decode_7seg_inst7(dbg_in[31:28], dec_out7);

   assign button1 = out_b4;
   assign button2 = out_c4;
   assign button3 = out_d4;

   assign rk_a = dec_out7;
   assign rk_b = dec_out6;
   assign rk_c = dec_out5;
   assign rk_d = dec_out4;
   assign rk_e = dec_out3;
   assign rk_f = dec_out2;
   assign rk_g = dec_out1;
   assign rk_h = dec_out0;

   // KAPPA3-LIGHTのコア
   wire 		    run;
   wire 		    step_phase;
   wire 		    step_inst;
   wire [3:0] 		    cstate;
   wire 		    running;
   wire [31:0] 		    pc_out;
   wire 		    pc_ld;
   wire [31:0] 		    ir_out;
   wire 		    ir_ld;
   wire [31:0] 		    a_out;
   wire 		    a_ld;
   wire [31:0] 		    b_out;
   wire 		    b_ld;
   wire [31:0] 		    c_out;
   wire 		    c_ld;
   wire [4:0] 		    reg_addr;
   wire 		    reg_ld;
   wire [31:0] 		    reg_out;
   wire [31:0] 		    mem_addr;
   wire 		    mem_read;
   wire 		    mem_write;
   wire [31:0] 		    mem_rddata;
   kappa3_light_core kapp3_light_core(.reset(reset),
				      .clock(clock),
				      .clock2(clock2),
				      .run(run),
				      .step_phase(step_phase),
				      .step_inst(step_inst),
				      .cstate(cstate),
				      .running(running),
				      .dbg_in(dbg_in),
				      .dbg_pc_ld(pc_ld),
				      .dbg_pc_out(pc_out),
				      .dbg_ir_ld(ir_ld),
				      .dbg_ir_out(ir_out),
				      .dbg_reg_addr(reg_addr),
				      .dbg_reg_ld(reg_ld),
				      .dbg_reg_out(reg_out),
				      .dbg_a_ld(a_ld),
				      .dbg_a_out(a_out),
				      .dbg_b_ld(b_ld),
				      .dbg_b_out(b_out),
				      .dbg_c_ld(c_ld),
				      .dbg_c_out(c_out),
				      .dbg_mem_addr(mem_addr),
				      .dbg_mem_read(mem_read),
				      .dbg_mem_write(mem_write),
				      .dbg_mem_out(mem_rddata));

   // デバッガ
   debugger dbg_inst(.sys_clock(sys_clock),
		     .reset(reset),
		     .clock(clock2),
		     .input_val(dbg_in),
		     .button1(button1),
		     .button2(button2),
		     .button3(button3),
		     .run(run),
		     .step_phase(step_phase),
		     .step_inst(step_inst),
		     .cstate(cstate),
		     .running(running),
		     .hex_a(hex_a),
		     .hex_b(hex_b),
		     .dip_a(dip_a),
		     .dip_b(dip_b),
		     .pc_out(pc_out),
		     .pc_ld(pc_ld),
		     .ir_out(ir_out),
		     .ir_ld(ir_ld),
		     .reg_out(reg_out),
		     .reg_addr(reg_addr),
		     .reg_ld(reg_ld),
		     .a_out(a_out),
		     .a_ld(a_ld),
		     .b_out(b_out),
		     .b_ld(b_ld),
		     .c_out(c_out),
		     .c_ld(c_ld),
		     .mem_addr(mem_addr),
		     .mem_out(mem_rddata),
		     .mem_read(mem_read),
		     .mem_write(mem_write),
		     .seg7_a(seg7_a),
		     .seg7_b(seg7_b),
		     .seg7_c(seg7_c),
		     .seg7_d(seg7_d),
		     .seg7_e(seg7_e),
		     .seg7_f(seg7_f),
		     .seg7_g(seg7_g),
		     .seg7_h(seg7_h),
		     .led_out(led_out));

endmodule
