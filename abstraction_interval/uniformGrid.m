classdef uniformGrid
    
% uniformGrid - information about uniform grid in dim-dimensional space.
%
% Syntax:  
%    obj = uniformGrid(dim, err, first, num_points, nn)
%
% Inputs:
%    dim - amount of dimensions
%    err - size of cell in grid
%    first - vector of the first values
%    num_points - amount of grid points in each dimension
%    nn - multiplicator for all previous dimensions
%
% Outputs:
%    obj - generated grid
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
% https://gitlab.lrz.de/matthias/SCOTSv0.2/-/blob/master/src/UniformGrid.hh

% Author:       Ivan Fedotov
% Written:      20-October-2020 
% Last update:   ---
% Last revision: ---

%------------- BEGIN CODE --------------


    properties (GetAccess = public, SetAccess = private)
        % dimension of the Eucleadian space.
        dim {mustBeNumeric};
        
        % array containing the cell size
        err = [];
        
        % array containing the real values of the first grid point
        first = [];
        
        % array containing the real values of the last grid point
        last = [];
        
        % array containing the number of grid points in each dimension
        num_points = [];
        
        % array recursively defined by:
        % m_NN[1]=1; m_NN[i]=m_NN[i-1}*no_grid_points[i-1]
        nn = [];
    end
    
    
 methods

     function obj = uniformGrid(grid_options)
         obj.dim = length(grid_options.lower_bound);
         obj.err = grid_options.err;
         obj.first = grid_options.lower_bound;
         obj.last = grid_options.upper_bound;
         
         total = 1;
         for d = 1 : obj.dim
             cell_size = grid_options.err(d);
             ub = grid_options.upper_bound(d);
             lb = grid_options.lower_bound(d);
             % rounding heuristic
             round_h = cell_size/1e10;
             % number of cells from zero to left bound
             no_l = round(abs(lb)/cell_size + 0.5 - round_h);
             % number of cells from zero to right bound
             no_u = round(abs(ub)/cell_size + 0.5 - round_h);
             obj.num_points(d) = sign(ub)*no_u - sign(lb)*no_l + 1;
             
             % compute dimensional multiplicator
             obj.nn(d) = total;
             total = total * obj.num_points(d);
         end
     end 

     % Each cell in n-dim hypercube is assigned to index. Access to the
     % vector state representation can be done by this enumeration.
     % Amount of cells in each dimension is multiplied by nn and sum up
     % with amount of cells from the previous iteration.
    function id = xtoi (obj, x_dot)
        id = 0;
        for d = 1 : obj.dim
            err_d = obj.err(d)/2;
            id_d = x_dot(d) - obj.first(d);
           
            if id_d<err_d || id_d > obj.num_points(d)*obj.err(d) + err_d
                throw(MException('Outside of uniform grid'));
            end
            id = id + ((id_d + err_d)/obj.err(d))*obj.nn(d);
        end
        
    end
    
    % Converting from index to vector. Start from the highest dimension and
    % "unwrap" length from zero to the cell with index id in each
    % dimension.
    function x_dot = itox (obj, id) % TODO: fix upper bound
        x_dot = zeros(obj.dim, 1);
        for i=obj.dim:-1:2
            num = floor(id/obj.nn(i));
            id = mod (id, obj.nn(i));
            x_dot(i) = obj.first(i) + num * obj.err(i);
        end
        num = id;
        x_dot(1) = obj.first(1) + num * obj.err(1);
    end
    
    function total = total_cells(obj)
        total = 1;
        for d = 1 : obj.dim
            total = total * obj.num_points(d);
        end
    end
    
 end
 
end
    
%------------- END OF CODE --------------