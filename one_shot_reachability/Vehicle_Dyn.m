classdef Vehicle_Dyn
% Vehicle_Dyn - class for differential function for vehicle examples from
% scots.
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
% Written:      11-Nov-2020
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------
    
    properties
        inputs
    end
    
    methods
        function obj = update_inputs (obj, inputs)
            obj.inputs = inputs;
        end
        
        function f = dyn_eq(obj, x, u)
            f(1,1) = obj.inputs(1) * cos(atan(tan(obj.inputs(2))/2) + x(3)) * cos(atan(tan(obj.inputs(2)))^(-1)) + u(1);
            f(2,1) =  obj.inputs(1) * sin(atan(tan(obj.inputs(2))/2) + x(3)) * cos(atan(tan(obj.inputs(2)))^(-1)) + u(2);
            f(3,1) =  obj.inputs(1) * tan(obj.inputs(2)) + u(3);
        end
    end
end

%------------- END OF CODE --------------

