function [rec] = Proposed_method2(rec, H, table, syndt)
    [r, c] = size(rec);
    row_error = [];
    col_error = [];

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

% R3_EQUAL
        if length(row_error) <= 2
    % R3_EQ_1
            for i = 1:length(row_error)

                for j = 1:length(col_error)
                    % 这是个 bit flip...
                    rec(row_error(i), col_error(j)) = rem(rec(row_error(i), col_error(j)) + 1, 2);
                end

            end

            [rec] = row_correct(rec, H, syndt);
        
        else
    % R3_EQ_2
            [rec] = row_correct(rec, H, syndt);
            [rec] = col_correct(rec, H, syndt);
            [rec] = row_correct(rec, H, syndt);
        end
% R3_EQUAL

    else

% R3_INEQUAL
        if length(row_error) > length(col_error)
            [rec] = row_correct(rec, H, syndt);
            [rec] = col_correct(rec, H, syndt);
            [rec] = row_correct(rec, H, syndt);
        else
            [rec] = col_correct(rec, H, syndt);
            [rec] = row_correct(rec, H, syndt);
            [rec] = col_correct(rec, H, syndt);
        end
% R3_INEQUAL

    end

end

function [rec] = row_correct(rec, H, syndt)
    [r, ~] = size(rec);

    for i = 1:r
        S = rem(rec(i, :) * H', 2);
        S = Bin2int(S);
        rec(i, :) = rem(rec(i, :) + syndt(S + 1, :), 2);
    end

end

function [rec] = col_correct(rec, H, syndt)
    [~, c] = size(rec);

    for i = 1:c
        S = rem(rec(:, i)' * H', 2);
        S = Bin2int(S);
        rec(:, i) = rem(rec(:, i)' + syndt(S + 1, :), 2)';
    end

end

function [Output] = Bin2int(mat)
    Output = 0;

    for i = 1:length(mat)
        Output = Output * 2 + mat(i);
    end

end
