function rawDataConvert(experiment_folder, samplesPerChirp)
%RAWDATACONVERT Summary of this function goes here
%   Detailed explanation goes here

directoryContent = dir(fullfile(experiment_folder,"raw","*.mat"));
if length(directoryContent) > 0
    warning("A .mat file is already present in the folder, skipping the .dat -> .mat conversion.")
    return;
end

% Get the content of the directory
directoryContent = dir(fullfile(experiment_folder,"raw","*.dat"));
if length(directoryContent) ~= 1
    error("More than one raw data file in the folder. Inside this folder you should have ONE .dat file coming directly from the SDR.");
end

file_path = fullfile(directoryContent.folder, directoryContent.name);

% Get the timestamp of the end of the acquisition
% last_mod_date = datetime(dir(file_path).date,'Locale','it_IT','InputFormat','dd-MMM-yyyy HH:mm:ss','Format','yyyy-MM-dd HH:mm:ss.SSS');
lastModDate = datetime(directoryContent(1).date,'Locale','it_IT','InputFormat','dd-MMM-yyyy HH:mm:ss','Format','yyyyMMdd-HHmmss');

% Open the file and read it in chunks of 1GB
f       = fopen(file_path, 'rb');

read_L  = 1e9;                       % length to be read each iteration
values  = zeros(read_L,1,"int16");
idx     = 1;
y       = zeros(0,1,'int16');

LL = directoryContent(1).bytes /4;

while ~isempty(values) 
    values  = fread(f,read_L,"int16=>int16");
    C       = complex(values(1:2:end-1),values(2:2:end));
    y       = [y;C];
    disp(['Read ' num2str(length(y)/LL*100) '%'])
end

fclose(f);

% Reshape the matrix in fast time and slow time
L = floor(length(y) / samplesPerChirp) * samplesPerChirp;
Draw = reshape(y(1:L),samplesPerChirp,[]);
clear y

dataSize = size(Draw);

% Save the raw data into a .mat file with some ancillary information
fprintf("Start saving... it may take a while: ");

savingFilename = fullfile(experiment_folder,"raw", strcat(directoryContent.name(1:end-4), ".mat"));
save(savingFilename, "Draw", '-v7.3', '-nocompression');
save(savingFilename, "dataSize", '-append');
save(savingFilename, "lastModDate", '-append');
fprintf("Done. \n");

% addpath(genpath([pwd, filesep, '..\..\lib' ]));       % add path of lib
% A = single(A);
% disp('Start saving...')
% save_bin(file_path(1:end-4),A);
% save([file_path(1:end-4) '_last_mod_date'],'last_mod_date')
% disp(strcat('Done ',num2str(i), "/",num2str(length(dir_out))))


end

