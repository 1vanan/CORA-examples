classdef RL_Con
% RL_Con - class for algebraic function for RL-power system
%
% Syntax:  
%    f = RL_Con(inputs)
%
% Inputs:
%    inputs - array of inputs for algebraic function
%
% Outputs:
%    f - vector storing the time-derivatives of the states

% Author:       Ivan Fedotov
% Written:      13-Sep-2020
% Last update:  21-Oct-2020 refactoring to class
% Last revision:---

%------------- BEGIN CODE --------------
    properties
        inputs
        % number of algebraic constraints
        constraints = 1;
    end
    
    methods
        % Kirchhoff’s law.
        function f = con_eq(obj,x,y,~)
            f(1,1) = x(1) + x(2) - y(1);
        end
    end
end

%------------- END OF CODE --------------