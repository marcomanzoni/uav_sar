clear all;
close all;
clc;

load("C:\Users\Manzoni\Desktop\dati strani\\DRC.mat");
load("C:\Users\manzoni\Desktop\dati strani\dati_strani.mat");

c = physconst('lightspeed');

%% Let's have a look at the trajectory


dtau = mean(diff(tau_ax));
rho_rg = radar_parameters.rho_rg;

% I want the movement to be along x
beginTraj   = 2.7e4 %3.5e4;%
endTraj     = 3.5e4 %4.3e4; %

window_filter = 3501;

% Filter them, they are like a sawtooth (interpolation error?)
Sx_fil = movmean(Sx, window_filter);
Sy_fil = movmean(Sy, window_filter);
Sz_fil = movmean(Sz, window_filter);

figure; 
subplot(1,3,1);
plot3(Sx,Sy,Sz, Sx_fil, Sy_fil, Sz_fil); grid on; axis equal; xlabel("X [m]"); ylabel("Y [m]"); zlabel("Z [m]"); hold on;
plot3(Sx_fil(beginTraj), Sy_fil(beginTraj), Sz_fil(beginTraj), 'g*');
plot3(Sx_fil(endTraj), Sy_fil(endTraj), Sz_fil(endTraj), 'r*');

subplot(1,3,2);
plot(tau_ax, Sx, tau_ax, Sy, tau_ax, Sz); grid on; xlabel("Slow-time [s]"); legend("Sx", "Sy", "Sz");
title("Trajectory"); axis tight

subplot(1,3,3);
plot(tau_ax, Sx_fil, tau_ax, Sy_fil, tau_ax, Sz_fil); grid on; xlabel("Slow-time [s]"); legend("Sx", "Sy", "Sz");
title("Trajectory filtered"); axis tight

% Replace the trajectories with the filtered ones
Sx = Sx_fil;
Sy = Sy_fil;
Sz = Sz_fil;

% Compute the velocities along each direction
DSx = gradient(Sx)/dtau;
DSx = movmedian(DSx, 2*window_filter);

DSy = gradient(Sy)/dtau;
DSy = movmedian(DSy, 2*window_filter); 

DSz = gradient(Sz)/dtau;
DSz = movmedian(DSz, 2*window_filter);

% instantaneous velocity
v_instant = sqrt(DSx.^2 + DSy.^2 + DSz.^2);

figure; plot(tau_ax, v_instant); grid on; hold on;
plot(tau_ax(beginTraj), v_instant(beginTraj), 'g*');
plot(tau_ax(endTraj), v_instant(endTraj), 'r*');

% Total trajectory length
traj_length = sum(v_instant(beginTraj:endTraj)*dtau)
res_far = radar_parameters.lambda/2/traj_length*1200

% Align trajectory
beta = atan2d(Sy(endTraj)-Sy(beginTraj),Sx(endTraj)-Sx(beginTraj));

H = [cosd(beta) sind(beta); -sind(beta) cosd(beta)];

% P = H*[Sx' ; Sy'];
% Sx = P(1,:)';
% Sy = P(2,:)';
% Sy = Sy - mean(Sy(beginTraj:endTraj));
% Sx = Sx - mean(Sx(beginTraj:endTraj));

figure;
plot3(Sx,Sy,Sz); grid on; axis equal; xlabel("X [m]"); ylabel("Y [m]"); zlabel("Z [m]"); hold on;
plot3(Sx(beginTraj), Sy(beginTraj), Sz(beginTraj), 'g*');
plot3(Sx(endTraj), Sy(endTraj), Sz(endTraj), 'r*');

%% Range compressed data analysis

r_ax            = c/2*t_ax;

% removing sidelobes in range with a gaussian filter
dr              = mean(diff(r_ax));
filter_ax       = -10*rho_rg : dr : 10*rho_rg;
filtering_strength = rho_rg;
range_filter    = exp(-1/2*(filter_ax./filtering_strength).^2);
range_filter    = range_filter./sqrt(sum(range_filter.^2));

D_range_rem     = conv2(D, range_filter(:), 'same');

% How much presumming can I make? Depends on how much sampling I do have
meanSampling    = mean(v_instant(beginTraj:endTraj)*dtau);
actualOvers     = radar_parameters.lambda/4/meanSampling

% Presumming and undersampling a bit
pres_win        = 51;
%Dpres = movmean(D,pres_win,2,"omitnan");

filter_pres     = exp(-1/2*((-2*pres_win:2*pres_win)/pres_win).^2);
filter_pres     = filter_pres./sum(filter_pres);
Dpres           = conv2(D_range_rem,filter_pres,'same');

Dpres           = Dpres(:, 1:pres_win:end);

tau_ax_pres     = tau_ax(1:pres_win:end);
Sx_pres         = Sx(1:pres_win:end);
Sy_pres         = Sy(1:pres_win:end);
Sz_pres         = Sz(1:pres_win:end);

% Some plotting
figure;
subplot(3,1,1);
imagesc(tau_ax, r_ax, db(D)); colormap("jet"); colorbar;
xlabel("Slow-time [s]");
ylabel("Range [m]"); title("Range compressed data [dB]");

subplot(3,1,2);
imagesc(tau_ax, r_ax, db(D_range_rem)); colormap("jet"); colorbar;
xlabel("Slow-time [s]");
ylabel("Range [m]"); title("Sidelobes removed [dB]");

subplot(3,1,3);
imagesc(tau_ax, r_ax, db(Dpres)); colormap("jet"); colorbar;
xlabel("Slow-time [s]");
ylabel("Range [m]"); title("Sidelobes removed and presumming [dB]");

figure; plot(r_ax, mean(abs(Dpres),2)); grid on;
xlabel("Range [m]"); xlim([50 max(r_ax)]);

%% Let's see the Doppler

% Full sampling before filtering and undersampling
Ntau        = length(beginTraj:endTraj);
NFFT        = 2^nextpow2(Ntau);
df          = radar_parameters.PRF/NFFT;
freq_axis   = (-NFFT/2:NFFT/2-1)*df;

Df = fftshift(fft(D_range_rem(:, beginTraj:endTraj),NFFT,2),2);
Df_mean = mean(abs(Df));

figure; 
subplot(2,1,1);
plot(freq_axis, db(Df_mean)); grid on; title("Doppler analysis. No filtering, full sampling");
xlabel("Doppler [Hz]"); ylabel("Amplitude"); axis tight
subplot(2,1,2);
imagesc(freq_axis, r_ax, db(Df)); colorbar; title("Range Doppler"); xlabel("Doppler [Hz]"); ylabel("Range [m]");

% After filtering and undersampling
df          = radar_parameters.PRF/pres_win/NFFT;
freq_axis   = (-NFFT/2:NFFT/2-1)*df;

Df = fftshift(fft(Dpres(:, beginTraj/pres_win:endTraj/pres_win),NFFT,2),2);
Df_mean = mean(abs(Df));

figure; 
subplot(2,1,1);
plot(freq_axis, db(Df_mean)); grid on; title("Doppler analysis. Filtering and undersampling");
xlabel("Doppler [Hz]"); ylabel("Amplitude"); axis tight
subplot(2,1,2);
imagesc(freq_axis, r_ax, db(Df)); colorbar; title("Range Doppler"); xlabel("Doppler [Hz]"); ylabel("Range [m]");

%% Let's try to notch the filter

wo = 4.77/(radar_parameters.PRF/pres_win/2);  
bw = wo/10;
[b,a] = iirnotch(wo,bw);

%Dpres_filt = filter(b,a,Dpres(500,:));
Dpres_filt = filter(b,a,Dpres, [], 2);

Df = fftshift(fft(Dpres_filt(:, beginTraj/pres_win:endTraj/pres_win),NFFT,2),2);
Df_mean = mean(abs(Df));

figure; 
subplot(2,1,1);
plot(freq_axis, db(Df_mean)); grid on; title("Doppler analysis. Filtering, undersampling and notched");
xlabel("Doppler [Hz]"); ylabel("Amplitude"); axis tight
subplot(2,1,2);
imagesc(freq_axis, r_ax, db(Df)); colorbar; title("Range Doppler"); xlabel("Doppler [Hz]"); ylabel("Range [m]");

%% Focusing the data itself

D_traj_pres           = Dpres_filt(:, floor(beginTraj/pres_win) : floor(endTraj/pres_win));
Sx_traj_pres          = Sx_pres(floor(beginTraj/pres_win) : floor(endTraj/pres_win));
Sy_traj_pres          = Sy_pres(floor(beginTraj/pres_win) : floor(endTraj/pres_win));
Sz_traj_pres          = Sz_pres(floor(beginTraj/pres_win) : floor(endTraj/pres_win));

tau_ax_apertura = tau_ax(floor(beginTraj/pres_win) : floor(endTraj/pres_win));
tau_ax_apertura = tau_ax_apertura - mean(tau_ax_apertura);
err_vel = 0 * tau_ax_apertura;

Ntau = length(Sx_traj_pres)

f0 = radar_parameters.f0;

x_ax = -600 : radar_parameters.rho_rg*0.5 : 600;
y_ax = 50 : radar_parameters.rho_rg*0.5 : 1200;

[X,Y] = meshgrid(x_ax, y_ax);
Z = 0*X;
I = zeros(size(X));
Inorm = I;

for ii = 1:Ntau

    fprintf("Focussing %d / %d: ", ii, Ntau);
    delta_x = Sx_traj_pres(ii)-X;
    delta_y = (Sy_traj_pres(ii)+err_vel(ii))-Y;
    delta_z = Sz_traj_pres(ii)-Z;

    distances = sqrt(delta_x.^2+delta_y.^2+delta_z.^2);

    delay = 2*distances/c;

    %I = I + interp1(t_ax, D_traj_pres(:,ii).*r_ax', delay, "linear",NaN).*exp(+1j*2*pi*f0*delay);
    Inorm = Inorm + interp1(t_ax, abs(D_traj_pres(:,ii)), delay, "linear",NaN);
    I = I + interp1(t_ax, D_traj_pres(:,ii), delay, "linear",NaN).*exp(+1j*2*pi*f0*delay);

    fprintf("Done. \n");
end

delta_x = Sx_traj_pres(floor(Ntau/2))-X;
delta_y = Sy_traj_pres(floor(Ntau/2))-Y;
delta_z = Sz_traj_pres(floor(Ntau/2))-Z;

distances = sqrt(delta_x.^2+delta_y.^2+delta_z.^2);

figure; imagesc(x_ax, y_ax, abs(I./Inorm)); axis xy equal tight
colormap("jet");

figure; imagesc(x_ax, y_ax, db(I)); axis xy equal tight
colormap("jet");


%% Let's try some dirty autofocus tricks
% 
% [pks,locs_y,locs_x]=peaks2(abs(I./Inorm),'MinPeakDistance',5*rho_rg, 'MinPeakHeight',0.5);
% 
% 
% figure; imagesc(x_ax, y_ax, abs(I./Inorm)); axis xy equal tight
% colormap("jet"); hold on;
% 
% 
% x_gcp = x_ax(locs_x);
% y_gcp = y_ax(locs_y);
% 
% plot(x_gcp, y_gcp, 'md');
% 
% for ii = 1:Ntau
% 
%     fprintf("Focussing %d / %d: ", ii, Ntau);
% 
%     delta_x = Sx_traj_pres(ii)-x_gcp;
%     delta_y = Sy_traj_pres(ii)-y_gcp;
%     delta_z = Sz_traj_pres(ii)-z_gcp;
% 
%     distances = sqrt(delta_x.^2+delta_y.^2+delta_z.^2);
% 
%     delay = 2*distances/c;
% 
%     %I = I + interp1(t_ax, D_traj_pres(:,ii).*r_ax', delay, "linear",NaN).*exp(+1j*2*pi*f0*delay);
%     Inorm = Inorm + interp1(t_ax, abs(D_traj_pres(:,ii)), delay, "linear",NaN);
%     I = I + interp1(t_ax, D_traj_pres(:,ii), delay, "linear",NaN).*exp(+1j*2*pi*f0*delay);
% 
%     fprintf("Done. \n");
% end
























































