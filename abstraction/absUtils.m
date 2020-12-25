classdef absUtils
    
% Utility functions for abstraction's computations.
%
% Author:       Ivan Fedotov
% Written:      10-December-2020 
% Last update:  24-December-2020 
% Last revision: ---

%------------- BEGIN CODE --------------
    methods
        % For provided zonotope and grid get cells that intersect this
        % zonotope
        function cells = getCells(obj, zonotopeCheck, grid)
            cells_amount = grid.total_cells;
            
            % function isIntersecting returns true even if one zonotope
            % touches the border on another one, but don't invade inside.
            % To avoid this, we decrement each non-zero coordinate of 
            % generators on some amount which is smaller than grid cell.
            % But in this case  we can lose intersections,
            % if the vector gous out less than on precision value 
            % compressedCheck = ...
            %     obj.compress(zonotopeCheck, grid.err(1)*0.001);

            %assume that the rror is the same for all dimensions
            diagEls = zeros(grid.dim,1)+grid.err(1) / 2;
            generators = diag(diagEls);
            init = true;

            for i = 1 : cells_amount
                %vector to the start of the cell
                state = grid.itox(i);
                center = zeros(grid.dim, 1);
    
                for j = 1 : grid.dim
                    if(j == 1)
                        center(j) = state(j) - grid.err(1)/2;
                    else
                        center(j) = state(j) + grid.err(1)/2;
                    end
                end
    
            cell = zonotope(center, generators);
            try
                if(isIntersecting(zonotopeCheck, cell))
                    if(init)
                        cells = [cell];
                        init = false;
                    else
                        cells(end+1) = cell;
                    end
                    disp("center: ");
                    disp(center);
                    disp("generators: ");
                    disp(generators);
                end
            catch
                disp("error! on: ");
                disp(zonotopeCheck.Z);
                disp("cell: ");
                disp(cell.Z);
            end
            end
            if(init)
                disp("no intersection inside the provided grid");
                cells = zonotope.empty;
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
                sys,params, options, grid)
            fin_step = (params.tFinal - params.tStart) / options.timeStep;
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
                sys, params, options, grid)
            fin_step = (params.tFinal - params.tStart) / options.timeStep;
            allZonotopes = zonotope.empty;
            %hyperinterval is represented as a zonotope
            cells = zonotope.empty;
            tic
            for i = 0 : intervalsAmount - 1
                R_i = reach(sys, params, options);
                params.R0 = R_i.timePoint.set{fin_step, 1};
                allZonotopes(end+1) = params.R0;
            end
            t1 = toc;
            disp("computation time: " + t1);
            tic
            for reachableSet = allZonotopes
                cells(end+1) = getCells(obj,reachableSet, grid);
            end
            t2 = toc;
            disp("projection time: " + t2);
        end      
            
    end
    
end

