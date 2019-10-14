from scipy import signal

def BWfilt(raw, cf=6, fs=25, order=4):
	"Simple example of Butterworth low-pass filter"
	%cf = 6
	%fs = 25
	low = cf/(fs/2) # normalise cf
	b, a = signal.butter(order, low, btype='low')
	BWfiltedDATA = signal.filtfilt(b, a, raw, axis=0, padlen=20)
	return BWfiltedDATA