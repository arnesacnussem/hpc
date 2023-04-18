function [H, G, n, k, table, syndt] = gen84(check_bit)
    pkg load communications;

    % 生成HGNK
    G = hammgen(check_bit);
    [row, col] = size(G);
    G = [G, zeros(row, 1); ones(1, col + 1)];
    G = rem(abs(rref(G)), 2);
    c = check_bit + 1;
    k = 2^check_bit - 1 - check_bit;
    n = 2^check_bit;
    H = gen2par(G);

    table = create_table(H);
    syndt = syndtable(H);
    H = H';
end

function [library] = create_table(H)
    [~, col] = size(H);
    library = zeros(col, 2);

    for i = 1:col
        library(i, 1) = bi2de(H(:, i)', 'left-msb');
    end

end