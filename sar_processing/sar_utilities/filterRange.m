function Drc = filterRange(Drc, t_ax, B)
%FILTERRANGE Filter the data in range to remove sidelobes. This routine
%degrade the resolution allowing to remove sidelobes from range compressed
%data.
%
% Inputs:
%       Drc:    range compressed data matrix. Fast time along the rows,
%               slow-time along the columns.
%       t_ax:   fast time axis
%       B:      bandwidth of the system
%
% Outputs:
%       Drc:            range compressed data matrix. Fast time along the rows,
%                       slow-time along the columns.
%

c       = physconst('lightspeed');
r_ax    = t_ax*c/2;
dr      = r_ax(2)-r_ax(1);
rhoR    = c/2/B;

% Side lobes suppression
rrr             = (-15:15)*dr; % 31 samples 
range_filter    = exp(-1/2*(rrr/rhoR).^2); % gaussian filtering with std=resolution
range_filter    = range_filter/sum(range_filter); % Normalization of the filter

Drc = conv2(Drc,range_filter(:),'same');

end

