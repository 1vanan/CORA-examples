function  oneShot()
% oneShot - example for one step reachability analysis to compare
% precision with growth bound
%
% Syntax:  
%    oneShot
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
% Written:       25-November-2020
% Last update:   ---
% Last revision: ---

%------------- BEGIN CODE --------------

% Parameters --------------------------------------------------------------
params.tStart = 0;   % Start time
params.tFinal = 3;   % Final time

u = absUtils;

c = [1;1;1];
G = [0 0 0; 0 0 0; 0 0 0];

c_d = [ 0; 0; 0];
G_d = [0.005 0 0; 0 0.005 0; 0 0 0.005];

state_gr_opt = grid_options([0 0 5], [1 1 6], [0.01 0.01 0.01]);
  
grid = uniformGrid(state_gr_opt);

% Describe initial set as a zonotope as a point (without generators) and
% disturbance 
% state zonotope
params.R0 = zonotope(c, G);

% Disturbance zonotope
params.U = zonotope(c_d, G_d); % no external inputs

% Reachability Settings ---------------------------------------------------

options.timeStep = 0.005;        % Time step size
options.taylorTerms = 50;        % Taylor terms
options.zonotopeOrder = 30;     % Zonotope order
 
fin_step = (params.tFinal - params.tStart) / options.timeStep;

options.alg                  = 'lin';
options.tensorOrder          = 3;
options.errorOrder           = 5;
options.intermediateOrder    = 20;
options.maxError             = [1; 1; 1];
options.reductionInterval    = Inf;


% System Dynamics ---------------------------------------------------------
vehicle = Vehicle_Dyn;
vehicle.inputs = [1, 1, 1];
dynFun = @(x,u) vehicle.dyn_eq(x,u);
sys = nonlinearSys('vehicle',dynFun,3,3);


% Reachability Analysis ---------------------------------------------------

% Compute reachable set 
tic
R = reach(sys, params, options);
t1 = toc;
disp("reachability computation time: " + t1);
%  Z = box(R(5,1).timePoint.set{1, 1});
tic
zonotopeCheck = R.timePoint.set{fin_step, 1};
cells = u.getCells(zonotopeCheck, grid);
t2 = toc; 
disp("projection time: " + t2);
disp("amount of cells: ");
disp(size(cells));

%------------- END OF CODE --------------

end
