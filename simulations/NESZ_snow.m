clear all;
close all;
clc;

f0              = 2e9;                      % Carrier frequency [Hz];
c               = physconst('lightspeed');  % Lightspeed
lambda          = c/f0;                     % Wavelength [m]

Tp              = 71e-6;                    % Pulse length
B               = 30e6;                     % bandwidth
K               = physconst('Boltzmann');
R               = 10:0.1:50;                % Radar-target range
F_dB            = 13;                       % Receiver noise figure [dB]
F               = 10^(F_dB/10);             % Noise factor
T0              = 290;                      % Temperature at which the noise figure is referring to [K]
v               = 1;                        % Platform velocity [m/s]
Ptx_db          = -7;                       % Total transmission power [dBw] (dBw = dBm - 30)
Ptx             = 10^(Ptx_db/10);

delta_psi       = 100/180*pi;               % azimuth beamwidth [rad]
delta_teta      = 100/180*pi;               % elevation beamwidth [rad]
beam_sector     = delta_teta*delta_psi;     % [rad^2]
eff_ant         = 0.7;                      % Antenna efficiency
G               = eff_ant*4*pi/beam_sector; % Antenna gain
f               = 1;                        % Antenna pattern

rho_rg          = c/2/B;                    % Range resolution
PRF             = 1/Tp;                     % PRF of the system

alpha           = snowPowerAttenuation(f0);
z               = 2;                        % Dept of the target in snow

NESZ            = (2*(4*pi)^3*R.^3*F*K*T0*B*v)/(Ptx*G^2*f^2*rho_rg*lambda^3*Tp*PRF*exp(-4*alpha*z));

figure; plot(R, 10*log10(NESZ)); grid on; title("NESZ at varying range");
xlabel("Range [m]");
ylabel("NESZ [dB]");

