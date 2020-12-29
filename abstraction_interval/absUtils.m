classdef absUtils
    
% Utility functions for abstraction's computations.
%
% Author:       Ivan Fedotov
% Written:      10-December-2020 
% Last update:  24-December-2020 
% Last revision: ---

%------------- BEGIN CODE --------------
    methods
        % For provided zonotope and vector of cell size in eacg dimension
        % compute amount of cells that intersect a zonotope.
        function cells = getCells(obj, zonotopeCheck, steps)
            cells = 0;
            s = size(zonotopeCheck.Z(:,1));
            dim = s(1);
            encl = box(zonotopeCheck);
            left_bound = zeros(dim, 1);
            right_bound = zeros(dim, 1);
            
            % compute right and left bounds of enclosing box in each
            % dimension according to radius size.
            for d = 1 : dim
                disp("dimension: " + d);
                left_bound(d) = floor((encl.Z(d,1) - ...
                    encl.Z(d,d+1))/steps(d))*steps(d);
                right_bound(d) = ceil((encl.Z(d,1) + ...
                    encl.Z(d,d+1))/steps(d))*steps(d);
                disp("left: " + left_bound(d));
                disp("right: " + right_bound(d));
            end
            
            state_gr_opt = grid_options(left_bound, right_bound, steps);
  
            grid = uniformGrid(state_gr_opt);
            cells_amount = grid.total_cells;
            % compute the intersection with the grid cells only around
            % enclosing box ares to reduce computation cost.
            for i = 1 : cells_amount
                left = zeros(grid.dim, 1);
                right = zeros(grid.dim, 1);
                %vector to the start of the cell
                state = grid.itox(i);
    
                for j = 1 : grid.dim
                    if(j == 1)
                        right(j) = state(j);
                        left(j) = state(j) - grid.err(1);
                    else
                        left(j) = state(j);
                        right(j) = state(j) + grid.err(1);
                    end
                end
            intv = interval(left, right);
                if(isIntersecting(intv, zonotopeCheck))
                    cells = cells + 1;
                end
            end
        end
        
        % For the provided zonotope decrease each generator on the value
        % err. Decrement on err works only for non-zero coordinates of
        % generators.
        function compressedZonotope = compress(obj, z, err)
            temp_array = size(z.Z);
            gen_nums = temp_array(2)-1;

            newGenerators = z.Z;
            newGenerators(:,1) = [];
            
            % decrease each non-zero coordinate of generators on err.
            for i = 1 : gen_nums
                for j = 1 : gen_nums
                    if(newGenerators(i,j) > 0)
                        newGenerators(i,j) = newGenerators(i,j) - err;
                    else
                        if(newGenerators(i,j) < 0)
                            newGenerators(i,j) = newGenerators(i,j) + err;
                        end
                    end
                end
                
                compressedZonotope = zonotope(z.Z(:,1), newGenerators);
            end
        
        end
        
        % for the provided initial zonotope and dynamics returns the cells
        % that intersect with the last reachable zonotope according to the 
        % given grid.
        function cells = getLastCells(obj, steps, ... 
                sys, options, grid)
            fin_step = (options.tFinal - options.tStart) / options.timeStep;
            tic
             for i = 0 : steps - 1
                R_i = reach(sys, params, options);
                params.R0 = R_i.timePoint.set{fin_step, 1};
             end
            t1 = toc;
            disp("computation time: " + t1);
            last = params.R0;
            tic
            cells = getCells(obj,last, grid);
            t2 = toc;
            disp("projection time: " + t2);
        end

        % for the provided initial zonotope and dynamics returns the cells
        % that intersect with the whole non-convex path that connects the
        % initial zonotope, intermediate zonotopes and the last one.
        function cells = getAllCells(obj, intervalsAmount, ...
                sys, options, steps)
            fin_step = (options.tFinal - options.tStart) / options.timeStep;
            %hyperinterval is represented as a zonotope
            cells = 0;
            tic
            for i = 0 : intervalsAmount - 1
                R_i = reach(sys, options);
                options.R0 = R_i{fin_step, 1}{1,1};
                cells = cells + getCells(obj,options.R0, steps);
            end
            t1 = toc;
            disp("computation time: " + t1);
        end      
            
        function cells = findWinningDomain(obj, sys, options, steps, win)
            fin_step = (options.tFinal - options.tStart) / options.timeStep;
            %hyperinterval is represented as a zonotope
            cells = 0;
            tic
            while 1
                R_i = reach(sys, options);
                options.R0 = R_i{fin_step, 1}{1,1};
                cells = cells + getCells(obj,options.R0, steps);
                if isIntersecting(win, options.R0)
                    break;
                end
            end
            t1 = toc;
            disp("computation time: " + t1);
        end  
    end
    
end

