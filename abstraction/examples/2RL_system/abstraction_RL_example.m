function abstraction_RL_example()
% abstraction_RL_example - example of nonlinear-differential-algebraic
%     reachability analysis for 2-RL power system using cells set of inputs
%    and states.
%
% Syntax:
%    abstraction_RL_example()
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
% Written:      21-Oct-2020
% Last update:  TODO: come up with optimal time step and error
% Last revision:---


%------------- BEGIN CODE --------------

% System Dynamics ---------------------------------------------------------
dif = RL_Dyn;
alg = RL_Con;

% Parameters and options for grid and algorythm ---------------------------
% lower and upper bounds and error for 2-dim state space.
state_gr_opt = grid_options([205 205], [206 206], [0.5 0.5]);
% lower and upper bounds and error for 2-dim input space.
input_gr_opt = grid_options([10 10], [11 11], [0.5 0.5]);
r_params.tFinal = 0.25; % the final time for analysis.

% one time step calculation. If the error is too big, will be decreased.
r_options.timeStep = 0.01;
% order of Taylor series expansion for the exp(A\delta t)
r_options.taylorTerms = 20;
%upper bound = p/n, p - sum members, n - dimension.
r_options.zonotopeOrder = 20;
% zonotope order is reduced to error order
r_options.errorOrder = 200;
% order of the Taylor series expansion. Default is 2
r_options.tensorOrder = 2;
% max overall error. default - infinity
r_options.maxError = [10; 10];
% max dif. error. default - infinity
r_options.maxError_x = r_options.maxError;
% max alg. error. default - infinity
r_options.maxError_y = 10;

% Reachability Analysis ---------------------------------------------------
% path for saving result.
path = "./reachability_res.json";
solver = reach_solver(state_gr_opt, input_gr_opt, ...
    r_params, r_options);
solver.compute(path, alg, dif);

% Visualization -----------------------------------------------------------
end

%------------- END OF CODE --------------
