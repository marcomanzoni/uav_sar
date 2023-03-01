function I = focusDroneTDBP(Drc, t_ax, f0, Sx, Sy, Sz, X,Y,Z, rho_az, squint)
%FOCUSDRONETDBP Summary of this function goes here
%   Detailed explanation goes here

% Axes, size, and physical constant
c       = physconst('LightSpeed');
lambda  = c/f0;

Ntau = length(Sx);
[Ny,Nx] = size(X);

x_ax = X(1,:); 
dx = x_ax(2)-x_ax(1);

y_ax = Y(:,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Angle-depending weighting factor
delta_Ks = 2*pi/rho_az;

tau_ref = round(Ntau/2);

delta_x = X - Sx(tau_ref);
delta_y = Y - Sy(tau_ref);
delta_z = Z - Sz(tau_ref);

R = sqrt(delta_x.^2 + delta_y.^2 + delta_z.^2);
P = asind(delta_x./R);

Ks = 4*pi/lambda*sind(P - squint);
A = Ks/delta_Ks;
W = exp(-4*A.^2);
%W = rectpuls(A);
tol = 1e-2;
ind = find(W(:) > tol);

% Indexes of pixels for which the weighting function is > 0
[Yc_ref,Xc_ref] = ind2sub([Ny Nx],ind); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRIPMAP BACK PROJECTION
Y_loc = Y(ind);
I = zeros(size(X));
scaling = zeros(size(X));

WAITBAR = waitbar(0,'Backprojecting...');

for tau = 1:Ntau
    waitbar(tau/Ntau,WAITBAR)
    
    % Index of samples to be backprojected
    delta_Sx = Sx(tau) - Sx(tau_ref);
    delta_x_camp = round(delta_Sx/dx);
    Xc_loc = Xc_ref + delta_x_camp;
    ind_loc = (Xc_loc-1)*Ny + Yc_ref;
    ind_loc(ind_loc<1) = 1;
    ind_loc(ind_loc>Nx*Ny) = Nx*Ny;
    % Coordinates
    X_loc = X(ind_loc); 
    Z_loc = Z(ind_loc);
    % Distances and angles
    delta_x = X_loc - Sx(tau);
    delta_y = Y_loc - Sy(tau);
    delta_z = Z_loc - Sz(tau);
    R = sqrt(delta_x.^2 + delta_y.^2 + delta_z.^2);
    P = asind(delta_x./R);
    Ks = 4*pi/lambda*sind(P-squint);
    A = Ks/delta_Ks;
    W = exp(-4*A.^2);
    %W = rectpuls(A);
    delay = (2*R)/c;
    % Interpolation, phase rotation, and accumulation 

    Itau = interp1(t_ax,Drc(:,tau),delay,'linear',0);
    Itau = W.*Itau.*exp(+1i*2*pi*f0*delay);
    I(ind_loc) = I(ind_loc) + Itau;
    scaling(ind_loc) = scaling(ind_loc) + 1;
end

I = I./scaling;

close(WAITBAR)




end

