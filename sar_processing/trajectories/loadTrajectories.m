function traj = loadTrajectories(experiment_folder)

dirContent = dir(fullfile(experiment_folder,"trajectories","sensorlog*.mat"));
if length(dirContent) ~= 1
    error("More than one trajectory file present in the folder");
end

trajectory = load(fullfile(dirContent.folder,dirContent.name)).Position;

traj.lat         = trajectory.latitude;
traj.lon         = trajectory.longitude;
traj.alt         = trajectory.altitude;
traj.speed       = trajectory.speed;
traj.time_stamp  = trajectory.Timestamp;

fprintf("Trajectory recording begins at %s \n", traj.time_stamp(1));
fprintf("Trajectory recording ends at %s \n", traj.time_stamp(end));
fprintf("Total length of trajectory recording: %ds\n\n", seconds(traj.time_stamp(end)-traj.time_stamp(1)));

end