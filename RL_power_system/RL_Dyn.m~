function f = RL_Dyn(~,y,u)
% bus2Dyn - dynamic function for a 3-bus power system
%
% Syntax:  
%    f = RL_Dyn(x,y,u)
%
% Inputs:
%    x - state vector
%    y - vector of algebraic variables
%    u - input vector
%
% Outputs:
%    f - vector storing the time-derivatives of the states

% Author:       Ivan Fedotov
% Written:      13-Sep-2020
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

%inductivity
L = 5;

%resistance
R = 1;

%voltage. It's an actual input, we fix it.
v_1 = 200;
v_2 = 200;


%dynamic model
f(1,1) = 1/L * (v_1 - y(1) * R) + u(1);
f(2,1) = 1/L * (v_2 - y(1) * R) + u(2);

%------------- END OF CODE --------------