function radar_parameters = loadRadarParameters(experiment_folder)
%loadRadarParameters.m loads the radar parameters into a structure
%
% Inputs:
%       experiment_folder: a string containing the experiment folder. See the script
%                           generateProjectFolder.m for the structure of
%                           this folder
%
% Outputs:
%       radar_parameters: a structure containing the following values
%       radar_parameters.f0: central frequency
%       radar_parameters.lambda: wavelength
%       radar_parameters.rho_rg: slant range resolution given by the
%       bandwidth
%       radar_parameters.B: bandwidth
%       radar_parameters.fs: sampling frequency in fast time
%       radar_parameters.TX_gain: TX gain
%       radar_parameters.RX_gain: RX gain
%       radar_parameters.TX_waveform: an array with the transmitte waveform
%       radar_parameters.samples_waveform: the number of samples of the
%       transmitted waveform
%       radar_parameters.PRI: Pulse Repetition Interval
%       radar_parameters.PRF: Pulse Repetition Frequency



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