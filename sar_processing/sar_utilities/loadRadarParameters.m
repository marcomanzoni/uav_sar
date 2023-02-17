function radar_parameters = loadRadarParameters(experiment_folder)

if not(exist(experiment_folder, 'dir'))
    error("The experiment folder does not exist");
end


radar_parameters.f0 = 1.65e9;
radar_parameters.B  = 36e6;
radar_parameters.fs = 40e6;
radar_parameters.TX_gain = 50; % dB
radar_parameters.RX_gain = 50; % dB

c = physconst('lightspeed');
radar_parameters.lambda = c/f0;

radar_parameters.TX_waveform        = load(fullfile(experiment_folder,"waveform/TX_waveform.mat"));
radar_parameters.samples_waveform   = length(radar_parameters.TX_waveform);
radar_parameters.PRI                = radar_parameters.samples_waveform / radar_parameters.fs;
radar_parameters.PRF                = 1/radar_parameters.PRI;

end