#!/usr/bin/env python3
import struct
from binascii import hexlify

# preencha os vetores abaixo
a = [ 1.5, 4.,   2.  ]
b = [ 2.,  0.25, 0.1 ]

def save(vec, fname):
    with open(fname, 'wb') as f:
        for x in vec:
            f.write(b'%s\n' % hexlify(struct.pack('>f', x)))

save(a, 'a.hex')
save(b, 'b.hex')

print('resultado esperado: %.4f' % sum(xa*xb for xa,xb in zip(a,b)))
