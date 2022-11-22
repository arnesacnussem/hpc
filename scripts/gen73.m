function [H, G, n, k, table, syndt] = gen73(check_bit)
    pkg load communications;

    % 生成HGNK
    [H,G,n,k] = hammgen(check_bit);
    table = create_table(H);
    syndt = syndtable(H);
end


function [library] = create_table(H)
    [~, col] = size(H);
    library = zeros(col, 2);

    for i = 1:col
        library(i, 1) = bi2de(H(:, i)', 'left-msb');
    end

end