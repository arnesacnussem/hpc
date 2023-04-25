function [output, req] = EHPC_decoding(H, rec, table, code)
    [r, c] = size(rec);
    org = rec;
    req = 0;
    row_uncorrect = zeros(1, r); %marked each row that has two errors
    col_uncorrect = zeros(1, c); %marked each column that has two errors
    row1_vector = zeros(1, r); %marked each row that has errors
    col1_vector = zeros(1, c); %marked each column that has errors
    col_error_site = zeros(1, c); % record the location of the column that has estimated.
    flag = 0;
    % check the error
    % CHK_R1
    for i = 1:r
        rrec = rec(i, :);
        [rError_exist, rCorrectable, ~] = Hdecode(rrec, H, table);

        if rError_exist == 1
            row_uncorrect(i) = 1 - rCorrectable;
            row1_vector(i) = 1;
        end

    end

    % CHK_C1
    for j = 1:c
        crec = rec(:, j)';
        [cError_exist, cCorrectable, ~] = Hdecode(crec, H, table);

        if cError_exist == 1
            col_uncorrect(j) = 1 - cCorrectable;
            col1_vector(j) = 1;
        end

    end

    %Compare_vector = [row1_vector;row_uncorrect;col_uncorrect;col1_vector];
    if sum(col1_vector + col_uncorrect) > sum(row1_vector + row_uncorrect) || length(find(col1_vector ~= 0)) > length(find(row1_vector ~= 0))
        % CHK_SET_FLAG
        rec = rec';
        flag = 1;
    end


    if flag == 1
        % 进行擦除 sum_vec_1 == sum_vec_2
        % CHK_CRFLAG
        if sum(col1_vector + col_uncorrect) == sum(row1_vector + row_uncorrect) && length(find(col1_vector ~= 0)) == length(find(row1_vector ~= 0))

            %擦除区域内的错误个数大于一半以上
            if (length(find(col1_vector ~= 0)) < sqrt(sum(col1_vector + col_uncorrect)) * sqrt(2))
                s1 = length(find(col1_vector ~= 0));
                s2 = length(find(row1_vector ~= 0));
                rr = find(row1_vector ~= 0);
                cc = find(col1_vector ~= 0);

                % CHK_CRLOOP
                for i = 1:s2

                    for j = 1:s1
                        rec(rr(i), cc(j)) = 1 - rec(rr(i), cc(j));
                    end

                end

            end

        end

    end

    row_vector = zeros(1, c);
    row_uncorrect = 0 * row_uncorrect;
    col_vector = zeros(1, r);
    col_uncorrect = 0 * col_uncorrect;
    % First step decoding: row decoding and generate row_vector
    for i = 1:r
        rrec = rec(i, :);
        [rError_exist, rCorrectable, rError_site] = Hdecode(rrec, H, table);

        if rError_exist == 1
            row_vector(i) = 1;

            if rCorrectable == 1
                rec(i, rError_site) = 1 - rec(i, rError_site);
            else
                row_uncorrect(i) = 1;
            end

        end

    end

    % Second step decoding: col decoding and generate col_vector
    for j = 1:c
        crec = rec(:, j)';
        [cError_exist, cCorrectable, cError_site] = Hdecode(crec, H, table);

        if cError_exist == 1
            col_vector(j) = 1;

            if cCorrectable == 1
                col_error_site(j) = cError_site;

                if row_vector(cError_site) == 0
                    col_uncorrect(j) = 1;
                end

            else
                col_uncorrect(j) = 1;
            end

        end

    end

    if sum(row_uncorrect) * 2 == 3 * sum(col_vector)
        % CHK_CR2_LOOP_1
        s1 = length(find(row_uncorrect ~= 0));
        s2 = length(find(col_vector ~= 0));
        rr = find(row_uncorrect ~= 0);
        cc = find(col_vector ~= 0);

        for i = 1:s1

            for j = 1:s2
                rec(rr(i), cc(j)) = 1 - rec(rr(i), cc(j));
            end

        end

    else % CHK_CR2_LOOP_2
        
        for i = 1:c

            if col_error_site(i) ~= 0
                rec(col_error_site(i), i) = 1 - rec(col_error_site(i), i);
            end

        end

        % CHK_CR2_LOOP_2S
        % Third step decoding: row decoding and generate col_vector
        for i = 1:r
            rrec = rec(i, :);
            [rError_exist, rCorrectable, rError_site] = Hdecode(rrec, H, table);

            if rError_exist == 1

                if rCorrectable == 1
                    rec(i, rError_site) = 1 - rec(i, rError_site);
                else

                    for j = 1:c

                        if col_uncorrect(j) == 1
                            rec(i, j) = 1 - rec(i, j);
                        end

                    end

                end

            end

        end

    end

    % CHK_R3
    for i = 1:r
        rrec = rec(i, :);
        [rError_exist, rCorrectable, rError_site] = Hdecode(rrec, H, table);

        if rError_exist == 1

            if rCorrectable == 1
                rec(i, rError_site) = 1 - rec(i, rError_site);
            else
                req = 1;
            end

        end

    end

    % CHK_REQ
    if req == 0

        for i = 1:r
            [cError_exist, ~, ~] = Hdecode(rec(:, i)', H, table);

            if cError_exist == 1
                req = 1;
                break;
            end

        end

    end

    % CHK_FLAG
    if flag == 1
        rec = rec';
    end

    output = rec;
end
