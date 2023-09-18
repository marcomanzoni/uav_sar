clear, clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H_ref = 100; % altezza in m
vp = 2; % velocità in m/s
c = physconst('lightSpeed'); % [m/s]
K = physconst('boltzmann'); % [J/K]
F_dB = 5.542; % figura di rumore

if 1 % 10.5 500 mW eirp
     f0 = 10.5e9;  % [Hz]
     P_tx_dBm = 15.9 % max = 17.5
     B = 100e6; % [Hz]
end
if 0  % 9.7 25 mW eirp
     f0 = 9.7e9;  % [Hz]
     P_tx_dBm = 2.8 % max = 17.5
     B = 400e6; % [Hz]
end
if 0
    f0 = 5.9e9;
    P_tx_dBm = 20;
    B = 40e6;
end

T_ref = 290; % [K]
lambda = c/f0; % [m]
delta_psi_deg = 60;
delta_teta_deg = 40;
teta_pt_deg = 90;
ant_eff = 0.75;
PRF = 125e3;%1e3; % [Hz]
duty_cycle = 1;
R_max = 4000;
R_min = H_ref;
fs = 40e6; % frequenza di campionamento del ricevitore 
Nb = 12; % bit per campionare il battimento 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETRI DERIVATI
% res range
pho_r       = c/2/B; % [m]

% Antenna
delta_psi   = delta_psi_deg*pi/180;
delta_teta  = delta_teta_deg*pi/180;
teta_pt = teta_pt_deg*pi/180;
Lh = lambda/delta_psi;
Lv = lambda/delta_teta;
Ae = ant_eff*Lh*Lv;
G = 4*pi*Ae/lambda^2;

% Potenza eirp
P_tx = 10^(P_tx_dBm/10);  % [W]
P_eirp_mW = P_tx*G

% Timing e chirp
PRI = 1/PRF;
Tc = PRI*duty_cycle;
K_chirp = B/Tc;

% Campioni ridondanti
dxa = vp/PRF;
Np_presum = lambda/4/dxa;

% Check campionamento ADC
tau_min = 2/c*R_min;
tau_max = 2/c*R_max;
f_min = K_chirp*tau_min;
f_max = K_chirp*tau_max;
fs_min_MHz = 2*f_max*1e-6
fs > fs_min_MHz*1e6 % check

% Rumore
F = 10^(F_dB/10);  % [W]
Nw = F*K*T_ref;
Pw = Nw*fs;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POTENZA DAL NADIR - assumendo che il terreno sia uno specchio metallico % (Hp molto conservativa) 

A_Fresnel = pi*lambda*H_ref/2; 
RCS_Fresnel = 4*pi/lambda^2*A_Fresnel^2 
div_sf = 4*pi*H_ref.^2; 
Rad_pat_1_way = sinc(sin(0-teta_pt)*Lv/lambda).^2;
% S incidente a terra
S_in = P_tx./div_sf*G.*Rad_pat_1_way;
% S al ricevitore
S_rx = S_in.*RCS_Fresnel./div_sf;
% Potenza al ricevitore
P_rx_Fresnel = S_rx.*Ae.*Rad_pat_1_way
%
RCS_Fresnel_dB = 10*log10(RCS_Fresnel);
Rad_pat_2_way_dB = 10*log10(Rad_pat_1_way^2); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
v = 0;
v = v + 1; 
Param_str{v} = ['f_0 = ' num2str(f0*1e-9,3) ' GHz']; v = v + 1; Param_str{v} = ['P_t_x = ' num2str(P_tx_dBm,3) ' dBm']; 
v = v + 1; Param_str{v} = ['B = ' num2str(B*1e-6,3) ' MHz']; 
v = v + 1; Param_str{v} = ['G = ' num2str(10*log10(G),3) ' dB']; v = v + 1; Param_str{v} = ['off-nadir pointing = ' num2str(teta_pt_deg,3) ' deg'];
v = v + 1; Param_str{v} = ['F = ' num2str(F_dB,3) ' dB']; v = v + 1; Param_str{v} = ['RCS Fresnel = ' num2str(RCS_Fresnel_dB,3) 'dB'];
v = v + 1; Param_str{v} = ['Rad pattern at Nadir (2 way) = ' num2str(Rad_pat_2_way_dB,3) 'dB'];
v = v + 1; Param_str{v} = ['Nb = ' num2str(Nb,3) ' bit']; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROFILO DI POTENZA DEL BACKSCATTER
sigma_0_ref_dB = -5; % questo valore non conta nulla perché la potenza max in Rx è dominata da Fresnel
sigma0 = 10^(sigma_0_ref_dB/10);
dr = 10;
r_ax = (R_min:dr:10*R_max);
teta = acos(H_ref./r_ax);
teta(r_ax<=H_ref) = 0;
div_sf = 4*pi*r_ax.^2;
Rad_pat_1_way = sinc(sin(teta-teta_pt)*Lv/lambda).^2;
% S incidente a terra
S_in = P_tx./div_sf*G.*Rad_pat_1_way;
% Area illuminata per ogni range
A_ill = dr*delta_psi*r_ax;
% RCS ref
RCS_ref = sigma0*A_ill;
% S al ricevitore
S_rx = S_in.*RCS_ref./div_sf;
% Potenza al ricevitore
P_rx_di_r = S_rx.*Ae.*Rad_pat_1_way;
P_rx_di_r(r_ax<=H_ref) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POTENZA TOTALE
% Potenza totale segnale = backscatter + Fresnel 
P_rx_tot_signal = sum(P_rx_di_r) + P_rx_Fresnel 

% Potenza totale 
P_rx_tot =  P_rx_tot_signal + Pw; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantizzazione
V_max = 5*sqrt(P_rx_tot); % non andrei sotto il 5 per ADC uniforme 
delta_q = 2*V_max/2^Nb; 
Pq = delta_q^2/12 
Nq = Pq/fs; % OK se tanti bit e non si ha saturazione (vedi esempio_quantizzazione.m)
TQR = 10*log10(Nw/Nq) % thermal to quantization ratio 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNR, e NESZ
FMCW_factor = 1/2; % la compressione con fft del dato reale spalma l'energia in due parti 
P_rx_cell = P_rx_di_r/dr*pho_r; % potenza da ogni cella di risoluzione in range 
SNR_rc_thermal = P_rx_cell*Tc/Nw*FMCW_factor*Np_presum;
% Non sono sicuro dell'effetto del presum sulla quantizzazione 
SNR_rc = P_rx_cell*Tc/(Nw/Np_presum + Nq)*FMCW_factor;

% NESZ
NESZ_thermal = sigma0./SNR_rc_thermal;
NESZQ = sigma0./SNR_rc;

figure,
subplot(2,1,1), plot(r_ax,10*log10(NESZ_thermal),r_ax,10*log10(NESZQ)), grid 
xlabel('range [m]'),title(['NESZ [dB]'])
xlim([0 R_max]), yy = ylim;
subplot(2,2,3), axis off
text(0,.5,Param_str,'FontSize',11,'Backgroundcolor',[1 1 1]*.99) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
