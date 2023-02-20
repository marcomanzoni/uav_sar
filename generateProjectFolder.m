mainFolder = "D:\Droni_Campaigns\20230208_monte_barro_auto_2";
experimentName = "exp1";

folderName = fullfile(mainFolder, experimentName);

if exist(folderName,"dir")
    error("Folder already present");
end

mkdir(folderName);

mkdir(fullfile(folderName, "raw"));
mkdir(fullfile(folderName, "rc"));
mkdir(fullfile(folderName, "images"));
mkdir(fullfile(folderName, "trajectories"));
