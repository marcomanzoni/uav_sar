function [Drc, PRF, tau_ax] = lowPassFilterAndUndersample(Drc,PRF, tau_ax, USF)
%LOWPASSFILTERANDUNDERSAMPLE Summary of this function goes here
%   Detailed explanation goes here

if rem(USF,2) ~= 1
    warning("Under Sampling Factor (USF) must be odd, rounding the the lower odd number");
    USF = USF - 1;
end

% For the moment is a moving average, later on we will make this more
% sophisticate
Drc = movmean(Drc,USF,2);
Drc = Drc(:, 1:USF:end);

% It changes also the PRF
PRF = PRF/USF;

% And the slow-time axis
tau_ax = tau_ax(1:USF:end);

end

