function nonConvexAutonomusVehicle()
% nonConvexAutonomusVehicle - example for reachability analysis with 
% the autonomous car model.
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
% Written:       30-December-2020
% Last update:   ---
% Last revision: ---

%------------- BEGIN CODE --------------

% Parameters --------------------------------------------------------------
dim=8;
options.tStart = 0;   % Start time
options.tFinal = 3.99;   % Final time
options.maxError = 10 * ones(dim,1);
u = absUtils;

options.x0=[0; 0; 0; 22; 0 ; 0; -2.1854; 0]; %initial state for simulation
options.R0 = zonotope([options.x0, 0*diag([1, 1, 1, 1, 1, 1, 1, 1])]); %initial state for reachability analysiszonotope([options.x0, diag([0.20, 0.20])]); %max for 3rd order

% Reachability Settings ---------------------------------------------------

options.timeStep=0.01; %time step size for reachable set computation
options.taylorTerms=5; %number of taylor terms for reachable sets
options.zonotopeOrder=200; %zonotope order

options.uTransVec = uTRansVec4CASreach();
options.u = 0;
options.U = zonotope([0*options.uTransVec(:,1), 0.05*diag([ones(5,1);zeros(21,1)])]);

options.advancedLinErrorComp = 0;
options.tensorOrder = 1;
options.reductionInterval = inf;
options.reductionTechnique = 'girard';

% System Dynamics ---------------------------------------------------------
car = nonlinearSys(8,26,@vmodel_A_bicycle_linear_controlled,options);
car_opts = grid_options(-100 + zeros(8,1), 100 + zeros(8,1), 0.1 + zeros(8,1));
car_grid = uniformGrid(car_opts);

% Reachability Analysis ---------------------------------------------------
tic
cells = u.findWinningDomain(car, options, car_grid);
t = toc;
disp("amount of cells: ");
disp(cells);

disp("computation time: ");
disp(t);
%------------- END OF CODE --------------

end

