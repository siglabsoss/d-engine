import sys
sys.path.insert(0,"../../../../python-osi")
sys.path.insert(0,"../../../scripts")
from sigmath import *
from subcarrier_math import *

from numpy.fft import ifft, fft, fftshift


def _signed_value(value, bit_count):
    if value > 2**(bit_count - 1) - 1:
        value -= 2**bit_count 

    return value



def _load_hex_file(filepath):
    with open(filepath) as bootprogram:
        lines = bootprogram.readlines()

    words = [int(l,16) for l in lines]

    rf = []
    for w in words:
        real = _signed_value(w&0xffff, 16)
        imag = _signed_value((w >> 16) & 0xffff, 16)
        rf.append(np.complex(real,imag))
        # print "r", real, " i ", imag
        # print rf[0]
        # sys.exit(0)
    return rf



input_0 = _load_hex_file("logs/input_0.hex")

func0_0 = _load_hex_file("logs/func0_0.hex")



ncplot(input_0, "input 0")
nplot(np.angle(input_0), "Arg input 0")
ncplot(func0_0, "func0_0")
nplot(np.angle(func0_0), "Arg output 0")


nplotshow()








