mainFolder = "D:\Droni_Campaigns\20230331_giuriati_2";
experimentName = "exp15";

folderName = fullfile(mainFolder, experimentName);

if exist(folderName,"dir")
    error("Folder already present");
end

mkdir(folderName);

mkdir(fullfile(folderName, "raw"));
mkdir(fullfile(folderName, "rc"));
mkdir(fullfile(folderName, "images"));
mkdir(fullfile(folderName, "trajectories"));
mkdir(fullfile(folderName, "waveform"));
