close all;
clc;

%% Add the paths

addpath('./trajectories',...
    './sar_utilities',...
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

experiment_folder              = "D:\Droni_Campaigns\20230208_monte_barro_auto_2\exp1";
max_range                      = 300;
OSF                            = 4;
zero_doppler_notch             = true;

%% Start the processing

% loading the parameters of the radar (f0,PRI,PRF,BW,fs,gains and waveform)
radar_parameters = loadRadarParameters(experiment_folder);

% Convert raw data from .dat to .mat
rawDataConvert(experiment_folder, radar_parameters.samples_waveform);

% load the data itself
[Drc, t_ax, tau_ax] = loadRawDataAndRangeCompress(experiment_folder, radar_parameters, max_range, OSF);  

figure; plot(t_ax*3e8/2, mean(abs(Drc),2)); xlabel("range [m]"); ylabel("Amplitude");
title("Resolution check from the direct path"); grid on;

% Testing notch filter
Drc = zeroDopplerNotch(Drc, radar_parameters.PRF);
figure; imagesc(tau_ax, t_ax*3e8/2, db(Drc)); caxis([90,120]);
xlabel("Slow time [s]");
ylabel("range [m]");
title("Notched zero doppler");

% Trajectory interpolation to match the radar timestamps

% Focusing

% Autofocusing












































