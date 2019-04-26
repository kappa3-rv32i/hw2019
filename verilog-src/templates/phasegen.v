
// @file phasegen.v
// @breif フェーズジェネレータ
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 命令フェイズを生成する．
//
// cstate = {cs_wb, cs_ex, cs_de, cs_if}
// で，常に1つのビットのみ1になっている．
// cs_wb = cstate[3], cs_if = cstate[0]
// であることに注意．
// 各ビットの意味は以下の通り．
// cs_if: IF フェーズ
// cs_de: DE フェーズ
// cs_ex: EX フェーズ
// cs_wb: WB フェーズ
//
// [入出力]
// clock:      クロック信号(立ち上がりエッジ)
// reset:      リセット信号(0でリセット)
// run:        実行開始
// step_phase: 1フェイズ実行
// step_inst:  1命令実行
// cstate:     命令実行フェーズを表すビットベクタ
module phasegen(input  	     clock,
		input 	     reset,
		input 	     run,
		input 	     step_phase,
		input 	     step_inst,
		output [3:0] cstate);

endmodule // phasegen
