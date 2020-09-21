function f = RL_Con(x,y,~)
% RL_Con - constraint function for a 3-bus power system
%
% Syntax:  
%    f = RL_Con(x,y,u)
%
% Inputs:
%    x - state vector
%    y - vector of algebraic variables
%    u - input vector
%
% Outputs:
%    f - vector storing the constraint viaolation

% Author:       Ivan Fedotov
% Written:      13-Sep-2020
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

% Kirchhoff’s law.
f(1,1) = x(1) + x(2) - y(1);

%------------- END OF CODE --------------