function [S,f_ax] = showDopplerPlot(Drc, PRF)
%SHOWDOPPLERPLOT Summary of this function goes here
%   Detailed explanation goes here

[Nrg, Naz] = size(Drc);

NFFT = 2^nextpow2(Naz);
df = PRF/NFFT;
f_ax = (-NFFT/2:NFFT/2-1)*df;
S = fftshift(fft(Drc,NFFT,2));

figure; plot(f_ax, db(mean(abs(S),1))); grid on;
xlabel("Doppler Frequency [Hz]"); ylabel("Amplitude [dB]");
title("Doppler"); axis tight;

end

