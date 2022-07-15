function [code] = Hamming_Encoding(msg,g)
    code_1 = rem(msg * g, 2);
    code = rem(code_1' * g, 2);
end
