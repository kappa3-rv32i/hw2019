#! /usr/bin/env python3

from inst import Inst

program = []
program.append( Inst.LUI(5, 0x04000000) )
program.append( Inst.ADDI(10, 0, 0xff) )
program.append( Inst.SB(5, 10, 0x00) )
program.append( Inst.JAL(0, -4*2) )

# generate assembly
#print('')
#print('sample program 3')
#for i in program :
#    print('{:08x} | {}'.format(i.gen_code(), i.gen_mnemonic()))

# generate intel hex format
for offset, inst in enumerate(program) :
    print(inst.gen_HEX(offset))
print(':00000001FF')
