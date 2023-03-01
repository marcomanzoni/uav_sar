function Drc = filterRange(Drc, t_ax, B)
%FILTERRANGE Summary of this function goes here
%   Detailed explanation goes here

c = physconst('lightspeed');
r_ax    = t_ax*c/2;
dr      = r_ax(2)-r_ax(1);
rhoR    = c/2/B;

% Side lobes suppression
rrr             = (-15:15)*dr;
range_filter    = exp(-1/2*(rrr/rhoR).^2);
range_filter    = range_filter/sum(range_filter);

Drc = conv2(Drc,range_filter(:),'same');

end

