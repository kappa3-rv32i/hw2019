#! /usr/bin/env python3

from inst import Inst

filename = 'sample1_7seg.hex'

program = []
program.append( Inst.LUI(5, 0x04000000) )
program.append( Inst.ADDI(10, 0, 0xff) )
program.append( Inst.SB(5, 10, 0x00) )
program.append( Inst.JAL(0, -4*2) )

# generate assembly
#print('')
print('sample program 1')
for i in program :
    print('{:08x} | {}'.format(i.gen_code(), i.gen_mnemonic()))

# generate intel hex format
with open(filename, 'w', encoding='utf-8') as file:
    for offset, inst in enumerate(program) :
        file.write(inst.gen_HEX(offset))
        file.write("\n")
    file.write(':00000001FF\n')
