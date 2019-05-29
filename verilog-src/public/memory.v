
// @file memory.v
// @breif メモリモジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * 64Kバイトの2ポートメモリを用いている．
// * 書き込むときには wrbits で指定されたバイトにのみ書き込む．
// * 実は read 信号は用いられない．
//
// [入出力]
// clock:       クロック
// address:     アドレス
// read:        読み出しイネーブル
// write:       書き込みイネーブル
// wrdata:      書き込みデータ
// wrbits:      書き込み用ビットマスク
// rddata:      読み出しデータ
// dbg_address: デバッグ用のアドレス
// dbg_read:    デバッグ用の読み出しイネーブル
// dbg_write:   デバッグ用の書き込みイネーブル
// dbg_in:      デバッグ用の書込みデータ
// dbg_out:     デバッグ用の読み出しデータ
module memory(input         clock,
	      input [31:0]  address,
	      input 	    read,
	      input 	    write,
	      input [31:0]  wrdata,
	      input [3:0]   wrbits,
	      output [31:0] rddata,

	      input [31:0]  dbg_address,
	      input 	    dbg_read,
	      input 	    dbg_write,
	      input [31:0]  dbg_in,
	      output [31:0] dbg_out);

   wire 		    sel_a = address[31:16] == 16'h1000;
   wire 		    sel_b = dbg_address[31:16] == 16'h1000;
   mem64kd mem(.clock(clock),
	       .address_a(address[15:2]),
	       .address_b(dbg_address[15:2]),
	       .byteena_a(wrbits),
	       .data_a(wrdata),
	       .data_b(dbg_in),
	       .wren_a(write & sel_a),
	       .wren_b(dbg_write & sel_b),
	       .q_a(rddata),
	       .q_b(dbg_out));

endmodule // memory
