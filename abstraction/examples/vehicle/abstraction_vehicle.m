function abstraction_vehicle()
% abstraction_vehicle - vehicle example from scots.
%
% Syntax:  
%    abstraction_vehicle()
%
% Inputs:
%    no
%
% Outputs:
%    no
%
% Example: 
%
% References:
%    -

% Author:       Ivan Fedotov
% Written:      10-Nov-2020
% Last update:  ---
% Last revision:---


%------------- BEGIN CODE --------------

% System Dynamics ---------------------------------------------------------
dif = Vehicle_Dyn;
alg = Vehicle_Con;

% Parameters and options for grid and algorythm ---------------------------
% lower and upper bounds and error for 3-dim state space.
state_gr_opt = grid_options([0 0 -3.5], [3 3 3.5], [0.3 0.3 0.3]);
% lower and upper bounds and error for 2-dim input space.
input_gr_opt = grid_options([-1 -1], [1 1], [0.3 0.3]);
r_params.tFinal = 0.3; % the final time for analysis.

% one time step calculation. If the error is too big, will be decreased.
% don't work: 0.15 
r_options.timeStep = 0.1;
% order of Taylor series expansion for the exp(A\delta t)
r_options.taylorTerms = 2; 
%upper bound = p/n, p - sum members, n - dimension.
r_options.zonotopeOrder = 2; 
% zonotope order is reduced to error order
r_options.errorOrder = 3; 
% order of the Taylor series expansion. Default is 2
r_options.tensorOrder = 2; 
% max overall error. default - infinity
r_options.maxError = [0.3; 0.3; 0.3]; 
% max dif. error. default - infinity
r_options.maxError_x = r_options.maxError; 
% max alg. error. default - infinity
r_options.maxError_y = 0.3;

% Reachability Analysis ---------------------------------------------------
% path to save result.
path = "./reachability_vehicle.json";
% provide one more argument, "false", if disable of enclosing box is needed
solver = reach_solver(state_gr_opt, input_gr_opt, ...
    r_params, r_options);
tic
solver.compute(path, alg, dif);
elapsed_time = toc;
disp(elapsed_time);

% Visualization -----------------------------------------------------------
%TODO
end

%------------- END OF CODE --------------
