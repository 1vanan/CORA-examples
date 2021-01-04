function nonConvexTank()
% nonConvexTank - example for reachability analysis with tank model
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
dim=6;
options.tStart = 0;   % Start time
options.tFinal = 3;   % Final time
u = absUtils;

C=[2; 4; 4; 2; 10; 4];
G = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]; 
options.R0=zonotope(C, G);
options.uTrans = 0;
options.U = zonotope([0,0.005]); %input for reachability analysis

% Reachability Settings ---------------------------------------------------

options.timeStep = 0.005;        % Time step size
options.taylorTerms = 50;        % Taylor terms
options.zonotopeOrder = 50;     % Zonotope order

options.originContained = 0;
options.advancedLinErrorComp = 0;
options.alg                  = 'lin';
options.tensorOrder          = 2;
options.intermediateOrder    = 50;
options.reductionTechnique='girard';
options.errorOrder=3;
options.polytopeOrder=3; %polytope order
options.reductionInterval=1e3;
options.maxError = 0.005*ones(dim,1);


% System Dynamics ---------------------------------------------------------
tank = nonlinearSys(6,1,@tank6Eq,options); %initialize tank system
tank_opts = grid_options([1.85 2.3 3.14 2 8 4], [10 10 5 3 10 5.4], [0.01 0.01 0.01 0.01 0.01 0.01]);
tank_grid = uniformGrid(tank_opts);

% Reachability Analysis ---------------------------------------------------
tic
cells = u.findWinningDomain(tank, options, tank_grid);
t = toc;
disp("amount of cells: ");
disp(cells);

disp("computation time: ");
disp(t);
%------------- END OF CODE --------------

end