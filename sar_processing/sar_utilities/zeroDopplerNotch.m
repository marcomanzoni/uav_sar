function Drc = zeroDopplerNotch(Drc, PRF)
%zeroDopplerNotch Remove the mean value computed along the slow time. This
%   cancels the direct path. A more sophisticated version perform an high-pass
%   filter on the data with a very small bandwidth.
%
% Inputs:
%       Drc: range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns.
%       PRF: Pulse Repetition Frequency
%   
%
% Outputs:
%       Drc:            range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns. The mean value along
%                       the slow-time (zero doppler component) has been
%                       removed.
%

% Remove the main
Drc = Drc - mean(Drc,2);

% Filtering (high pass)
%BW = 5;    
%Drc = highpass(Drc.',BW,PRF);
%Drc = Drc.';

end