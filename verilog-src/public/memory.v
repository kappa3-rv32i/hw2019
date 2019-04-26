
// @file memory.v
// @breif メモリモジュール
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// * 16Kバイトのメモリブロックを4つ(=64Kバイト)用いる．
// * 読み出すときには4つのメモリから読み出した値を連結する．
// * 書き込むときには wrbits で指定されたブロックにのみ書き込む．
// * 実は read 信号は用いられない．
// * 書き込みは dbg_write が write より優先する．
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
	      input [31:0]  dbg_in);

   // 本当のアドレス
   // address と dbg_address から適切な方を選ぶ
   wire [31:0]		    eaddress;

   // 本当の wrdata
   wire [31:0] 		    ewrdata;

   // 本当の wribts
   // デバッグモードでは常に全バイト書き込む．
   wire [3:0] 		    ewrbits;

   // address が範囲内にある時 1 になる信号
   wire 		    select;

   // 各メモリブロックごとの書込みイネーブル信号
   wire 		    wr0, wr1, wr2, wr3;

   // 16k のメモリブロック x 4
   mem16k mem0(.clock(clock),
	       .address(eaddress[15:2]),
	       .wren(wr0),
	       .data(ewrdata[7:0]),
	       .q(rddata[7:0]));

   mem16k mem1(.clock(clock),
	       .address(eaddress[15:2]),
	       .wren(wr1),
	       .data(ewrdata[15:8]),
	       .q(rddata[15:8]));

   mem16k mem2(.clock(clock),
	       .address(eaddress[15:2]),
	       .wren(wr2),
	       .data(ewrdata[23:16]),
	       .q(rddata[23:16]));

   mem16k mem3(.clock(clock),
	       .address(eaddress[15:2]),
	       .wren(wr3),
	       .data(ewrdata[31:24]),
	       .q(rddata[31:24]));

   assign eaddress = (dbg_read || dbg_write) ? dbg_address : address;
   assign ewrdata = (dbg_write) ? dbg_in : wrdata;
   assign ewrbits = (dbg_write) ? 4'b1111 : wrbits;
   assign select = eaddress[31:16] == 30'b0000_0000_0000_0000;
   assign wr0 = select & ewrbits[0];
   assign wr1 = select & ewrbits[1];
   assign wr2 = select & ewrbits[2];
   assign wr3 = select & ewrbits[3];

endmodule // memory
