#!/usr/bin/env python3
import sys
import re
import struct

def conv(m):
    # https://en.wikipedia.org/wiki/Single-precision_floating-point_format#IEEE_754_single-precision_binary_floating-point_format:_binary32
    s, e, m = m.groups()
    s = 1 if s == '-' else 0
    e = int('0x' + e, 16)
    m = int('0x' + m, 16)
    f32 = m | (e << 23) | (s << 31)
    f, = struct.unpack('>f', struct.pack('>I', f32))
    return '%.4f' % f

for line in sys.stdin:
    sys.stdout.write(re.sub(r'<Float ([+-])([0-9a-f]{2}).([0-9a-f]{6})>', conv, line))
