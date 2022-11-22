function [code, H, table, syndt] = gen84(check_bit)
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

    [msg_org] = Binary_generate(k * k);
    msg = reshape(msg_org, [k, k]);
    code_1 = rem(msg * G, 2);
    % 原始码字
    code = rem(code_1' * G, 2);
    table = create_table(H);
    syndt = syndtable(H);
end

function [Output] = Binary_generate(n)
    Output = zeros(1, n);

    for i = 1:n

        if rand() >= 0.5
            Output(i) = 1;
        end

    end

end

function [library] = create_table(H)
    [~, col] = size(H);
    library = zeros(col, 2);

    for i = 1:col
        library(i, 1) = bi2de(H(:, i)', 'left-msb');
    end

end