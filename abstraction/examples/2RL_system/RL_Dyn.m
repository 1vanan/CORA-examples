classdef RL_Dyn
% RL_Dyn - class for differential function for RL-power system
%
% Syntax:  
%    f = RL_Dyn(inputs)
%
% Inputs:
%    inputs - array of inputs for differential function
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
    end
    
    methods
        function obj = update_inputs (obj, inputs)
            obj.inputs = inputs;
        end
        
        function f = dyn_eq(obj, ~,y,u)
            %inductivity
            L = 5;

            %resistance
            R = 1;
            
            f(1,1) = 1/L * (obj.inputs(1) - y(1) * R) + u(1);
            f(2,1) = 1/L * (obj.inputs(2) - y(1) * R) + u(2);
        end
    end
end

%------------- END OF CODE --------------