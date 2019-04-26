
// @file udcount4.v
// @breif 4ビットアップダウンカウンタ
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 4ビットのアップダウンカウンタ
//
// [入出力]
// clock:  クロック
// reset:  リセット
// ud:     アップ・ダウンを制御する信号．0: up, 1: down
// enable: カウントイネーブル信号
// q:      4ビットのカウント値
// carry:  キャリー出力
module udcount4(input            clock,
		input 		 reset,
		input 		 ud,
		input 		 enable,
		output reg [3:0] q,
		output 		 carry);

endmodule // udcount4
