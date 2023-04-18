function [rec] = SHPC_decoding(H, rec)
    T = syndtable(H);
    [r, c] = size(rec);
    row_error = [];
    col_error = [];
    T = syndtable(H);

    for i = 1:r
        S = rem(rec(i, :) * H', 2);
        index = Bin2int(S);

        if (index ~= 0)
            row_error = [row_error, i];
        end

    end

    for i = 1:c
        S = rem(rec(:, i)' * H', 2);
        index = Bin2int(S);

        if (index ~= 0)
            col_error = [col_error, i];
        end

    end

    if length(row_error) == length(col_error)

        if length(row_error) <= 2

            for i = 1:length(row_error)

                for j = 1:length(col_error)
                    rec(row_error(i), col_error(j)) = rem(rec(row_error(i), col_error(j)) + 1, 2);
                end

            end

            [rec] = row_correct(rec, H, T);
        else
            [rec] = row_correct(rec, H, T);
            [rec] = col_correct(rec, H, T);
            [rec] = row_correct(rec, H, T);
        end

    else

        if length(row_error) > length(col_error)
            [rec] = row_correct(rec, H, T);
            [rec] = col_correct(rec, H, T);
            [rec] = row_correct(rec, H, T);
        else
            [rec] = col_correct(rec, H, T);
            [rec] = row_correct(rec, H, T);
            [rec] = col_correct(rec, H, T);
        end

    end

end

function [rec] = row_correct(rec, H, T)
    [r, ~] = size(rec);

    for i = 1:r
        S = rem(rec(i, :) * H', 2);
        index = Bin2int(S);
        rec(i, :) = rem(rec(i, :) + T(index + 1, :), 2);
    end

end

function [rec] = col_correct(rec, H, T)
    [~, c] = size(rec);

    for i = 1:c
        S = rem(rec(:, i)' * H', 2);
        index = Bin2int(S);
        rec(:, i) = rem(rec(:, i)' + T(index + 1, :), 2)';
    end

end

function [Output] = Bin2int(mat)
    Output = 0;

    for i = 1:length(mat)
        Output = Output * 2 + mat(i);
    end

end
