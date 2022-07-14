function [library] = create_table(H)
    [~, col] = size(H);
    library = zeros(col, 2);

    for i = 1:col
        library(i, 1) = bi2de(H(:, i)', 'left-msb');
    end

end
