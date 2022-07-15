function [output] = Bao(H, rec, table)
    [r, c] = size(rec);
    row_vector = zeros(1, c);
    col_vector = zeros(1, r);
    % First step decoding: row decoding and generate row_vector
    for i = 1:r
        rrec = rec(i, :);
        [rError_exist, rCorrectable, rError_site] = Hdecode(rrec, H, table);

        if rError_exist == 1
            row_vector(i) = 1;

            if rCorrectable == 1
                rec(i, rError_site) = 1 - rec(i, rError_site);
            end

        end

    end

    % Second step decoding: col decoding and generate col_vector
    for j = 1:c
        crec = rec(:, j)';
        [cError_exist, cCorrectable, cError_site] = Hdecode(crec, H, table);

        if cError_exist == 1

            if cCorrectable == 1
                rec(cError_site, j) = 1 - rec(cError_site, j);

                if row_vector(cError_site) == 0
                    col_vector(j) = 1;
                end

            else
                col_vector(j) = 1;
            end

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

                    if col_vector(j) == 1
                        rec(i, j) = 1 - rec(i, j);
                    end

                end

            end

        end

    end

    output = rec;
end
