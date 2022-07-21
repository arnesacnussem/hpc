function [] = main_3(check_bit)
    pkg load communications;
    [H,G,n,k]=hammgen(check_bit);
    [row, col] = size(G);
    c = check_bit + 1;
    EbN0db = 10;
    table = create_table(H);
    rate = k / n;
    ferrlim = 10000; #f-err-lim
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
            printf("nframe=%d\n",nframe);
            nframe = nframe + 1;

            % 原始消息=随机生成
            [msg_org] = Binary_generate(k * k);
            msg = reshape(msg_org, [k, k]);
            code = Hamming_Encoding(msg, G);
            I = 2 * code -1;
            rec = I + sigma * randn(n, n);
            rec = (sign(rec) + 1) / 2;
            est_code = Bao(H, rec, table);

            if isequal(est_code, code) == 0
                count = count + 1;
                rec ~= code;
                est_code ~= code;
            end

        end
    end

end