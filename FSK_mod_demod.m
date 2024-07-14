clear all
fs = 5e9;
fdev=99.5e3;
fc= 160e6;
sampling_freq=80e3;
f1 = fc-fdev;
f2 = fc+fdev;
BW = 5e6;
data = repmat([0 1 ], 1, 20);
%data = randi([0, 1], [1, 10]);
bit_T = 1/sampling_freq;
lim1 = fc-BW/2;
lim2 = fc+BW/2;
%%%%%%%%%%%%%%%%%%%%%%%
%FSK modulation
signal = [];
for i = 1:length(data)
    t_bit = (i-1)*bit_T:1/fs:i*bit_T-1/fs;
    if data(i) == 0
        signal =[signal cos(2*pi*f1*t_bit)];
    else
        signal =[signal cos(2*pi*f2*t_bit)]; 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%
%AWGN
rx_Signal=[];
step1 = (length(signal)/10);
snrdB = -10;
for n1 = step1:step1:length(signal)
    rx_Signal = [rx_Signal awgn(signal(n1-(step1-1):n1),snrdB)];
    snrdB = snrdB + 2;
end 
%signal = rx_Signal;
%%%%%%%%%%%%%%%%%%%%%%%
%FFT
window_length = length(t_bit) * length(data);
average_spectrum= fftshift(abs(fft(signal)));
%
%average_spectrum = 10^(3/20)/max(average_spectrum)*average_spectrum;
%
%%%%%%%%%%%%%%%%%%%%%%%
%Plottings
frequencies = linspace(-fs/2, fs/2, window_length);
figure;
subplot(5,1,1);
plot(0:1/fs:(length(signal)-1)/fs, signal);
title('2FSK Modulated');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(5,1,2);
plot(frequencies, average_spectrum);
%plot(frequencies, 10^(3/20)/max(average_spectrum)*average_spectrum);
title('2FSK Modulated Frequency Spectrum Linear Scale Amplitude');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([lim1 lim2]);
%ylim([-30 1000]);



dbamplitudespectrum = 20*log10(average_spectrum);
%dbamplitudespectrum = 20*log10(10^(3/20)/max(average_spectrum)*average_spectrum);
subplot(5,1,3);
plot(frequencies, dbamplitudespectrum);
title('2FSK Modulated Frequency Spectrum dB Scale Amplitude');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
xlim([lim1 lim2]);
%ylim([-30 100]);



powerspectrum = (average_spectrum.^2) / window_length;
subplot(5,1,4);
plot(frequencies, powerspectrum);
%plot(frequencies,  10^(3/10)/max(powerspectrum)*powerspectrum);
title('2FSK Modulated Power Spectrum Linear Scale Amplitude');
xlabel('Frequency (Hz)');
ylabel('Power');
xlim([lim1 lim2]);
%ylim([-30 1000]);



dbpowerspectrum = 10*log10(powerspectrum);
%dbpowerspectrum = 10*log10(10^(3/10)/max(powerspectrum)*powerspectrum);
subplot(5,1,5);
plot(frequencies, dbpowerspectrum);
title('2FSK Modulated Power Spectrum dB Scale Amplitude');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
xlim([lim1 lim2]);
ylim([-50 70]);

figure;
plot(frequencies, dbpowerspectrum);
title('2FSK Modulated Power Spectrum dB Scale Amplitude');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
xlim([lim1 lim2]);
ylim([-50 70]);



dbpowerspectrum_ = 10*log10(10^(3/10)/max(powerspectrum)*powerspectrum);
figure;
plot(frequencies, dbpowerspectrum_);
title('2FSK Modulated Power Spectrum dB Scale Amplitude');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
xlim([lim1 lim2]);
ylim([-100 20]);
%%%%%%%%%%%%%%%%%%%%%%%
%FSK demodulation
% fc, fdev, fs, sampling_freq
symbol_step = fs/sampling_freq;
f1_filtered_fsk = bandpass(signal,[fc-fdev-fdev/2,fc-fdev+fdev/2],fs);
f2_filtered_fsk = bandpass(signal,[fc+fdev-fdev/2,fc+fdev+fdev/2],fs);
demodulated_data=[];
for symbol = 1:symbol_step:length(signal)
    p1 = f1_filtered_fsk(symbol:symbol+symbol_step-1);
    p2 = f2_filtered_fsk(symbol:symbol+symbol_step-1);
    p1_envelope = abs(hilbert(p1));
    p2_envelope = abs(hilbert(p2));
    if(sum(p1_envelope) > sum(p2_envelope))
        demodulated_data=[demodulated_data,0];
    else
        demodulated_data=[demodulated_data,1];
    end
end
if(data==demodulated_data)
    disp('data==demodulated_data')
end







