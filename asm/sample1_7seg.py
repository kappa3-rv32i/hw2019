from inst import Inst, asm, print_asm, print_ihex

program = [
    Inst.LUI(5, 0x04000000),  # r5 に7 セグのアドレスを代入
    Inst.ADDI(10, 0, 0x60),   # セグ「1」のパタンをr10 に代入
    Inst.SB(5, 10, 0x00),     # r5[0] = 0x60 (7 セグのアドレスに0x60 をストア)
    Inst.JAL(0, -4*1)         # 1 命令前に無条件分岐
]

r = asm(program)
print_asm(r)
print()
print_ihex(r)
