function traj = alignTrajectoryWithRadarData(lat, lon, alt, speed, time_stamp, tau_ax, Nbegin, Nend)
%ALIGNTRAJECTORYWITHRADARDATA Align the trajectory with radar data, convert
%it it local coordinates and align the trajectory with x.
%
% Inputs:
%       lat:            vector with the latitude coordinates of the trajectory
%       lon:            vector with the longitude coordinates of the trajectory
%       alt:            vector with the altitude coordinates of the trajectory
%       speed :         vector with the instantaneous speed of the trajectory
%       time_stamp:     time stamp of the navigation unit
%       tau_ax:         radar slow time axis
%       Nbegin:         slow-time samples at which the platform starts to
%                       move. This sample will be aligned with the first sample of the
%                       trajectory with non-zero speed.
%       Nbegin:         slow-time samples at which the platform stops
%
% Outputs:
%       traj:       structure containing the following paramterers
%       traj.Sx:    x position (along track)
%       traj.Sy     y position
%       traj.Sz     z position
%       traj.speed  instantaneous speed
%       traj.tau_ax slow-time in UTC
%       traj.Nbegin same as input
%       traj.Nend   same as input



% Convert from lat lon to local coordinates w.r.t
idx_start = find(speed~=0, 1, 'first');
idx_end = find(speed~=0, 1, 'last');

figure; plot(speed); hold on; plot(idx_start, speed(idx_start), 'gd'); grid on;
plot(idx_end, speed(idx_end), 'rd'); title("Instantaneous NU Speed"); xlabel("Time"); ylabel("Speed [m/s]");

origin = [mean(lat(idx_start:idx_end)), mean(lon(idx_start:idx_end)), mean(alt(idx_start:idx_end))];
[xEast, yNorth, zUp] = latlon2local(lat, lon, alt, origin); 

% Compute again the speed of the vehicle, the one on the navigator is
% wrong...
dt = seconds(diff(time_stamp));
dt = [dt(1); dt];

Vx = gradient(xEast)./dt;
Vy = gradient(yNorth)./dt;
Vz = gradient(zUp)./dt;
new_speed = sqrt(Vx.^2 + Vy.^2 + Vz.^2);

% Compute again the start and end of the trajectory with the new speed
idx_start = find(new_speed~=0, 1, 'first');
idx_end = find(new_speed~=0, 1, 'last');

plot(new_speed); hold on; plot(idx_start, new_speed(idx_start), 'gd');
plot(idx_end, new_speed(idx_end), 'rd');
legend("NU speed", "Start", "End", "Speed re-computed using NU positions");

origin = [mean(lat(idx_start:idx_end)), mean(lon(idx_start:idx_end)), mean(alt(idx_start:idx_end))];
[xEast, yNorth, zUp] = latlon2local(lat, lon, alt, origin); 

% Rotate the trajectory to be aligned with x
x_begin = xEast(idx_start); x_end = xEast(idx_end);
y_begin = yNorth(idx_start); y_end = yNorth(idx_end);
beta = atan2d((y_end-y_begin),(x_end-x_begin));

H = [cosd(beta) sind(beta); -sind(beta) cosd(beta)];

P = H*[xEast' ; yNorth'];
Sx = P(1,:)';
Sy = P(2,:)';
Sz = zUp;

figure; plot(xEast, yNorth); axis equal; grid on; hold on;
plot(x_begin, y_begin, 'gd');
plot(x_end, y_end, 'rd');
plot(Sx,Sy); axis tight;
plot(Sx(idx_start), Sy(idx_start), 'gd');
plot(Sx(idx_end), Sy(idx_end), 'rd');
title("Trajectory");
xlabel("x [m]"); ylabel("y [m]");
legend("ENU", "Start", "End", "X-Aligned");

% Start time of the trajectory
time_start = time_stamp(idx_start);
time_end = time_stamp(idx_end);

% Change the slow time axis to be aligned with the starting point
tau_ax = tau_ax - tau_ax(Nbegin);
new_tau_ax = time_start + seconds(tau_ax);

% Now I interpolate to align the two
temp = interp1(time_stamp, [Sx,Sy,Sz], new_tau_ax, 'linear');
Sx = temp(:,1);
Sy = temp(:,2);
Sz = temp(:,3);

nav_speed = interp1(time_stamp, speed, new_tau_ax, 'linear');

traj.Sx = Sx;
traj.Sy = Sy;
traj.Sz = Sz;
traj.speed = nav_speed;
traj.tau_ax = new_tau_ax;
traj.idx_start = Nbegin;
traj.idx_end = Nend; 

% 
% dt = mean(diff(tau_ax));
% Vx = gradient(Sx)./dt;
% Vy = gradient(Sy)./dt;
% Vz = gradient(Sz)./dt;
% new_speed = sqrt(Vx.^2 + Vy.^2 + Vz.^2);
% 
% figure; plot(tau_ax, nav_speed); grid on;

end

