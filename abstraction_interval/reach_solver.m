classdef reach_solver
    
% reach_solver - compute reachability zonotopes for all possible
% permutations of input ans state cells.
%
% Syntax:  
%    obj = reachability(algebraic_system, differential_system, 
%    state_grid_options, input_grid_options, r_params, r_options)
%
% Inputs:
%    algebraic_system - vector funstion represented algebraic system
%    differential_system - vector funstion represented differential system
%    state_grid_options - uniformGrid object for state space
%    input_grid_options - uniformGrid object for input space
%    r_params - params for DAE reachability analysis, examples
%    in CORA\examples\contDynamics\nonlinDASys
%    r_options - options for DAE reachability analysis.
%
% Outputs:
%    obj - the set of final zonotopes
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
% https://gitlab.lrz.de/matthias/SCOTSv0.2/-/blob/master/src/Abstraction.hh

% Author:       Ivan Fedotov
% Written:      21-October-2020 
% Last update:  TODO: guess y0 and parallelalize reach loops with "parfor"
% improve printing progress 
% Last revision: ---

%------------- BEGIN CODE --------------
    
    properties (GetAccess = public, SetAccess = private)
        % state grid options must include the following n-dimensional 
        % arrays: lower_bound, upper_bound, err.
        state_grid_options;
        
        % input grid options.
        input_grid_options;
        
        % reachability params must include: tFinal, y0guess, R0, U.
        r_params
        
        % reachability options must include: timeStep, taylorTerms, 
        % zonotopeOrder,errorOrder, tensorOrder, maxError, maxError_x, 
        % maxError_y.
        r_options
        
        % put this flag in 'true' if writing to json enclosingaxis-aligned 
        % box, but not the whole zonotope is necessary. True by default.
        using_intervals;
    end
    
    methods
        function obj = reach_solver(varargin)
            obj.state_grid_options = varargin{1};
            obj.input_grid_options = varargin{2};
            obj.r_params = varargin{3};
            obj.r_options = varargin{4};
            
            if nargin > 4
                obj.using_intervals = varargin{5};
            else
                obj.using_intervals = true;
            end
        end
        
        function result = compute(obj, path, algebraic_s, differential_s)
            state_grid = uniformGrid(obj.state_grid_options);
            input_grid = uniformGrid(obj.input_grid_options);
            result = 0;
            
            % final step of zonotope calculation
            fin_step = obj.r_params.tFinal / obj.r_options.timeStep;
            
            % structure for JSON. 
            S = struct();
            
            %zonotope for disturbance. consist of only the center.
            %Represents the error - size of cell.
            state_cells_amount = state_grid.total_cells;
            error_matrix = zeros(state_grid.dim, state_grid.dim);
            error_matrix(:,1) = obj.state_grid_options.err;
            obj.r_params.U = zonotope(error_matrix);
            
            
% Reachability Analysis----------------------------------------------------
            % loop over all states
            for i = 0 : state_cells_amount - 1
                % print progress
                disp(".");
                
                state = state_grid.itox(i);
                state_matrix = zeros(state_grid.dim, state_grid.dim + 1);
                % center of the zonotope is a state
                state_matrix(:,1) = state;
                % generators: consist from error in each dimension.
                % Zonotope is represented as a n-dim cube.
                for k = 2 : size(state) + 1
                    state_matrix(k-1,k) = ...
                    obj.state_grid_options.err(k-1)/2;
                end
                tic
                % loop over all inputs
                for j = 0 : input_grid.total_cells - 1
                    inputs = input_grid.itox(j);
                    
                    %put input into equations
                    differential_s.inputs = inputs;
                    algebraic_s.inputs = inputs;
                    
                    % Guess for algebraic part TODO: how to guess it?
                    obj.r_params.y0guess = 0;
                    % zonotope for initial dif vars
                    obj.r_params.R0 = zonotope(state_matrix);
                    
                    powerDyn = nonlinDASys(@differential_s.dyn_eq, ...
                        @algebraic_s.con_eq, ...
                        state_grid.dim, state_grid.dim, ...
                        algebraic_s.constraints);
                    
% Reachability Analysis  for one cell--------------------------------------
                    R = reach(powerDyn, obj.r_params, obj.r_options);
                    
% Add Result To JSON ------------------------------------------------------
                    if obj.using_intervals
                        Z = box(R.timePoint.set{int8(fin_step), 1});
                        % disp("write a single zonotope");
                    else
                        Z = R.timePoint.set{int8(fin_step), 1};
                    end
                    
                    % amount of generators for the current iteration
                    temp_array = size(Z.Z);
                    gen_nums = temp_array(2);
                    
                    % generators for reachable set for current iteration
                    % generators = zeros(state_grid.dim, gen_nums);
                    for g = 2 : gen_nums
                        gen = Z.Z(:,g);
                        % avoid empty generators 
                        if nnz(gen) ~= 0
                            for d = 1 : state_grid.dim
                                generators(g-1, d) = gen(d);
                            end
                        end
                    end
                    
                    %create sceleton for the whole json for the first time.
                    % { "zonotopes": 
                    % [ { "input": [...], "state": [...], value: 
                    % { "center": [...], "generators": [...],...,[...] } }, 
                    %   {...}, ..., {...}]}
                    if (j == 0 && i == 0)
                        S = struct ("zonotope", struct("input", ...
                        inputs, "state", state, "value",struct("center",...
                        Z.Z(:,1), ...
                        "generators", generators)));
                    else 
                        % add to structure the current reachable zonotope  
                        % and meta info: 
                        S(end+1) = struct ("zonotope", struct("input",...
                        inputs, "state", state, "value",struct("center",...
                        Z.Z(:,1), ...
                        "generators", generators)));
                    end
                end
                t = toc
                disp("time: " + t);
                % create json and write it to the file    
                s = jsonencode(S);
                fileID = fopen(path, 'w');
                if fileID==-1
                    error('Cannot open file for writing: %s', file);
                end
                fprintf(fileID, s);
                fclose(fileID);
            end 
        end
    end
end

%------------- END OF CODE --------------