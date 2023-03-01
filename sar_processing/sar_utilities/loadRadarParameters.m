function radar_parameters = loadRadarParameters(experiment_folder)
%loadRadarParameters: load the parameters of the radar

if not(exist(experiment_folder, 'dir'))
    error("The experiment folder does not exist");
end

c = physconst('lightspeed');

radar_parameters.f0         = 1.65e9;
radar_parameters.B          = 36e6;
radar_parameters.fs         = 40e6;
radar_parameters.TX_gain    = 59; % dB
radar_parameters.RX_gain    = 70; % dB


radar_parameters.lambda     = c/radar_parameters.f0;
radar_parameters.rho_rg     = c/2/radar_parameters.B;

radar_parameters.TX_waveform        = load(fullfile(experiment_folder,"waveform/TX_waveform_S56M.mat")).s_pad;
radar_parameters.samples_waveform   = length(radar_parameters.TX_waveform);
radar_parameters.PRI                = radar_parameters.samples_waveform/radar_parameters.fs;
radar_parameters.PRF                = 1/radar_parameters.PRI;

end


%%%%%%%%%%%%%%%%% Waveform check %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N = length(radar_parameters.TX_waveform);
% df = radar_parameters.fs/N;
% f_ax = (-N/2:N/2-1)*df;
% 
% figure; plot(f_ax, abs(fftshift(fft(radar_parameters.TX_waveform)))); grid on;
% xlabel("Frequency [Hz]");