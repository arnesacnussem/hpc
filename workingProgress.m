function [output, req] = EHPC_decoding(H, rec, table, code)
    %Compare_vector = [row_vector;row_uncorrect;col_uncorrect;col_vector];
    if sum(col_vector + col_uncorrect) > sum(row_vector + row_uncorrect) || length(find(col_vector ~= 0)) > length(find(row_vector ~= 0))
        % CHK_SET_FLAG
        rec = rec';
        flag = 1;
    end


    if flag ~= 1
        % 进行擦除 sum_vec_1 == sum_vec_2
        % CHK_CRFLAG
        if sum(col_vector + col_uncorrect) == sum(row_vector + row_uncorrect) && length(find(col_vector ~= 0)) == length(find(row_vector ~= 0))

            %擦除区域内的错误个数大于一半以上
            if (length(find(col_vector ~= 0)) < sqrt(sum(col_vector + col_uncorrect)) * sqrt(2))
                % s1 = length(find(col_vector ~= 0)); %col里不为0的数量
                % s2 = length(find(row_vector ~= 0)); %row里不为0的数量
                % rr = find(row_vector ~= 0); % row_vec里不为0的下标
                % cc = find(col_vector ~= 0); % col_vec里不为0的下标

                % % CHK_CRLOOP
                % for i = 1:s2
                %     for j = 1:s1
                %         rec(rr(i), cc(j)) = 1 - rec(rr(i), cc(j));
                %     end
                % end
            end

        end

    end


    if sum(row_uncorrect) * 2 == 3 * sum(col_vector)
        % s1 = length(find(row_uncorrect ~= 0));
        % s2 = length(find(col_vector ~= 0));
        % rr = find(row_uncorrect ~= 0);
        % cc = find(col_vector ~= 0);

        % for i = 1:s1

        %     for j = 1:s2
        %         rec(rr(i), cc(j)) = 1 - rec(rr(i), cc(j));
        %     end

        % end

    else
        
        for i = 1:c

            if col_error_site(i) ~= 0
                rec(col_error_site(i), i) = 1 - rec(col_error_site(i), i);
            end

        end

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
