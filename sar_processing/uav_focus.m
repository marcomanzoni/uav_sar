close all;
clc;

%% Add the paths

addpath('./trajectories',...
    './sar_utilities',...
    './focusing', ...
    genpath('../utilities'),...
    addpath(genpath('../range_compression')));

%% Definition of the parameters

% Each experiment has a folder with the following sub-directories
% raw: for raw data
% rc: for range compressed data
% images: for the output
% trajectories: for the mat file containing the trajectories
% and the info.txt file with infos about the experiment such as (PRF, PRI,
% pulse length, bandwidth, central frequency, total trajectory lenth)

experiment_folder              = "D:\Droni_Campaigns\20230208_monte_barro_auto_2\exp12";

% Maximum range for the range compression
max_range                      = 300;

% Over sampling factor for the range compression
OSF                            = 4;

% Under sampling factor for the slow-times (odd-number!)
USF                            = 7; 

% Flag for the notching of the zero doppler peak (mean removal)
zero_doppler_notch             = true;

% Azimuth resolution (-1 means same as range resolution)
rho_az = -1;

% Squint for the focusing (deg)
squint = 0;

%% Start the processing

% loading the parameters of the radar (f0,PRI,PRF,BW,fs,gains and waveform)
radar_parameters = loadRadarParameters(experiment_folder);

% Convert raw data from .dat to .mat
rawDataConvert(experiment_folder, radar_parameters.samples_waveform);

% load the data itself
[Drc, t_ax, tau_ax] = loadRawDataAndRangeCompress(experiment_folder, radar_parameters, max_range, OSF);  

figure; plot(t_ax*3e8/2, mean(abs(Drc),2)); xlabel("range [m]"); ylabel("Amplitude");
title("Resolution check from the direct path"); grid on;

% Notch filter on the zero Doppler to kill the direct path from TX antenna
% to RX antenna
Drc = zeroDopplerNotch(Drc, radar_parameters.PRF);
figure; imagesc(tau_ax, t_ax*3e8/2, db(Drc)); 
caxis([100,130]);
xlabel("Slow time [s]");
ylabel("range [m]");
title("Notched zero doppler");

showDopplerPlot(Drc,radar_parameters.PRF);

% Filter the range compressed data with a gaussian filter in range to
% remove sidelobes
Drc = filterRange(Drc, t_ax, radar_parameters.B);

% Low pass filter and undersample the range compressed data. We have a very
% high PRF, so we can do it
[Drc_lp, PRF, tau_ax] = lowPassFilterAndUndersample(Drc, radar_parameters.PRF, tau_ax, USF);
showDopplerPlot(Drc_lp,PRF);
figure; imagesc(tau_ax, t_ax*3e8/2, db(Drc_lp)); 
caxis([100,130]);
xlabel("Slow time [s]");
ylabel("range [m]");
title("Notched zero doppler");

% Trajectory interpolation to match the radar timestamps
Nbegin  = 450;%4500;
Nend    = 7050;%5840;%64300;
figure; imagesc([], t_ax*3e8/2, db(Drc_lp)); caxis([100,130]); hold on;
plot([Nbegin Nbegin],[t_ax(1)*3e8/2, t_ax(end)*3e8/2], 'r');
plot([Nend Nend],[t_ax(1)*3e8/2, t_ax(end)*3e8/2], 'r');

traj = loadTrajectories(experiment_folder);
traj = alignTrajectoryWithRadarData(traj.lat, traj.lon, traj.alt, traj.speed, traj.time_stamp, ...
    tau_ax, Nbegin, Nend);

%% Focusing
if rho_az == -1
    rho_az = radar_parameters.rho_rg;
end

% Define the backprojection grid
x = -40 : radar_parameters.rho_rg/20 : 40;
y = 1 : -radar_parameters.rho_rg/20 : -300;
[X,Y] = meshgrid(x,y);
Z = zeros(size(X));

I = focusDroneT DBP(Drc_lp(:,Nbegin:Nend), t_ax, radar_parameters.f0,...
    traj.Sx(Nbegin:Nend), traj.Sy(Nbegin:Nend), traj.Sz(Nbegin:Nend),...
    X,Y,Z,...
    rho_az, squint);

figure; imagesc(x,y,abs(I)); colorbar; axis xy
xlabel("x [m]"); ylabel("y [m]"); title("Focussed SAR image");
caxis([1e7 11e7]); axis xy tight
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')

% Autofocusing












































