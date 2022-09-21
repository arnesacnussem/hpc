function [code] = Hamming_Encoding(msg,G)
    code_1 = rem(msg*G,2); 
    code = rem(code_1'*G,2);
end