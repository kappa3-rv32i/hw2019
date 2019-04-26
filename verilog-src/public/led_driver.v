
// @file led_driver.v
// @breif MU500-RX,RK,7SEGセット用表示モジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// MU500-RK と MU500-7SEG のLED表示のためのドライバ回路
// ただしMU500-RKの８個のドットLEDはこのモジュールを介さずに直接
// 信号線を出力する．
// それ以外の7SEG-LEDおよびMU500-7SEGの64個のLEDはピンを
// 共有しているので時分割制御が必要となる．
// さらに面倒なのはMU500-RKはダイナミック回路として動作する
// のに対してMU500-7SEGは一旦ラッチした信号を出力するスタティック
// 回路として動作するので両者に対して異なった制御が必要となる．
// 基本的には適当な周期で表示する桁(MU500-7SEGの場合はグループ)
// を移動させていく．実機で試した結果20MHzのシステムクロックを
// 64K(= 2^16)分周した312Hz程度だとチラツキもないようなので，
// この値を用いている．
// 前述のようにMU500-7SEGは出力する値を一旦ラッチするので
// セレクト信号は１クロック分のパルスになるように加工する．
// また配線遅延の関係でセレクト信号を切替えた瞬間だとデータ
// の到達が間に合わないようなのでセレクト信号のパルスは１クロック
// 遅らせるようにしている．
// MU500-RKは単純に4桁のLEDを順に切り替えていく．注意が必要なのは
// MU500-RKのセレクト信号は負論理(0がアクティブ)なので実際に
// 出力するときに反転を行っている．
//
// [入出力]
//
// sys_clock:  MU500のシステムクロック
// reset:      リセット信号(負論理)
// seg7_a:     MU500-7SEGボードのAグループのセグメント(8ビット x 8個)
// seg7_b:     MU500-7SEGボードのBグループのセグメント(8ビット x 8個)
// seg7_c:     MU500-7SEGボードのCグループのセグメント(8ビット x 8個)
// seg7_d:     MU500-7SEGボードのDグループのセグメント(8ビット x 8個)
// seg7_e:     MU500-7SEGボードのEグループのセグメント(8ビット x 8個)
// seg7_f:     MU500-7SEGボードのFグループのセグメント(8ビット x 8個)
// seg7_g:     MU500-7SEGボードのGグループのセグメント(8ビット x 8個)
// seg7_h:     MU500-7SEGボードのHグループのセグメント(8ビット x 8個)
// seg7_dot64: MU500-7SEGボードのドットマトリクス(64ビット)
// rk_a:       MU500-RKボードのAのセグメント(8ビット)
// rk_b:       MU500-RKボードのBのセグメント(8ビット)
// rk_c:       MU500-RKボードのCのセグメント(8ビット)
// rk_d:       MU500-RKボードのDのセグメント(8ビット)
// rk_e:       MU500-RKボードのEのセグメント(8ビット)
// rk_f:       MU500-RKボードのFのセグメント(8ビット)
// rk_g:       MU500-RKボードのGのセグメント(8ビット)
// rk_h:       MU500-RKボードのHのセグメント(8ビット)
// seg_a:      MU500-7SEGボードへの出力(seg_a)
// seg_b:      MU500-7SEGボードへの出力(seg_b)
// seg_c:      MU500-7SEGボードへの出力(seg_c)
// seg_d:      MU500-7SEGボードへの出力(seg_d)
// seg_e:      MU500-7SEGボードへの出力(seg_e)
// seg_f:      MU500-7SEGボードへの出力(seg_f)
// seg_g:      MU500-7SEGボードへの出力(seg_g)
// seg_h:      MU500-7SEGボードへの出力(seg_h)
// sel:        MU500-7SEGボードへの出力(sel)
// seg_x:      MU500-RKボードへの出力(seg_x)
// sel_x:      MU500-RKボードへの出力(sel_x)
// seg_y:      MU500-RKボードへの出力(seg_y)
// sel_y:      MU500-RKボードへの出力(sel_y)
//
// なお出力の seg_a はボード上の7SEG-LEDのAグループ
// とは全く無関係の8列ある7SEG-LEDの左端に対応している．
module led_driver(input        sys_clock,
		  input        reset,
		  input [63:0] seg7_a,
		  input [63:0] seg7_b,
		  input [63:0] seg7_c,
		  input [63:0] seg7_d,
		  input [63:0] seg7_e,
		  input [63:0] seg7_f,
		  input [63:0] seg7_g,
		  input [63:0] seg7_h,
		  input [63:0] seg7_dot64,
		  input [7:0]  rk_a,
		  input [7:0]  rk_b,
		  input [7:0]  rk_c,
		  input [7:0]  rk_d,
		  input [7:0]  rk_e,
		  input [7:0]  rk_f,
		  input [7:0]  rk_g,
		  input [7:0]  rk_h,
		  output [7:0] seg_a,
		  output [7:0] seg_b,
		  output [7:0] seg_c,
		  output [7:0] seg_d,
		  output [7:0] seg_e,
		  output [7:0] seg_f,
		  output [7:0] seg_g,
		  output [7:0] seg_h,
		  output [8:0] sel,
		  output [7:0] seg_x,
		  output [3:0] sel_x,
		  output [7:0] seg_y,
		  output [3:0] sel_y);

   // 8つ+1のなかから１つの値を選ぶ(7SEG用)．
   function [63:0] select9(input [63:0] a,
			    input [63:0] b,
			    input [63:0] c,
			    input [63:0] d,
			    input [63:0] e,
			    input [63:0] f,
			    input [63:0] g,
			    input [63:0] h,
			    input [63:0] dot64,
			    input [8:0]  state);
      // one-hot エンコーディングを仮定している
      if ( state[0] ) begin
	 select9 = a;
      end
      else if ( state[1] ) begin
	 select9 = b;
      end
      else if ( state[2] ) begin
	 select9 = c;
      end
      else if ( state[3] ) begin
	 select9 = d;
      end
      else if ( state[4] ) begin
	 select9 = e;
      end
      else if ( state[5] ) begin
	 select9 = f;
      end
      else if ( state[6] ) begin
	 select9 = g;
      end
      else if ( state[7] ) begin
	 select9 = h;
      end
      else if ( state[8] ) begin
	 select9 = dot64;
      end
      else begin
	 // ありえないけど念の為
	 select9 = 64'b0;
      end
   endfunction // select9

   // in_0, in_1, in_2, in_3 から選択する(RK用)．
   function [7:0] select4(input [7:0] in_0,
			  input [7:0] in_1,
			  input [7:0] in_2,
			  input [7:0] in_3,
			  input [3:0] state);
      // one-hot エンコーディングを仮定している
      if ( state[0] ) begin
	 select4 = in_0;
      end
      else if ( state[1] ) begin
	 select4 = in_1;
      end
      else if ( state[2] ) begin
	 select4 = in_2;
      end
      else if ( state[3] ) begin
	 select4 = in_3;
      end
      else begin
	 // ありえないけど念の為
	 select4 = 8'b0;
      end
   endfunction // select4

   // 時分割のタイミング調整用カウンタ
   reg [15:0]			      count;

   // 7SEG用の内部状態
   // 8個の7SEG-LEDグループ+1つのドットLEDグループで9個
   reg [8:0] 			      seg7_state;

   // RK用の内部状態
   // 4桁の7SEG-LEDを切り替える．
   reg [3:0] 			      rk_state;

   // 時分割を行うためにセレクト信号を巡回させる．
   // 20Mhz を 2^16 = 64K分周する(約312Hz)．
   // これくらいならチラツキが気にならない．
   // 312Hzの周期でセレクト信号を一つ進める．
   // やっていることは9ビットと4ビットのデータの左ローテート
   // だが，Verilog-HDLにはローテート演算はないので連結演算子
   // でローテート演算を記述している．
   always @ ( posedge sys_clock or negedge reset ) begin
      if ( !reset ) begin
	 // 初期化する．
	 // 実は count はどの値から始まっても正しく動く．
	 // seg7_state, rk_state はどれか1つのビットだけ1の状態
	 // から始めないと正しく動かない．
	 count <= 16'b0;
	 seg7_state <= 9'b0_0000_0001;
	 rk_state <= 4'b0001;
      end
      else begin
	 count <= count + 16'b1;
	 if ( count == 16'b0 ) begin
	    // count が一周したタイミングでセレクト信号を更新する．
	    seg7_state <= {seg7_state[7:0], seg7_state[8]};
	    rk_state <= {rk_state[2:0], rk_state[3]};
	 end
      end
   end

   // 7SEG用のセレクト信号
   // MU500-7SEGのLEDはラッチされるので１クロック分の
   // パルスを作る．
   // count == 16'b0 のタイミングだと配線遅延の影響で
   // ただしいデータがラッチされないことがあるようなので
   // 1クロック遅らせてラッチしている．
   assign sel = seg7_state & {9{(count == 16'b1)}};

   // seg7_state で選択されたデータ
   // 8個別々に書いてもいいけど連結すれば1つでまとめて記述できる．
   wire [63:0] 			      data;
   assign data = select9(seg7_a, seg7_b, seg7_c, seg7_d,
			 seg7_e, seg7_f, seg7_g, seg7_h,
			 seg7_dot64, seg7_state);

   assign {seg_a, seg_b, seg_c, seg_d,
	   seg_e, seg_f, seg_g, seg_h} = data;

   // 選択信号は負論理
   // MU500-RKのLEDはダイナミック回路なので
   // 常にどれかの桁を光らせておく．
   assign sel_x = ~rk_state;
   assign sel_y = sel_x;

   // rk_state によって出力内容を選択する．
   // これも連結すれば1行で書けるけどこちらのほうがわかりやすい．
   assign seg_x = select4(rk_a, rk_b, rk_c, rk_d, rk_state);
   assign seg_y = select4(rk_e, rk_f, rk_g, rk_h, rk_state);

endmodule // led_driver
