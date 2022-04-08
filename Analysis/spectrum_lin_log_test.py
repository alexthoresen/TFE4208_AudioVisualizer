import numpy as np
from scipy.io import wavfile
import matplotlib.pyplot as plt

N_FFT_SAMPLES = 256
N_COLUMNS = 8
TIMESTAMP = 20 # seconds

f_s, stereo_samples = wavfile.read("Go_Your_Own_Way.wav")

mono_samples = (stereo_samples[:,0] + stereo_samples[:,1]) >> 1

def spectrum_bars_at_time(data, time, f_s):
    t = time * f_s
    samples = data[t:t+N_FFT_SAMPLES]
    freq = np.fft.rfftfreq(n=N_FFT_SAMPLES, d=1/f_s)[:-1]
    freq_log2 = np.log2(freq)
    spectrum = np.log10(np.abs(np.fft.rfft(samples / 2**16)))[:-1]

    bars = np.zeros(np.shape(spectrum))
    bars_log2 = np.zeros(np.shape(spectrum))

    fft_len = N_FFT_SAMPLES // 2
    bar_step = fft_len // N_COLUMNS

    for i in range(0, fft_len, bar_step):
        bars[i:i+bar_step] = np.max(spectrum[i:i+bar_step])

    bars_log2[64:128] = np.max(spectrum[64:128])
    bars_log2[32:64] = np.max(spectrum[32:64])
    bars_log2[16:32] = np.max(spectrum[16:32])
    bars_log2[8:16] = np.max(spectrum[8:16])
    bars_log2[4:8] = np.max(spectrum[4:8])
    bars_log2[2:4] = np.max(spectrum[2:4])
    bars_log2[1:2] = np.max(spectrum[1:2])
    bars_log2[0:1] = np.max(spectrum[0:1])

    return freq, freq_log2, spectrum, bars, bars_log2

for time in range(0, 3*60+40, 5):
    # Figuren i rappoerten er 1:30 ut i "Go Your Own Way" av Fleetwood Mac
    freq, freq_log2, spectrum, bars, bars_log2 = spectrum_bars_at_time(mono_samples, time, f_s)

    fig, [[ax1, ax3], [ax2, ax4]] = plt.subplots(nrows=2, ncols=2)
    ax1.get_shared_x_axes().join(ax1, ax2)
    ax3.get_shared_x_axes().join(ax3, ax4)
    ax1.plot(freq, spectrum, '-b')
    ax1.plot(freq, bars, '-r')
    ax2.plot(freq, spectrum, '-b')
    ax2.plot(freq, bars_log2, '-r')
    ax3.plot(freq_log2, spectrum, '-b')
    ax3.plot(freq_log2, bars, '-r')
    ax4.plot(freq_log2, spectrum, '-b')
    ax4.plot(freq_log2, bars_log2, '-r')

    ax1.set_title("Linear frequency, linear bands")
    ax1.set_ylabel("Log10 Amplitude")
    ax2.set_title("Linear frequency, exp2 bands")
    ax2.set_xlabel("Frequency [Hz]")
    ax2.set_ylabel("Log10 Amplitude")
    ax3.set_title("Log2 frequency, linear bands")
    ax4.set_title("Log2 frequency, exp2 bands")
    ax4.set_xlabel("Log2 [Frequency [Hz]]")

    plt.show()
    break
