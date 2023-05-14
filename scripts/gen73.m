function [H, G, n, k, table] = gen73(check_bit)
    pkg load communications;

    % 生成HGNK
    [H, G, n, k] = hammgen(check_bit);
    H = H';
end
