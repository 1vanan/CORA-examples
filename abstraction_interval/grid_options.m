classdef grid_options
% grid_options - class for storing information about state space and 
% input space. Input in the sense of control input, not disturbance.
%
% Syntax:  
%    obj = grid_options(lower_bound, upper_bound, err)
%
% Inputs:
%    lower_bound - n-dimensional aray of lower bounds.
%    upper_bound - n-dimensional aray of upper bounds.
%    err - n-dimensional aray of cell sizes.
%
% Outputs:
%    obj - object with grid options
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%

% Author:       Ivan Fedotov
% Written:      21-October-2020 
% Last update:  ---
% Last revision: ---

%------------- BEGIN CODE --------------
    
    properties (GetAccess = public, SetAccess = private)
        lower_bound;
        upper_bound;
        err;
    end
    
    methods
        function obj = grid_options(lower_bound, upper_bound, err)
            obj.lower_bound = lower_bound;
            obj.upper_bound = upper_bound;
            obj.err = err;
        end
    end
end

%------------- END OF CODE --------------