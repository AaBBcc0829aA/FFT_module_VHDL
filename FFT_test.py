import numpy as np
import matplotlib.pyplot as plt

a = np.array(range(-150,170,10))
b = np.array(range(150,-170,-10))
x=a+1j*b
y = np.round(np.fft.fft(x)/32)

print(x)
print(y)
