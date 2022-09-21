function [output,req] = Bao_v2(H,rec,table,code)
    [r,c] = size(rec);
    req = 0;
    row_uncorrect = 0;
    col_uncorrect = 0;
    row1_vector = zeros(1,r);
    col1_vector = zeros(1,c);
    flag = 0;
    % check the error
    for i = 1:r
        rrec = rec(i,:);
        [rError_exist,rCorrectable,~] = Hdecode(rrec,H,table);
        row_uncorrect = row_uncorrect + rCorrectable;
        if rError_exist == 1 
            row1_vector(i) = 1;
            if rCorrectable == 0
                row1_vector(i) =row1_vector(i)+1 ;
            end
        end
    end
    for j = 1:c
        crec = rec(:,j)';
        [cError_exist,cCorrectable,~] = Hdecode(crec,H,table);
        col_uncorrect = col_uncorrect+cCorrectable;
        if cError_exist == 1 
            col1_vector(j) = 1;
            if cCorrectable == 0
                 col1_vector(j) = col1_vector(j)+1;
            end
        end
    end
     if sum(col1_vector) > sum(row1_vector) || length(find(col1_vector~=0)) >length(find(row1_vector~=0))
        rec = rec';
        flag = 1;
     else 
         if sum(col1_vector) == sum(row1_vector)&& length(find(col1_vector~=0)) == length(find(row1_vector~=0))  
             if(length(find(col1_vector~=0)) < sqrt(sum(col1_vector))*sqrt(2))
                 s1 = length(find(col1_vector~=0));
                 s2 = length(find(row1_vector~=0));
                 rr = find(row1_vector~=0);
                 cc = find(col1_vector~=0);
                 for i= 1:s2
                     for j = 1:s1
                         rec(rr(i),cc(j)) = 1 - rec(rr(i),cc(j));
                     end
                 end
             end
         end
     end
    row_vector = zeros(1,c);
    col_vector = zeros(1,r);
    % First step decoding: row decoding and generate row_vector
    for i = 1:r
        rrec = rec(i,:);
        [rError_exist,rCorrectable,rError_site] = Hdecode(rrec,H,table);
        if rError_exist == 1 
            row_vector(i) = 1;
            if rCorrectable == 1
                rec(i,rError_site) = 1- rec(i,rError_site);
            end 
        end
    end
    % Second step decoding: col decoding and generate col_vector
    for j = 1:c
        crec = rec(:,j)';
        [cError_exist,cCorrectable,cError_site] = Hdecode(crec,H,table);
        if cError_exist == 1 
            if cCorrectable == 1
                    rec(cError_site,j) = 1 -  rec(cError_site,j);
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
        rrec = rec(i,:);
        [rError_exist,rCorrectable,rError_site] = Hdecode(rrec,H,table);
        if rError_exist == 1 
            if rCorrectable == 1
                rec(i,rError_site) = 1- rec(i,rError_site);
            else
                for j = 1:c
                    if col_vector(j) == 1
                        rec(i,j) = 1 - rec(i,j);
                    end
                end
            end 
        end
    end

    for i = 1:r
        rrec = rec(i,:);
        [rError_exist,rCorrectable,rError_site] = Hdecode(rrec,H,table);
        if rError_exist == 1 
            if rCorrectable == 1
                rec(i,rError_site) = 1- rec(i,rError_site);
            else
                req = 1;
            end 
        end
    end
    if flag == 1
        rec = rec';
    end
    output = rec;
end