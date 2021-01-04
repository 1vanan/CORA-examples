function nonConvexUnicycle()
% nonConvexShot - example for reachability analysis with unicycle model
% from scots
%
% Syntax:  
%    nonConvexShot
%
% Inputs:
%    no
%
% Outputs:
%    res - boolean
%
% References:
%   -

% Author:        Ivan Fedotov
% Written:       24-December-2020
% Last update:   ---
% Last revision: ---

%------------- BEGIN CODE --------------

% Parameters --------------------------------------------------------------
options.tStart = 0;   % Start time
options.tFinal = 3;   % Final time
u = absUtils;

c = [1;1;1];
G = [0 0 0; 0 0 0; 0 0 0];

c_d = [ 0; 0; 0];
G_d = [0.005 0 0; 0 0.005 0; 0 0 0.005];

% Describe initial set as a zonotope as a point (without generators) and
% disturbance 
% state zonotope
options.R0 = zonotope(c, G);

% Disturbance zonotope
options.uTrans = 0;
options.U = zonotope(c_d, G_d); % no external inputs

% Reachability Settings ---------------------------------------------------

options.timeStep = 0.005;        % Time step size
options.taylorTerms = 50;        % Taylor terms
options.zonotopeOrder = 30;     % Zonotope order

options.advancedLinErrorComp = 0;
options.alg                  = 'lin';
options.tensorOrder          = 3;
options.errorOrder           = 5;
options.intermediateOrder    = 20;
options.maxError             = [1; 1; 1];
options.reductionInterval    = Inf;
options.reductionTechnique = 'girard';
% System Dynamics ---------------------------------------------------------
vehicle = nonlinearSys(3,3,@Vehicle_Dyn,options);
vehicle_opts = grid_options([-10 -10 0], [10 10 20], [0.01 0.01 0.01]);
vehicle_grid = uniformGrid(vehicle_opts);

% Reachability Analysis ---------------------------------------------------
tic
cells = u.findWinningDomain(vehicle, options, vehicle_grid);
t = toc;
disp("amount of cells: ");
disp(cells);

disp("computation time: ");
disp(t);
%------------- END OF CODE --------------

end
