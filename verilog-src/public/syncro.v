
// @file syncro.v
// @brief シンクロナイザ
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * 3つのD-FFを直列に接続する．
// * 出力側の2つのFFの値から出力を作る．
//
// [入出力]
// clock: クロック
// reset: リセット
// in:    入力
// out:   出力
module syncro(input  clock,
	      input  reset,
	      input  in,
	      output out);
   reg 		     q0, q1, q2;

   always @ ( posedge clock or negedge reset ) begin
      if ( !reset ) begin
	 q0 <= 1'b0;
	 q1 <= 1'b0;
	 q2 <= 1'b0;
      end
      else begin
	 q0 <= ~in; // プッシュボタンは負論理
	 q1 <= q0;
	 q2 <= q1;
      end
   end

   assign out = q1 & (~q2);

endmodule // syncro
