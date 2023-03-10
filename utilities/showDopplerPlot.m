function [S,f_ax] = showDopplerPlot(Drc, PRF)
%SHOWDOPPLERPLOT Compute the Doppler spectrum of the data
%
% Inputs:
%       Drc: range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns.
%       PRF: Pulse Repetition Frequency
%   
%
% Outputs:
%       S: doppler spectrum computed for each range along slow-time
%       f_ax: axis for the Doppler Frequecy domain.
%

[Nrg, Naz] = size(Drc);

NFFT = 2^nextpow2(Naz);
df = PRF/NFFT;
f_ax = (-NFFT/2:NFFT/2-1)*df;
S = fftshift(fft(Drc,NFFT,2));

figure; plot(f_ax, db(mean(abs(S),1))); grid on;
xlabel("Doppler Frequency [Hz]"); ylabel("Amplitude [dB]");
title("Doppler"); axis tight;

end

