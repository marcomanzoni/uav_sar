function [raw_data, t_ax, tau_ax] = loadRawDataAndRangeCompress(experiment_folder, radar_parameters, max_range)
%LOADRAWDATA Summary of this function goes here
%   Detailed explanation goes here

chirp_sr            = radar_parameters.fs;                  % SDR sample rate
chirp_bw            = .9*chirp_sr;                          % actual chirp bandwidth

tx_wave             = radar_parameters.TX_waveform;
tx_wave             = single(tx_wave);
samples_per_chirp   = radar_parameters.samples_waveform;            % 2^15 mew, 33002 for 30MSps(old)

dt                  = 1/chirp_sr;
dR                  = physconst('LightSpeed') * dt;
samp_margin         = round(max_range / dR);

%%%%%%%%%%%%%%%%%%%% Get the folder content %%%%%%%%%%%%%%%%%%%%%%%%%%%%
directoryContent = dir(fullfile(experiment_folder,"raw","*.bb"));
if length(directoryContent) ~= 1
    error("More than one raw data file in the folder")
end

file_path = fullfile(directoryContent.folder, directoryContent.name);

%%%%%%%%%%%%%%%%%%%% load the raw data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("Loading the raw data: ");
A = load_bin(file_path(1:end-3));
fprintf("Done. \n");

%%%%%%%%%%%%%%%%%%% Range compress it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_fft       = 2 ^ nextpow2(samples_per_chirp);
N_slice     = 1e3;

% Destination file
dest_file= fullfile(experiment_folder, "/rc", "drc.mat");

if(isfile(dest_file))
    error("ERROR Destination file already present. Delete before continue");
else
    m       = matfile(dest_file,'Writable',true);
end

% Fourier transform of the transmitted waveform
txWaveFFT   = conj(fft(tx_wave,N_fft));
max_idx = -1;

% Start the range compression in slides, the data

f = waitbar(0,'Range compression...');

for slice_idx = 1:N_slice:size(A,2)

    waitbar(slice_idx/size(A,2),f,'Range compression...');

    % Load the slice
    if slice_idx + N_slice - 1 > size(A,2)
        matFFT = fft(A(:,slice_idx : end),N_fft,1);
    else
        matFFT = fft(A(:,slice_idx:slice_idx+N_slice-1),N_fft,1);
        N_slice = size(matFFT,2);
    end

    % matched filter in the frequency domain
    RC_slice = ifft( matFFT .* txWaveFFT,N_fft,1);

    if (max_idx == -1)
        [~,max_idx] = max(abs(RC_slice(:,500)));
    end

    %save the slice, appending to the end
    idxs = max_idx-samp_margin:max_idx + samp_margin;

    if(idxs(1) < 1)
        RC_slice = circshift(RC_slice,-idxs(1) + 1, 1);
        idxs = idxs + (idxs(1) + 1);
    elseif (idxs(end) > size(RC_slice,1))
        RC_slice = circshift(RC_slice,size(RC_slice,1) - idxs(end), 1);
        idxs = idxs - (idxs(end) - size(RC_slice,1));
    end

    if slice_idx == 1
        m.Drc   = zeros(length(idxs), size(A,2), 'like',A);
    end

    % Save it
    m.Drc(:,slice_idx:slice_idx+N_slice-1) = RC_slice;
end

close(f);

tau_ax = 0:radar_parameters.PRI:size(A,2);
t_ax = (-samp_margin/2:samp_margin/2)*dt;


end

