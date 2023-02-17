close all;
clc;

%% Add the paths

addpath('./trajectories',...
    './sar_utilities',...
    genpath('../utilities'),...
    addpath(genpath('../range_compression')));

%% Experiment definition
% Each experiment has a folder with the following sub-directories
% raw: for raw data
% rc: for range compressed data
% images: for the output
% trajectories: for the mat file containing the trajectories
% and the info.txt file with infos about the experiment such as (PRF, PRI,
% pulse length, bandwidth, central frequency, total trajectory lenth)

experiment_folder              = "C:\Users\manzoni\Documents\data\exp1";

% load the parameters of the radar (f0,PRI,PRF,BW,fs,gains and waveform)
radar_parameters = loadRadarParameters(experiment_folder);

% load the data itself
raw_data = loadRawDataAndRangeCompress(experiment_folder, radar_parameters, max_range);














































