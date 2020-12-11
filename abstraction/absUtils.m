classdef absUtils
    
% Utility functions for abstraction's computations.
%
% Author:       Ivan Fedotov
% Written:      10-December-2020 
% Last update:   ---
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
    end
    
end

