function res = one_shot()
% one_shot - example for one step reachability analysis to compare
% precision with growth bound
%
% Syntax:  
%    one_shot
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

c = [-1.16167;-1.16167;-1.16167];
G = [0 0 0; 0 0 0; 0 0 0];

c_d = [ 0; 0; 0];
G_d = [0.1 0 0; 0 0.1 0; 0 0 0.1];

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
t = toc;
disp("time: " + t);
%  Z = box(R(5,1).timePoint.set{1, 1});
 Z = box(R.timePoint.set{fin_step, 1});
  disp("in each dimension: ");
 disp(Z.Z(1, 2)/0.1);
 disp(Z.Z(2, 3)/0.1);
 disp(Z.Z(3, 4)/0.1);

%------------- END OF CODE --------------