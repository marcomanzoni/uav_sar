function [S,f_ax] = showDopplerPlot(Drc, tau_ax, t_ax, mode)
%SHOWDOPPLERPLOT Compute the Doppler spectrum of the data
%
% Inputs:
%       Drc: range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns.
%       PRF: Pulse Repetition Frequency
%       mode: string with "average" or "full". "full" is the default value.
%       "average" takes an average in fast time
%   
%
% Outputs:
%       S: doppler spectrum computed for each range along slow-time
%       f_ax: axis for the Doppler Frequecy domain.
%

if nargin < 3
    mode = "full";
end

[Nrg, Naz]  = size(Drc);

NFFT        = Naz; %2^nextpow2(Naz);
PRF = 1/mean(diff(tau_ax));
df          = PRF/NFFT;
f_ax        = (-NFFT/2:NFFT/2-1)*df;
S           = fftshift(fft(Drc,NFFT,2),2);

figure;
if isequal(mode, "full")
    imagesc(f_ax,t_ax*physconst('lightspeed')/2, db(S)); colorbar;
    title("Range-Doppler");
    ylabel("Range bin");
    axis xy
else
   plot(f_ax, db(mean(abs(S),1))); 
   title("Doppler spectrum averaged over all ranges");
   ylabel("Amplitude [dB]");
   grid on;
end

xlabel("Doppler Frequency [Hz]"); 

end

