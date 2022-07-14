% input : n - the number of bits of the required binary output (integer that >0)
function [Output] = Binary_generate(n)
    Output = zeros(1,n);
    for i = 1:n
        if rand() >= 0.5
            Output(i) = 1;
        end
    end
end
