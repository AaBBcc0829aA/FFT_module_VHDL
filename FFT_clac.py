import numpy as np
import matplotlib.pyplot as plt

# Create a sample signal
fs = 1000  # Sampling frequency (Hz)
t = np.linspace(0, 1, fs, endpoint=False)  # Time vector
f1, f2 = 50., 120  # Frequencies of the signal (Hz)
signal = np.sin(2 * np.pi * f1 * t) + 0.5 * np.sin(2 * np.pi * f2 * t)

# Perform FFT
fft_result = np.fft.fft(signal)
fft_magnitude = 150+10*np.log10(np.abs(fft_result))  # Magnitude of FFT
fft_frequency = np.fft.fftfreq(len(t), d=1/fs)  # Frequency vector

# Only take the positive frequencies
positive_freq_indices = fft_frequency > 0
fft_frequency = fft_frequency[positive_freq_indices]
fft_magnitude = fft_magnitude[positive_freq_indices]

# Plot the signal and its FFT
plt.figure(figsize=(12, 6))

# Original signal
plt.subplot(2, 1, 1)
plt.plot(t, signal)
plt.title("Original Signal")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.grid()

# FFT result
plt.subplot(2, 1, 2)
plt.stem(fft_frequency, fft_magnitude, basefmt=" ")
plt.title("FFT of Signal")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude")
plt.grid()
plt.tight_layout()
plt.show()
