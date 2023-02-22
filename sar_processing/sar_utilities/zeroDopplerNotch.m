function Drc = zeroDopplerNotch(Drc, PRF)

BW = 5;    
Drc = highpass(Drc.',BW,PRF);
Drc = Drc.';

end