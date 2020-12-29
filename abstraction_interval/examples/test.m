   c = [4.5;4.5];
   generators = [5, 0;0, 5];
   
   u = absUtils;
   
   z = zonotope([1.5 0.5 0 0; 1.5 0 0.5 0; 1.5 0 0 0.5]);
     
   % k = u.compress(z, grid.err(1)*0.01);
   % 
   % disp(k.Z);
   
    res = u.getCells(z, [1 1 1]);
      
    disp(res);

% left = zeros(2, 1);
% right = zeros(2, 1);
% left(1) = -10;
% left(2) = -10;
% right(1) = 20;
% right(2) = 20;
%  
% I1 = interval(left, right);
% 
% I2 = interval([15; 15], [17; 17]);
% 
% Z = zonotope([-5 1 0;-50 0 1]);
% 
% disp(isIntersecting(I1, Z));

% Z = zonotope([-5 1 0 1 1 1; -50 0 1 1 1 1]);
% b = box(Z);
% s = size(b.Z(:,1));
% dim = s(1);
% left_bound = zeros(dim, 1);
% right_bound = zeros(dim, 1);
% for d = 1 : dim
%     left_bound(d) = b.Z(d,1) - b.Z(d,d+1);
%     right_bound(d) = b.Z(d,1) + b.Z(d,d+1);
%     disp(left_bound(d));
%     disp(right_bound(d));
% end