function nonConvexShot()
% nonConvexShot - example for reachability analysis to within defined time steps
% and non-convex final reachable set. Comparison result with scots: 16
% cells versus 383.
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
options.reductionTechnique = 'girard'
% System Dynamics ---------------------------------------------------------
sys = nonlinearSys(3,3,@Vehicle_Dyn,options);


% Reachability Analysis ---------------------------------------------------
tic
% cells = u.getAllCells(itarations, sys, options, [0.01 0.01 0.01]);
left = [0.6; 1.3; 14];
right = [0.7; 1.4; 16];
winning = interval(left, right);
cells = u.findWinningDomain(sys, options, [0.01 0.01 0.01], winning);
disp("amount of cells: ");
disp(cells);

%------------- END OF CODE --------------

end
