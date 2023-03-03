function [Drc, PRF, tau_ax] = lowPassFilterAndUndersample(Drc,PRF, tau_ax, USF)
%LOWPASSFILTERANDUNDERSAMPLE Low pass the data in Doppler and undersample
%it. This improves SNR and reduce computational burden during TDBP
%
% Inputs:
%       Drc:            range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns.
%       PRF:            pulse repetition frequency
%       tau_ax:         slow time axis
%       USF:            Under Sampling Factor. 
%   
% Outputs:
%       Drc:            range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns.
%       PRF:            new system PRF after undersampling
%       tau_ax:         new slow-time axis after undersampling.
%

if rem(USF,2) ~= 1
    warning("Under Sampling Factor (USF) must be odd, rounding the the lower odd number");
    USF = USF - 1;
end


b = fir1(50,2/USF,"low");
b = b./sqrt(b*b');
Drc = filter(b, 1,Drc, [], 2);

% For the moment is a moving average, later on we will make this more
% sophisticate
%Drc = movmean(Drc,USF,2);
Drc = Drc(:, 1:USF:end);

% It changes also the PRF
PRF = PRF/USF;

% And the slow-time axis
tau_ax = tau_ax(1:USF:end);

end

