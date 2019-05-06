
// @file reg32.v
// @breif 汎用32ビットレジスタ
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 32ビットの汎用レジスタ．
// PC, IR, A-reg, B-reg, C-reg に用いられる．
// ただし，デバッグ用に dbg_in, dbg_ld の付加的な
// 信号入力を持つ．
// 以下のような動作を行う．
// * 内容は out から常時出力されている．
// * リセット信号が0の時に内容を32'h0に初期化する．
// * クロックの立ち上がりエッジで
//   - dbg_mode が 1 で dbg_ld が1の時に dbg_in の値を書き込む．
//   - dbg_mode が 0 で ld が1の時に in の値を書き込む．
//
// [入出力]
// clock:    クロック信号(立ち上がりエッジ)
// reset:    リセット信号(0でリセット)
// in:       書き込みデータ(32ビット)
// ld:       ロード信号
// out:      読み出しデータ(32ビット)
// dbg_mode: デバックモード
// dbg_in:   デバッグモードの入力
// dbg_ld:   デバッグモードのロード信号
module reg32(input             clock,
	     input 	       reset,

	     input [31:0]      in,
	     input 	       ld,

	     output reg [31:0] out,

	     // デバッグ関係
	     input 	       dbg_mode,
	     input [31:0]      dbg_in,
	     input 	       dbg_ld);

   always @ ( posedge clock or negedge reset )
     if ( !reset )
       out <= 32'h0;
     else if ( dbg_mode && dbg_ld )
       out <= dbg_in;
     else if ( !dbg_mode && ld )
       out <= in;

endmodule // reg32
