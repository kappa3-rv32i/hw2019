
// @file calc.v
// @brief 簡単な電卓
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 簡単な電卓を実装する．
// * clear が押されたら ibuf, cbuf をクリアする．
// * plus が押されたら ibuf の値を cbuf に転送して ibuf をクリアする．
// * equal が押されたら cbuf に ibuf の値を足して ibuf をクリアする．
//
// [入出力]
// clock:   クロック
// reset:   リセット
// keys:    テンキーの値
// clear:   クリア信号
// plus:    `+'信号
// equal:   `='信号
// ibuf:    入力バッファの値
// cbuf:    計算結果バッファの値
module calc(input         clock,
	    input 	  reset,
	    input [15:0]  keys,
	    input 	  clear,
	    input 	  plus,
	    input 	  equal,
	    output [31:0] ibuf,
	    output [31:0] cbuf);

endmodule // calc
