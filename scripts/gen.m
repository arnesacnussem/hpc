function gen(check_bit)

    pkg load communications;
    % 生成HGNK
    g = hammgen(check_bit);
    [row, col] = size(g);
    g = [g, zeros(row, 1); ones(1, col + 1)];
    g = rem(abs(rref(g)), 2);
    c = check_bit + 1;
    k = 2^check_bit - 1 - check_bit;
    n = 2^check_bit;
    h = gen2par(g);

    
    [~, col] = size(h);
    table = zeros(col, 1);

    for i = 1:col
        table(i) = bi2de(h(:, i)', "left-msb");
    end

    % tag formate: !# type tag #! value
    printf("!# mat ht #! %s\n", mat2str(h'));
    printf("!# mat g #! %s\n", mat2str(g));
    printf("!# val n #! %d\n", n);
    printf("!# val k #! %d\n", k);
    printf("!# mat table #! %s\n", mat2str(table));
    printf("!# mat syndt #! %s\n", mat2str(syndtable(h)));

end
