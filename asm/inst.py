#! /usr/bin/env python3

### @file inst.py
### @brief RISC-V の命令を表すクラス
### @author Yusuke Matsunaga (松永 裕介)
###
### Copyright (C) 2018 Yusuke Matsunaga
### All rights reserved.

from enum import Enum

labeltbl = {}

### @brief オプコードの定義
class Opcode(Enum) :
    LUI   = 0b0110111
    AUIPC = 0b0010111
    JAL   = 0b1101111
    JALR  = 0b1100111
    BEQ   = 0b1100011
    BNE   = 0b1100011
    BLT   = 0b1100011
    BGE   = 0b1100011
    BLTU  = 0b1100011
    BGEU  = 0b1100011
    LB    = 0b0000011
    LH    = 0b0000011
    LW    = 0b0000011
    LBU   = 0b0000011
    LHU   = 0b0000011
    SB    = 0b0100011
    SH    = 0b0100011
    SW    = 0b0100011
    SBU   = 0b0100011
    SHU   = 0b0100011
    ADDI  = 0b0010011
    SLTI  = 0b0010011
    SLTIU = 0b0010011
    XORI  = 0b0010011
    ORI   = 0b0010011
    ANDI  = 0b0010011
    SLLI  = 0b0010011
    SRLI  = 0b0010011
    SRAI  = 0b0010011
    ADD   = 0b0110011
    SUB   = 0b0110011
    SLL   = 0b0110011
    SLT   = 0b0110011
    SLTU  = 0b0110011
    XOR   = 0b0110011
    SRL   = 0b0110011
    SRA   = 0b0110011
    OR    = 0b0110011
    AND   = 0b0110011


### @brief Funct3 フィールドの定義
class Funct3(Enum) :

    JALR  = 0b000
    BEQ   = 0b000
    BNE   = 0b001
    BLT   = 0b100
    BGE   = 0b101
    BLTU  = 0b110
    BGEU  = 0b111
    LB    = 0b000
    LH    = 0b001
    LW    = 0b010
    LBU   = 0b100
    LHU   = 0b101
    SB    = 0b000
    SH    = 0b001
    SW    = 0b010
    ADDI  = 0b000
    SLTI  = 0b010
    SLTIU = 0b011
    XORI  = 0b100
    ORI   = 0b110
    ANDI  = 0b111
    SLLI  = 0b001
    SRLI  = 0b101
    SRAI  = 0b101
    ADD   = 0b000
    SUB   = 0b000
    SLL   = 0b001
    SLT   = 0b010
    SLTU  = 0b011
    XOR   = 0b100
    SRL   = 0b101
    SRA   = 0b101
    OR    = 0b110
    AND   = 0b111

### @brief Funct7 フィールドの定義
class Funct7(Enum) :

    ADD   = 0b0000000
    SUB   = 0b0100000
    SLL   = 0b0000000
    SLT   = 0b0000000
    SLTU  = 0b0000000
    XOR   = 0b0000000
    SRL   = 0b0000000
    SRA   = 0b0100000
    OR    = 0b0000000
    AND   = 0b0000000


### @brief 命令からスライスを切り出す．
### @param[in] src 32ビットのビットベクタ
### @param[in] msb 切り出すスライスの msb
### @param[in] lsb 切り出すスライスの lsb
def part(src, msb, lsb) :
    mask = 0
    for i in range(lsb, msb + 1) :
        mask |= (1 << i)
    ans = src & mask
    ans >>= lsb
    return ans


### @brief 指定されたビット幅の２進数(2の補数表現)に変換する．
### @param[in] src 変換する値
### @param[in] bw ビット幅
def pack(src, bw) :
    mask = 0
    for i in range(bw - 1) :
        mask |= (1 << i)
    m_src = src & mask
    if src & (1 << (bw - 1)) :
        return (1 << (bw - 1)) + m_src
    else :
        return m_src


### @brief 符号拡張を行う．
### @param[in] src 変換する値
### @param[in] bw ビット幅
def unpack(src, bw) :
    if src & (1 << (bw - 1)) :
        mask = 0
        for i in range(bw - 1) :
            mask |= (1 << i)
            m_src = src & mask
        return m_src - (1 << (bw - 1))
    else :
        return src

### @brief レジスタ名を表す文字列を返す．
### @param[in] reg_id レジスタ番号
def reg_name(reg_id) :
    return "x{:02d}".format(reg_id)


### @brief 即値を表す文字列を返す．
### @param[in] imm 即値
def imm_str(imm) :
    return "{:x}h".format(imm)


### @brief RISC-V の命令を表すクラス
class Inst :

    ### @brief 初期化
    def __init__(self, opcode) :
        # 命令によっては None のままのメンバもある．
        self.__opcode = opcode
        self.__funct3 = None
        self.__funct7 = None
        self.__rd = None
        self.__rs1 = None
        self.__rs2 = None
        self.__I_31_20 = None  # [11: 0]
        self.__S_31_25 = None  # [11: 5]
        self.__S_11_07 = None  # [ 4: 0]
        self.__B_31_31 = None  # [12:12]
        self.__B_30_25 = None  # [10: 5]
        self.__B_11_08 = None  # [ 4: 1]
        self.__B_07_07 = None  # [11:11]
        self.__U_31_12 = None  # [31:12]
        self.__J_31_31 = None  # [20:20]
        self.__J_30_21 = None  # [10:01]
        self.__J_20_20 = None  # [11:11]
        self.__J_19_12 = None  # [19:12]

        self.__cont = False
#        self.__pc = 0x1000 # for debug

    ### @brief LUI命令を作る．
    @staticmethod
    def LUI(rd, imm) :
        return Inst.__Utype(Opcode.LUI, rd, imm)

    ### @brief AUIPC命令を作る．
    @staticmethod
    def AUIPC(rd, imm) :
        return Inst.__Utype(Opcode.AUIPC, rd, imm)

    ### @brief JAL命令を作る．
    @staticmethod
    def JAL(rd, imm) :
        return Inst.__Jtype(Opcode.JAL, rd, imm)

    ### @brief JAL命令を作る．(ラベル対応)
    @staticmethod
    def LJAL(rd, label) :
        return Inst.__LJtype(Opcode.JAL, rd, label)

    ### @brief JALR命令を作る．
    @staticmethod
    def JALR(rd, rs1, imm) :
        return Inst.__Itype(Opcode.JALR, Funct3.JALR, rd, rs1, imm)

    ### @brief BEQ命令を作る．
    @staticmethod
    def BEQ(rs1, rs2, imm) :
        return Inst.__Btype(Opcode.BEQ, Funct3.BEQ, rs1, rs2, imm)

    ### @brief Label BEQ命令を作る．
    @staticmethod
    def LBEQ(rs1, rs2, label) :
        return Inst.__LBtype(Opcode.BEQ, Funct3.BEQ, rs1, rs2, label)

    ### @brief BNE命令を作る．
    @staticmethod
    def BNE(rs1, rs2, imm) :
        return Inst.__Btype(Opcode.BEQ, Funct3.BNE, rs1, rs2, imm)

    ### @brief Label BNE命令を作る．
    @staticmethod
    def LBNE(rs1, rs2, label) :
        return Inst.__LBtype(Opcode.BEQ, Funct3.BNE, rs1, rs2, label)

    ### @brief BLT命令を作る．
    @staticmethod
    def BLT(rs1, rs2, imm) :
        return Inst.__Btype(Opcode.BEQ, Funct3.BLT, rs1, rs2, imm)

    ### @brief Label BLT命令を作る．
    @staticmethod
    def LBLT(rs1, rs2, label) :
        return Inst.__LBtype(Opcode.BEQ, Funct3.BLT, rs1, rs2, label)

    ### @brief BGE命令を作る．
    @staticmethod
    def BGE(rs1, rs2, imm) :
        return Inst.__Btype(Opcode.BEQ, Funct3.BGE, rs1, rs2, imm)

    ### @brief Label BGE命令を作る．
    @staticmethod
    def LBGE(rs1, rs2, label) :
        return Inst.__LBtype(Opcode.BEQ, Funct3.BGE, rs1, rs2, label)

    ### @brief BLTU命令を作る．
    @staticmethod
    def BLTU(rs1, rs2, imm) :
        return Inst.__Btype(Opcode.BEQ, Funct3.BLTU, rs1, rs2, imm)

    ### @brief label BLTU命令を作る．
    @staticmethod
    def LBLTU(rs1, rs2, label) :
        return Inst.__LBtype(Opcode.BEQ, Funct3.BLTU, rs1, rs2, label)

    ### @brief BGEU命令を作る．
    @staticmethod
    def BGEU(rs1, rs2, imm) :
        return Inst.__Btype(Opcode.BEQ, Funct3.BGEU, rs1, rs2, imm)

    ### @brief label BGEU命令を作る．
    @staticmethod
    def LBGEU(rs1, rs2, label) :
        return Inst.__LBtype(Opcode.BEQ, Funct3.BGEU, rs1, rs2, label)

    ### @brief LB命令を作る．
    @staticmethod
    def LB(rd, rs1, imm) :
        return Inst.__Itype(Opcode.LB, Funct3.LB, rd, rs1, imm)

    ### @brief LH命令を作る．
    @staticmethod
    def LH(rd, rs1, imm) :
        return Inst.__Itype(Opcode.LH, Funct3.LH, rd, rs1, imm)

    ### @brief LW命令を作る．
    @staticmethod
    def LW(rd, rs1, imm) :
        return Inst.__Itype(Opcode.LW, Funct3.LW, rd, rs1, imm)

    ### @brief LBU命令を作る．
    @staticmethod
    def LBU(rd, rs1, imm) :
        return Inst.__Itype(Opcode.LBU, Funct3.LBU, rd, rs1, imm)

    ### @brief LHU命令を作る．
    @staticmethod
    def LHU(rd, rs1, imm) :
        return Inst.__Itype(Opcode.LHU, Funct3.LHU, rd, rs1, imm)

    ### @brief SB命令を作る．
    @staticmethod
    def SB(rs1, rs2, imm) :
        return Inst.__Stype(Opcode.SB, Funct3.SB, rs1, rs2, imm)

    ### @brief SH命令を作る．
    @staticmethod
    def SH(rs1, rs2, imm) :
        return Inst.__Stype(Opcode.SH, Funct3.SH, rs1, rs2, imm)

    ### @brief SW命令を作る．
    @staticmethod
    def SW(rs1, rs2, imm) :
        return Inst.__Stype(Opcode.SW, Funct3.SW, rs1, rs2, imm)

    ### @brief ADDI命令を作る．
    @staticmethod
    def ADDI(rd, rs1, imm) :
        return Inst.__Itype(Opcode.ADDI, Funct3.ADDI, rd, rs1, imm)

    ### @brief SLTI命令を作る．
    @staticmethod
    def SLTI(rd, rs1, imm) :
        return Inst.__Itype(Opcode.SLTI, Funct3.SLTI, rd, rs1, imm)

    ### @brief SLTIU命令を作る．
    @staticmethod
    def SLTIU(rd, rs1, imm) :
        return Inst.__Itype(Opcode.SLTIU, Funct3.SLTIU, rd, rs1, imm)

    ### @brief XORI命令を作る．
    @staticmethod
    def XORI(rd, rs1, imm) :
        return Inst.__Itype(Opcode.XORI, Funct3.XORI, rd, rs1, imm)

    ### @brief ORI命令を作る．
    @staticmethod
    def ORI(rd, rs1, imm) :
        return Inst.__Itype(Opcode.ORI, Funct3.ORI, rd, rs1, imm)

    ### @brief ANDI命令を作る．
    @staticmethod
    def ANDI(rd, rs1, imm) :
        return Inst.__Itype(Opcode.ANDI, Funct3.ANDI, rd, rs1, imm)

    ### @brief SLLI命令を作る．
    @staticmethod
    def SLLI(rd, rs1, imm) :
        return Inst.__Itype2(Opcode.SLLI, Funct3.SLLI, rd, rs1, imm, Funct7.SLL)

    ### @brief SRLI命令を作る．
    @staticmethod
    def SRLI(rd, rs1, imm) :
        return Inst.__Itype2(Opcode.SRLI, Funct3.SRLI, rd, rs1, imm, Funct7.SRL)

    ### @brief SRAI命令を作る．
    @staticmethod
    def SRAI(rd, rs1, imm) :
        return Inst.__Itype2(Opcode.SRAI, Funct3.SRAI, rd, rs1, imm, Funct7.SRA)

    ### @brief ADD命令を作る．
    @staticmethod
    def ADD(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.ADD, Funct3.ADD, Funct7.ADD, rd, rs1, rs2)

    ### @brief SUB命令を作る．
    @staticmethod
    def SUB(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.SUB, Funct3.SUB, Funct7.SUB, rd, rs1, rs2)

    ### @brief SLT命令を作る．
    @staticmethod
    def SLT(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.SLT, Funct3.SLT, Funct7.SLT, rd, rs1, rs2)

    ### @brief SLTU命令を作る．
    @staticmethod
    def SLTU(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.SLTU, Funct3.SLTU, Funct7.SLTU, rd, rs1, rs2)

    ### @brief XOR命令を作る．
    @staticmethod
    def XOR(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.XOR, Funct3.XOR, Funct7.XOR, rd, rs1, rs2)

    ### @brief OR命令を作る．
    @staticmethod
    def OR(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.OR, Funct3.OR, Funct7.OR, rd, rs1, rs2)

    ### @brief AND命令を作る．
    @staticmethod
    def AND(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.AND, Funct3.AND, Funct7.AND, rd, rs1, rs2)

    ### @brief SLL命令を作る．
    @staticmethod
    def SLL(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.SLL, Funct3.SLL, Funct7.SLL, rd, rs1, rs2)

    ### @brief SRL命令を作る．
    @staticmethod
    def SRL(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.SRL, Funct3.SRL, Funct7.SRL, rd, rs1, rs2)

    ### @brief SRA命令を作る．
    @staticmethod
    def SRA(rd, rs1, rs2) :
        return Inst.__Rtype(Opcode.SRA, Funct3.SRA, Funct7.SRA, rd, rs1, rs2)

    ### @brief R-type の命令を作る．
    @staticmethod
    def __Rtype(opcode, funct3, funct7, rd, rs1, rs2) :
        inst = Inst(opcode)
        inst.__funct3 = funct3
        inst.__funct7 = funct7
        inst.__rs1 = rs1
        inst.__rs2 = rs2
        inst.__rd = rd
        return inst

    ### @brief I-type の命令を作る．
    @staticmethod
    def __Itype(opcode, funct3, rd, rs1, imm) :
        inst = Inst(opcode)
        inst.__funct3 = funct3
        inst.__rs1 = rs1
        inst.__rd = rd
        inst.__I_31_20 = pack(imm, 12)
        return inst

    ### @brief Label I-type の命令を作る．
    @staticmethod
    def __LItype(opcode, funct3, rd, rs1, label) :
        inst = Inst(opcode)
        inst.__funct3 = funct3
        inst.__rs1 = rs1
        inst.__rd = rd
        inst.label = label
        inst.__cont = lambda self: Inst.__Itype(opcode, funct3, rd, rs1, Inst.pcrelref(self))

        return inst

    ### @brief シフト命令用の I-type の命令を作る．
    @staticmethod
    def __Itype2(opcode, funct3, rd, rs1, imm, funct7) :
        inst = Inst(opcode)
        inst.__funct3 = funct3
        inst.__rs1 = rs1
        inst.__rd = rd
        tmp = imm | (funct7.value << 5)
        inst.__I_31_20 = pack(tmp, 12)
        return inst

    ### @brief S-type の命令を作る．
    @staticmethod
    def __Stype(opcode, funct3, rs1, rs2, imm) :
        inst = Inst(opcode)
        inst.__funct3 = funct3
        inst.__rs1 = rs1
        inst.__rs2 = rs2
        p_imm = pack(imm, 12)
        inst.__S_31_25 = part(p_imm, 11, 5)
        inst.__S_11_07 = part(p_imm,  4, 0)
        return inst

    ### @brief B-type の命令を作る．
    @staticmethod
    def __Btype(opcode, funct3, rs1, rs2, imm) :
        inst = Inst(opcode)
        inst.__funct3 = funct3
        inst.__rs1 = rs1
        inst.__rs2 = rs2
        p_imm = pack(imm, 13)
        inst.__B_31_31 = part(p_imm, 12, 12)
        inst.__B_30_25 = part(p_imm, 10,  5)
        inst.__B_11_08 = part(p_imm,  4,  1)
        inst.__B_07_07 = part(p_imm, 11, 11)
        return inst

    ### @brief Label Label B-type の命令を作る．
    @staticmethod
    def __LBtype(opcode, funct3, rs1, rs2, label) :
        inst = Inst(opcode)
        inst.label = label
        inst.__cont = lambda self: Inst.__Btype(opcode, funct3, rs1, rs2, Inst.pcrelref(self))

        return inst

    ### @brief U-type の命令を作る．
    @staticmethod
    def __Utype(opcode, rd, imm) :
        inst = Inst(opcode)
        inst.__rd = rd
        inst.__U_31_12 = part(imm, 31, 12)
        return inst

    ### @brief J-type の命令を作る．
    @staticmethod
    def __Jtype(opcode, rd, imm) :
        inst = Inst(opcode)
        inst.__rd = rd
        p_imm = pack(imm, 21)
        inst.__J_31_31 = part(p_imm, 20, 20)
        inst.__J_30_21 = part(p_imm, 10,  1)
        inst.__J_20_20 = part(p_imm, 11, 11)
        inst.__J_19_12 = part(p_imm, 19, 12)
        return inst

    ### @brief Label J-type の命令を作る．
    @staticmethod
    def __LJtype(opcode, rd, label) :
        inst = Inst(opcode)
        inst.__rd = rd
        inst.label = label
        inst.__cont = lambda self: Inst.__Jtype(opcode, rd, Inst.pcrelref(self))

        return inst

    @staticmethod
    def pcrelref(self):
        return -(self.pc - labeltbl[self.label])

    ### @brief lui 命令のとき true を返す．
    def is_lui(self) :
        return self.__opcode == Opcode.LUI

    ### @brief auipc 命令のとき true を返す．
    def is_auipc(self) :
        return self.__opcode == Opcode.AUIPC

    ### @brief JAL 命令のとき true を返す．
    def is_jal(self) :
        return self.__opcode == Opcode.JAL

    ### @brief JALR 命令のとき true を返す．
    def is_jalr(self) :
        return self.__opcode == Opcode.JALR

    ### @brief 分岐命令(BEQ, BNE, BLT, BGE, BLTU, BGEU)のとき true を返す．
    def is_branch(self) :
        return self.__opcode == Opcode.BEQ

    ### @brief BEQ 命令のとき true を返す．
    def is_beq(self) :
        return self.is_branch() and self.__funct3 == Funct3.BEQ

    ### @brief BNE 命令のとき true を返す．
    def is_bne(self) :
        return self.is_branch() and self.__funct3 == Funct3.BNE

    ### @brief BLT 命令のとき true を返す．
    def is_blt(self) :
        return self.is_branch() and self.__funct3 == Funct3.BLT

    ### @brief BGE 命令のとき true を返す．
    def is_bge(self) :
        return self.is_branch() and self.__funct3 == Funct3.BGE

    ### @brief BLTU 命令のとき true を返す．
    def is_bltu(self) :
        return self.is_branch() and self.__funct3 == Funct3.BLTU

    ### @brief BGEU 命令のとき true を返す．
    def is_bgeu(self) :
        return self.is_branch() and self.__funct3 == Funct3.BGEU

    ### @brief ロード命令(LB, LH, LW, LBU, LHU)のとき true を返す．
    def is_load(self) :
        return self.__opcode == Opcode.LB

    ### @brief LB 命令のとき true を返す．
    def is_lb(self) :
        return self.is_load() and self.__funct3 == Funct3.LB

    ### @brief LH 命令のとき true を返す．
    def is_lh(self) :
        return self.is_load() and self.__funct3 == Funct3.LH

    ### @brief LW 命令のとき true を返す．
    def is_lw(self) :
        return self.is_load() and self.__funct3 == Funct3.LW

    ### @brief LBU 命令のとき true を返す．
    def is_lbu(self) :
        return self.is_load() and self.__funct3 == Funct3.LBU

    ### @brief LHU 命令のとき true を返す．
    def is_lhu(self) :
        return self.is_load() and self.__funct3 == Funct3.LHU

    ### @brief ストア命令(SB, SH, SW)のとき true を返す．
    def is_store(self) :
        return self.__opcode == Opcode.SB

    ### @brief SB 命令のとき true を返す．
    def is_sb(self) :
        return self.is_store() and self.__funct3 == Funct3.SB

    ### @brief SH 命令のとき true を返す．
    def is_sh(self) :
        return self.is_store() and self.__funct3 == Funct3.SH

    ### @brief SW 命令のとき true を返す．
    def is_sw(self) :
        return self.is_store() and self.__funct3 == Funct3.SW

    ### @brief 即値演算命令のとき true を返す．
    def is_imm_op(self) :
        return self.__opcode == Opcode.ADDI

    ### @brief ADDI 命令のとき true を返す．
    def is_addi(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.ADDI

    ### @brief SLTI 命令のとき true を返す．
    def is_slti(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.SLTI

    ### @brief SLTIU 命令のとき true を返す．
    def is_sltiu(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.SLTIU

    ### @brief XORI 命令のとき true を返す．
    def is_xori(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.XORI

    ### @brief ORI 命令のとき true を返す．
    def is_ori(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.ORI

    ### @brief ANDI 命令のとき true を返す．
    def is_andi(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.ANDI

    ### @brief SLLI 命令のとき true を返す．
    def is_slli(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.SLLI

    ### @brief SRLI 命令のとき true を返す．
    def is_srli(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.SRLI and self.__funct7 == Funct7.SRL

    ### @brief SRAI 命令のとき true を返す．
    def is_srai(self) :
        return self.is_imm_op() and self.__funct3 == Funct3.SRLI and self.__funct7 == Funct7.SRA

    ### @brief レジスタ演算命令のとき true を返す．
    def is_reg_op(self) :
        return self.__opcode == Opcode.ADD

    ### @brief ADD 命令のとき true を返す．
    def is_add(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.ADD and self.__funct7 == Funct7.ADD

    ### @brief SUB 命令のとき true を返す．
    def is_sub(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.ADD and self.__funct7 == Funct7.SUB

    ### @brief SLL 命令のとき true を返す．
    def is_sll(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.SLL and self.__funct7 == Funct7.SLL

    ### @brief SRL 命令のとき true を返す．
    def is_srl(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.SRL and self.__funct7 == Funct7.SRL

    ### @brief SRA 命令のとき true を返す．
    def is_sra(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.SRA and self.__funct7 == Funct7.SRA

    ### @brief SLT 命令のとき true を返す．
    def is_slt(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.SLT

    ### @brief SLTU 命令のとき true を返す．
    def is_sltu(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.SLTU

    ### @brief XOR 命令のとき true を返す．
    def is_xor(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.XOR

    ### @brief OR 命令のとき true を返す．
    def is_or(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.OR

    ### @brief AND 命令のとき true を返す．
    def is_and(self) :
        return self.is_reg_op() and self.__funct3 == Funct3.AND

    ### @brief I-type の即値を取り出す．
    def get_I_imm(self) :
        return imm_str(unpack(self.__I_31_20, 12))

    ### @brief S-type の即値を取り出す．
    def get_S_imm(self) :
        return imm_str(unpack((self.__S_31_25 << 5) | self.__S_11_07, 12))

    ### @brief B-type の即値を取り出す．
    def get_B_imm(self) :
        return imm_str(unpack((self.__B_31_31 << 12) | (self.__B_30_25 << 5) | (self.__B_11_08 << 1) | (self.__B_07_07 << 11), 13))

    ### @brief U-type の即値を取り出す．
    def get_U_imm(self) :
        return imm_str((self.__U_31_12 << 12))

    ### @brief J-type の即値を取り出す．
    def get_J_imm(self) :
        return imm_str(unpack((self.__J_31_31 << 20) | (self.__J_30_21 << 1) | (self.__J_20_20 << 11) | (self.__J_19_12 << 12), 21))

    ### @brief コードを出力する．
    def gen_code(self) :
        code = self.__opcode.value
        if self.__funct3 :
            code |= (self.__funct3.value << 12)
        if self.__funct7 :
            code |= (self.__funct7.value << 25)
        if self.__rd :
            code |= (self.__rd << 7)
        if self.__rs1 :
            code |= (self.__rs1 << 15)
        if self.__rs2 :
            code |= (self.__rs2 << 20)
        if self.__I_31_20 :
            code |= (self.__I_31_20 << 20)
        if self.__S_31_25 :
            code |= (self.__S_31_25 << 25)
        if self.__S_11_07 :
            code |= (self.__S_11_07 << 7)
        if self.__B_31_31 :
            code |= (self.__B_31_31 << 31)
        if self.__B_30_25 :
            code |= (self.__B_30_25 << 25)
        if self.__B_11_08 :
            code |= (self.__B_11_08 << 8)
        if self.__B_07_07 :
            code |= (self.__B_07_07 << 7)
        if self.__U_31_12 :
            code |= (self.__U_31_12 << 12)
        if self.__J_31_31 :
            code |= (self.__J_31_31 << 31)
        if self.__J_30_21 :
            code |= (self.__J_30_21 << 21)
        if self.__J_20_20 :
            code |= (self.__J_20_20 << 20)
        if self.__J_19_12 :
            code |= (self.__J_19_12 << 12)
        return code

    ### @brief intel HEX フォーマットの行を出力する．
    def gen_HEX(self, offset) :
        data_size = 0x04
        offset_h = (offset >> 8) & 0xFF
        offset_l = offset & 0xFF
        record_type = 0x00
        code = self.gen_code()
        code_3 = (code >> 24) & 0xFF
        code_2 = (code >> 16) & 0xFF
        code_1 = (code >>  8) & 0xFF
        code_0 = code & 0xFF
        record = []
        record.append(data_size)
        record.append(offset_h)
        record.append(offset_l)
        record.append(record_type)
        record.append(code_3)
        record.append(code_2)
        record.append(code_1)
        record.append(code_0)
        s = 0
        line = ':'
        for b in record :
            s += b
            line += '{:02X}'.format(b)
        cs = (~s + 1) & 0xFF
        line += '{:02X}'.format(cs)
        return line

    ### @brief ニーモニックに変換する．
    def gen_mnemonic(self) :
        opcode = self.__opcode
        if opcode == Opcode.LB :
            inst_type = 'I'
            funct3 = self.__funct3
            if funct3 == Funct3.LB :
                op = 'LB'
            elif funct3 == Funct3.LH :
                op = 'LH'
            elif funct3 == Funct3.LW :
                op = 'LW'
            elif funct3 == Funct3.LBU :
                op = 'LBU'
            elif funct3 == Funct3.LHU :
                op = 'LHU'
            else :
                op = '---'
        elif opcode == Opcode.ADDI :
            inst_type = 'I'
            funct3 = self.__funct3
            if funct3 == Funct3.ADDI :
                op = 'ADDI'
            elif funct3 == Funct3.SLTI :
                op = 'SLTI'
            elif funct3 == Funct3.SLTIU :
                op = 'SLTIU'
            elif funct3 == Funct3.XORI :
                op = 'XORI'
            elif funct3 == Funct3.ORI :
                op = 'ORI'
            elif funct3 == Funct3.ANDI :
                op = 'ANDI'
            elif funct3 == Funct3.SLLI :
                inst_type = 'I2'
                shamt = part(self.__I_31_20, 4, 0)
                op = 'SLLI'
            elif funct3 == Funct3.SRLI :
                inst_type = 'I2'
                tmp = part(self.__I_31_20, 11, 5)
                shamt = part(self.__I_31_20, 4, 0)
                if tmp == 0b0000000 :
                    op = 'SRLI'
                elif tmp == 0b0100000 :
                    op = 'SRAI'
                else :
                    op = '---'
        elif opcode == Opcode.AUIPC :
            inst_type = 'U'
            op = 'AUIPC'
        elif opcode == Opcode.SB :
            inst_type = 'S'
            funct3 = self.__funct3
            if funct3 == Funct3.SB :
                op = 'SB'
            elif funct3 == Funct3.SH :
                op = 'SH'
            elif funct3 == Funct3.SW :
                op = 'SW'
            else :
                op = '---'
        elif opcode == Opcode.ADD :
            inst_type = 'R'
            funct3 = self.__funct3
            if funct3 == Funct3.ADD :
                funct7 = self.__funct7
                if funct7 == Funct7.ADD :
                    op = 'ADD'
                elif funct7 == Funct7.SUB :
                    op = 'SUB'
                else :
                    op = '---'
            elif funct3 == Funct3.SLL :
                op = 'SLL'
            elif funct3 == Funct3.SLT :
                op = 'SLT'
            elif funct3 == Funct3.SLTU :
                op = 'SLTU'
            elif funct3 == Funct3.XOR :
                op = 'XOR'
            elif funct3 == Funct3.SRL :
                funct7 = self.__funct7
                if funct7 == Funct7.SRL :
                    op = 'SRL'
                elif funct7 == Funct7.SRA :
                    op = 'SRA'
                else :
                    op = '---'
            elif funct3 == Funct3.OR :
                op = 'OR'
            elif funct3 == Funct3.AND :
                op = 'AND'
        elif opcode == Opcode.LUI :
            inst_type = 'U'
            op = 'LUI'
        elif opcode == Opcode.BEQ :
            inst_type = 'B'
            funct3 = self.__funct3
            if funct3 == Funct3.BEQ :
                op = 'BEQ'
            elif funct3 == Funct3.BNE :
                op = 'BNE'
            elif funct3 == Funct3.BLT :
                op = 'BLT'
            elif funct3 == Funct3.BGE :
                op = 'BGE'
            elif funct3 == Funct3.BLTU :
                op = 'BLTU'
            elif funct3 == Funct3.BGEU :
                op = 'BGEU'
            else :
                op = '---'
        elif opcode == Opcode.JALR :
            inst_type = 'I'
            op = 'JALR'
        elif opcode == Opcode.JAL :
            inst_type = 'J'
            op = 'JAL'
        else :
            inst_type = '-'
            op = '---'

        line = '{:5} '.format(op)
        if inst_type == 'R' :
            line += '{0}, {1}, {2}'.format(reg_name(self.__rd), reg_name(self.__rs1), reg_name(self.__rs2))
        elif inst_type == 'I' :
            imm = self.get_I_imm()
            line += '{0}, {1}, {2}'.format(reg_name(self.__rd), reg_name(self.__rs1), imm)
        elif inst_type == 'I2' :
            line += '{0}, {1}, {2}'.format(reg_name(self.__rd), reg_name(self.__rs1), shamt)
        elif inst_type == 'S' :
            imm = self.get_S_imm()
            line += '{0}, {1}, {2}'.format(reg_name(self.__rs1), reg_name(self.__rs2), imm)
        elif inst_type == 'B' :
            imm = self.get_B_imm()
            line += '{0}, {1}, {2}'.format(reg_name(self.__rs1), reg_name(self.__rs2), imm)
        elif inst_type == 'U' :
            imm = self.get_U_imm()
            line += '{0}, {1}'.format(reg_name(self.__rd), imm)
        elif inst_type == 'J' :
            imm = self.get_J_imm()
            line += '{0}, {1}'.format(reg_name(self.__rd), imm)
        else :
            line += ' ---'

        return line

    def force(self):
        if self.__cont:
            return self.__cont(self)
        else:
            return self

def asm(program):
    # pass1: make symbol table
    pc = 0x10000000
    for inst in program:
        if type(inst) is str:
            # label
            labeltbl[inst] = pc
        else:
            # instruction
            inst.pc = pc
            pc += 4

    # pass2: resolve and remove labels
    program = [inst.force() for inst in program if type(inst) is not str]

    return program

def print_asm(program):
    for i in program :
        print('{:08x} | {}'.format(i.gen_code(), i.gen_mnemonic()))

def print_ihex(program):
    for offset, inst in enumerate(program) :
        print(inst.gen_HEX(offset))
    print(':00000001FF\n')

if __name__ == '__main__' :

    def inst_test(inst, inst_str) :
        print('{0:30} = {1:032b} | {2}'.format(inst_str, inst.gen_code(), inst.gen_mnemonic()))

    inst_test(Inst.LUI(1, 0x12345000), 'LUI(x1, 0x12345000)')
    inst_test(Inst.AUIPC(2, 0x23456000), 'AUIPC(x2, 0x23456000)')
    inst_test(Inst.JAL(3, 0x65432), 'JAL(x3, 0x65432)')
    inst_test(Inst.JALR(4, 11, 0x555), 'JALR(x4, x11, 0x555)')
    inst_test(Inst.BEQ(3, 4, -4), 'BEQ(x3, x4, -4)')
    inst_test(Inst.BNE(5, 6, 0x434), 'BNE(x5, x6, 0x0434)')
    inst_test(Inst.BLT(7, 8, -0x876), 'BLT(x7, x8, -0x876)')
    inst_test(Inst.BGE(9, 10, 0xbcc), 'BGE(x9, x10, 0x0bcc)')
    inst_test(Inst.BLTU(11, 12, -0xedc), 'BLTU(x11, x12, -0xedc)')
    inst_test(Inst.BGEU(13, 14, 0xaaa), 'BGEU(x13, x14, 0xaaa)')
    inst_test(Inst.LB(15, 16, 0x456), 'LB(x15, x16, 0x456)')
    inst_test(Inst.LH(17, 18, 0x987), 'LH(x17, x18, 0x987)')
    inst_test(Inst.LW(19, 20, 0xabc), 'LW(x19, x20, 0xabc)')
    inst_test(Inst.LBU(21, 22, 0xdef), 'LBU(x21, x22, 0xdef)')
    inst_test(Inst.LHU(23, 24, 0x111), 'LHU(x23, x24, 0x111)')
    inst_test(Inst.SB(25, 26, 0x222), 'SB(x25, x26, 0x222)')
    inst_test(Inst.SH(27, 28, 0x333), 'SH(x27, x28, 0x333)')
    inst_test(Inst.SW(29, 30, 0x444), 'SW(x29, x30, 0x444)')
    inst_test(Inst.ADDI(6, 5, 10), 'ADDI(x6, x5, 10)')
    inst_test(Inst.SLTI(0, 31, 0x555), 'SLTI(x0, x31, 0x555)')
    inst_test(Inst.SLTIU(1, 30, 0x666), 'SLTIU(x1, x30, 0x666)')
    inst_test(Inst.XORI(2, 29, 0x777), 'XORI(x2, x29, 0x777)')
    inst_test(Inst.ORI(3, 28, 0x888), 'ORI(x3, x28, 0x888)')
    inst_test(Inst.ANDI(4, 27, 0x999), 'ANDI(x4, x27, 0x999)')
    inst_test(Inst.SLLI(5, 26, 0xa), 'SLLI(x5, x26, 0xa)')
    inst_test(Inst.SRLI(6, 25, 0xb), 'SRLI(x6, x25, 0xb)')
    inst_test(Inst.SRAI(7, 24, 0xc), 'SRAI(x7, x24, 0xc)')
    inst_test(Inst.ADD(8, 9, 10), 'ADD(x8, x9, x10)')
    inst_test(Inst.SUB(11, 12, 13), 'SUB(x11, x12, x13)')
    inst_test(Inst.SLL(14, 15, 16), 'SLL(x14, x15, x16)')
    inst_test(Inst.SLT(17, 18, 19), 'SLT(x17, x18, x19)')
    inst_test(Inst.SLTU(20, 21, 22), 'SLTU(x20, x21, x22)')
    inst_test(Inst.XOR(23, 24, 25), 'XOR(x23, x24, x25)')
    inst_test(Inst.SRL(26, 27, 28), 'SRL(x26, x27, x28)')
    inst_test(Inst.SRA(29, 30, 31), 'SRA(x29, x30, x31)')
    inst_test(Inst.OR(1, 2, 3), 'OR(x1, x2, x3)')
    inst_test(Inst.AND(4, 5, 6), 'AND(x4, x5, x6)')
