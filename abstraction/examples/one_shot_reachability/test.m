c = [4.5;4.5];
generators = [0.5,0;0,0.5];

u = absUtils;

z = zonotope(c, generators);

state_gr_opt = grid_options([0 0], [10 10], [1 1]);
  
grid = uniformGrid(state_gr_opt);
  
% k = u.compress(z, grid.err(1)*0.01);
% 
% disp(k.Z);

 res = u.getCells(z, grid);
   
 disp(size(res));