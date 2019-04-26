
// @file ldconv.v
// @breif ldconv(ロードデータ変換器)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// ロードのデータタイプに応じてデータを変換する．
// 具体的には以下の処理を行う．
//
// * B(byte) タイプ
//   オフセットに応じたバイトを取り出し，符号拡張を行う．
// * BU(byte unsigned) タイプ
//   オフセットに応じたバイトを取り出し，上位に0を詰める．
// * H(half word) タイプ
//   オフセットに応じたハーフワード(16ビット)を取り出し，符号拡張を行う．
// * HU(half word unsigned) タイプ
//   オフセットに応じたハーフワード(16ビット)を取り出し，上位に0を詰める．
// * W(word) タイプ
//   そのままの値を返す．
//
// B, BU, H, HU, W タイプの判別は IR レジスタの内容で行う．
//
// [入出力]
// in:     入力(32ビット)
// ir:     IRレジスタの値
// offset: アドレスオフセット
// out:    出力(32ビット)
module ldconv(input [31:0]      in,
	      input [31:0] 	ir,
	      input [1:0] 	offset,
	      output reg [31:0] out);

endmodule; // ldconv
