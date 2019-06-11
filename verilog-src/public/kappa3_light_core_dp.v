
// @file kappa3_light_core_dp.v
// @breif KAPPA3-LIGHT のデータパス
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// KAPPA3-LIGHT のデータパス(正確にはレジスタとメモリ)のみのモジュール
// debugger で各レジスタにアクセスすることを目的としている．
//
// [入出力]
// clock:         クロック
// clock2:        clock を2分周したもの
// reset:         リセット
// run:           実行開始
// step_phase:    フェイズごとの実行
// step_inst:     命令ごとの実行
// cstate:        制御状態信号
// running:       実行中を示すフラグ
// dbg_in:        デバッグ用の書込みデータ
// dbg_pc_ld:     デバッグ用のPCの書込みイネーブル
// dbg_ir_ld:     デバッグ用のIRの書込みイネーブル
// dbg_reg_ld:    デバッグ用のレジスタファイルの書込みイネーブル
// dbg_reg_addr:  デバッグ用のレジスタファイルのアドレス
// dbg_a_ld:      デバッグ用のAレジスタの書込みイネーブル
// dbg_b_ld:      デバッグ用のBレジスタの書込みイネーブル
// dbg_c_ld:      デバッグ用のCレジスタの書込みイネーブル
// dbg_mem_addr:  デバッグ用のメモリアドレス
// dbg_mem_read:  デバッグ用のメモリ読み出しイネーブル
// dbg_mem_write: デバッグ用のメモリ書込みイネーブル
// dbg_pc_out:    デバッグ用のPC出力
// dbg_ir_out:    デバッグ用のIR出力
// dbg_reg_out:   デバッグ用のレジスタファイル出力
// dbg_a_out:     デバッグ用のAレジスタ出力
// dbg_b_out:     デバッグ用のBレジスタ出力
// dbg_c_out:     デバッグ用のCレジスタ出力
// dbg_mem_out:   デバッグ用のメモリ出力
module kappa3_light_core(input 	       clock,
			 input 	       clock2,
			 input 	       reset,

			 // 実行制御
			 input 	       run,
			 input 	       step_phase,
			 input 	       step_inst,

			 output [3:0]  cstate,
			 output        running,

			 // デバッグ関係
			 input [31:0]  dbg_in,
			 input 	       dbg_pc_ld,
			 input 	       dbg_ir_ld,
			 input 	       dbg_reg_ld,
			 input [4:0]   dbg_reg_addr,
			 input 	       dbg_a_ld,
			 input 	       dbg_b_ld,
			 input 	       dbg_c_ld,
			 input [31:0]  dbg_mem_addr,
			 input 	       dbg_mem_read,
			 input 	       dbg_mem_write,
			 output [31:0] dbg_pc_out,
			 output [31:0] dbg_ir_out,
			 output [31:0] dbg_reg_out,
			 output [31:0] dbg_a_out,
			 output [31:0] dbg_b_out,
			 output [31:0] dbg_c_out,
			 output [31:0] dbg_mem_out);

   // デバッグモードの信号
   wire 			       dbg_mode;
   assign dbg_mode = !running;

   // PC
   wire [31:0] 			pc_in;       // PC の書き込みデータ
   wire 			pc_ld;       // PC の書き込みイネーブル信号
   wire [31:0] 			pc;          // PC の値
   reg32 pc_inst(.clock(clock2),
		 .reset(reset),
		 .in(pc_in),
		 .ld(pc_ld),
		 .out(pc),
		 .dbg_mode(dbg_mode),
		 .dbg_in(dbg_in),
		 .dbg_ld(dbg_pc_ld));
   assign dbg_pc_out = pc;

   // IR
   wire [31:0] 		 ir_in;      // IR の書き込みデータ
   wire 		 ir_ld;      // IR の書き込みイネーブル信号
   wire [31:0] 		 ir;         // IRの値
   reg32 ir_inst(.clock(clock2),
		 .reset(reset),
		 .in(ir_in),
		 .ld(ir_ld),
		 .out(ir),
		 .dbg_mode(dbg_mode),
		 .dbg_in(dbg_in),
		 .dbg_ld(dbg_ir_ld));
   assign dbg_ir_out = ir;

   // メモリ
   wire [31:0] 		 mem_addr;
   wire 		 mem_write;
   wire [31:0] 		 mem_wrdata;
   wire [3:0] 		 mem_wrbits;
   wire [31:0] 		 mem_rddata;
   memory mem_inst(.clock(clock),
		   .address(mem_addr),
		   .read(1'b1),
		   .write(mem_write),
		   .wrdata(mem_wrdata),
		   .wrbits(mem_wrbits),
		   .rddata(mem_rddata),
		   .dbg_address(dbg_mem_addr),
		   .dbg_read(dbg_mem_read),
		   .dbg_write(dbg_mem_write),
		   .dbg_in(dbg_in),
		   .dbg_out(dbg_mem_out));

   // reg-file
   wire [4:0] 		 rs1_addr;     // rs1 のアドレス
   wire [4:0] 		 rs2_addr;     // rs2 のアドレス
   wire [4:0] 		 rd_addr;      // rd のアドレス
   wire [31:0] 		 rd_in;        // rd に書き込む値
   wire                  rd_ld;        // rd の書込みイネーブル信号
   wire [31:0] 		 rs1;          // rs1 の値
   wire [31:0] 		 rs2;          // rs2 の値
   regfile regfile_inst(.clock(clock2),
			.reset(reset),
			.rs1_addr(rs1_addr),
			.rs2_addr(rs2_addr),
			.rd_addr(rd_addr),
			.in(rd_in),
			.ld(rd_ld),
			.rs1_out(rs1),
			.rs2_out(rs2),
			.dbg_mode(dbg_mode),
			.dbg_in(dbg_in),
			.dbg_addr(dbg_reg_addr),
			.dbg_ld(dbg_reg_ld),
			.dbg_out(dbg_reg_out));

   // A-reg
   wire                  a_ld;         // A-reg の書込みイネーブル信号
   wire [31:0] 		 areg;         // A-reg の値
   reg32 areg_inst(.clock(clock2),
		   .reset(reset),
		   .in(rs1),
		   .ld(a_ld),
		   .out(areg),
		   .dbg_mode(dbg_mode),
		   .dbg_in(dbg_in),
		   .dbg_ld(dbg_a_ld));
   assign dbg_a_out = areg;

   // B-reg
   wire                  b_ld;         // B-reg の書込みイネーブル信号
   wire [31:0] 		 breg;         // B-reg の値
   reg32 breg_inst(.clock(clock2),
		   .reset(reset),
		   .in(rs2),
		   .ld(b_ld),
		   .out(breg),
		   .dbg_mode(dbg_mode),
		   .dbg_in(dbg_in),
		   .dbg_ld(dbg_b_ld));
   assign dbg_b_out = breg;

   // ALU
   wire [31:0] 		 alu_out;      // ALU の出力
   // 実際にはここに alu のインスタンス記述が入る．

   // C-reg
   wire                  c_ld;         // C-reg の書込みイネーブル信号
   wire [31:0] 		 creg;         // C-reg の値
   reg32 creg_inst(.clock(clock2),
		   .reset(reset),
		   .in(alu_out),
		   .ld(c_ld),
		   .out(creg),
		   .dbg_mode(dbg_mode),
		   .dbg_in(dbg_in),
		   .dbg_ld(dbg_c_ld));
   assign dbg_c_out = creg;

   // 制御信号はすべて0にしておく．
   assign pc_in = 32'b0;
   assign pc_ld = 1'b0;
   assign ir_in = 32'b0;
   assign ir_ld = 1'b0;
   assign mem_addr = 32'b0;
   assign mem_write = 1'b0;
   assign mem_wrdata = 32'b0;
   assign mem_wrbits = 4'b0;
   assign rs1_addr = 5'b0;
   assign rs2_addr = 5'b0;
   assign rd_addr = 5'b0;
   assign rd_in = 32'b0;
   assign rd_ld = 1'b0;
   assign a_ld = 1'b0;
   assign b_ld = 1'b0;
   assign alu_out = 32'b0;
   assign c_ld = 1'b0;
   assign cstate = 4'b0000; // この値もダミー

   // running は実際には phasegen の出力を用いる．
   // phasegen phasegen_inst(.clock(clock2), .reset(reset),
   //			  .run(run), .step_phase(step_phase), .step_inst(step_inst),
   //			  .cstate(cstate), .running(running));
   assign running = 1'b0;

endmodule // kappa3_light_core
