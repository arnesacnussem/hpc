function [] = main_3(check_bit)
    G = hammgen(check_bit);
    [row, col] = size(G);
    G = [G, zeros(row, 1); ones(1, col + 1)];
    G = rem(abs(rref(G)), 2);
    c = check_bit + 1;
    k = 2^check_bit - 1 - check_bit;
    n = 2^check_bit;
    H = gen2par(G);
    EbN0db = 10;
    table = create_table(H);
    rate = k / n;
    ferrlim = 10000;
    error_set = {};
    Errors = {};
    frame = zeros(EbN0db, 3);

    error_bit = zeros(EbN0db, 3);

    for nEN = 4:EbN0db
        count = 0;
        en = 10^(nEN / 10);
        sigma = 1 / sqrt(2 * rate * en);
        nframe = 0;

        while nframe < ferrlim
            nframe = nframe + 1;
            [msg_org] = Binary_generate(k * k);
            msg = reshape(msg_org, [k, k]);
            code = Hamming_Encoding(msg, G);
            I = 2 * code -1;
            rec = I + sigma * randn(n, n);
            rec = (sign(rec) + 1) / 2;
            est_code = Bao(H, rec, table);

            if isequal(est_code, code) == 0
                count = count + 1;
                rec ~= code
                est_code ~= code
            end

        end

        count/
    end

end
