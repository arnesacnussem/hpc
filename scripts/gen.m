function gen(check_bits)

    pkg load communications;
    [h, g, n, k] = hammgen(check_bits);
    [~, col] = size(h);
    table = zeros(col, 1);

    for i = 1:col
        table(i) = bi2de(h(:, i)', "left-msb");
    end

    % tag formate: !# type tag #! value
    printf("!# mat h #! %s\n", mat2str(h'));
    printf("!# mat g #! %s\n", mat2str(g));
    printf("!# val n #! %d\n", n);
    printf("!# val k #! %d\n", k);
    printf("!# mat table #! %s\n", mat2str(table))

end
