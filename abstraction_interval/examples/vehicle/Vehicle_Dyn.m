function f = Vehicle_Dyn(t,x, u)
f(1,1) = 1 * cos(atan(tan(1)/2) + x(3)) * cos(atan(tan(1))^(-1)) + u(1);
f(2,1) =  1 * sin(atan(tan(1)/2) + x(3)) * cos(atan(tan(1))^(-1)) + u(2);
f(3,1) =  1 * tan(1) + u(3);
end


%------------- END OF CODE --------------
