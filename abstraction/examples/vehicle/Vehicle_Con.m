classdef Vehicle_Con
% Vehicle_Dyn - class for algebraic function for vehicle examples from
% scots. As there are no algebraic part, the function here is empty.
%
% Syntax:
%    f = Vehicle_Con(inputs)
%
% Inputs:
%    inputs - array of inputs for algebraic function
%
% Outputs:
%    f - vector storing the time-derivatives of the states

% Author:       Ivan Fedotov
% Written:      11-Nov-2020
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------
    properties
        inputs;
        % number of algebraic constraints
        constraints = 1;
    end

    methods
        function f = con_eq(obj,x,y,~)
            f(1,1) = y(1);
        end
    end
end

%------------- END OF CODE --------------
