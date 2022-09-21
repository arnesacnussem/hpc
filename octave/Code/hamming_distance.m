function [distance] = hamming_distance() 
number_One = zeros(1,7); 
 msg = [0 0 1; 0 1 0;0 1 1;1 0 0;1 0 1;1 1 0; 1 1 1];
 G = [1 1 0 1 1 0 0 1 1 0 1 0 0;1 0 1 1 0 1 0 1 0 1 0 1 0;1 1 1 0 0 0 1 1 1 1 0 0 1];
 code = rem(msg*G,2);
 for i = 1:7
     number_One(1,i) = length(find(code(i,:)) == 1); 
 end
distance = min(number_One);
disp(distance);
end
 