function Drc = zeroDopplerNotch(Drc, PRF)

Drc = Drc - mean(Drc,2);

%BW = 5;    
%Drc = highpass(Drc.',BW,PRF);
%Drc = Drc.';

end