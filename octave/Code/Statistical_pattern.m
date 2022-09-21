function [type]=Statistical_pattern(org_pattern)
type = zeros(1,3);
[~,number]= size(org_pattern);
for i = 1:number
    mat = cell2mat(org_pattern(i));
    row_stat = 0;
    col_stat = 0;
    [r,~] = size(mat);
    for ii = 1:r
        if sum(mat(ii,:)) > 0
            row_stat = row_stat+1;
        end
        if sum(mat(:,ii)) >0
            col_stat = col_stat+1;
        end
    end
    if row_stat == 2 && col_stat == 2
        type(1) = type(1) +1;
    elseif row_stat == 2 && col_stat == 3
        type(2) = type(2) +1;
    elseif row_stat == 2 && col_stat == 4
        type(3) = type(3) +1;
    end
end
end