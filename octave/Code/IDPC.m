function [rec] = IDPC(H,rec,table,code)
     [r,c] = size(rec);
     [rec,col_vector,row_vector,error_still_exist]=iterative_decodeing(rec,H,table,r,c);
     if(error_still_exist == 1)
         s1 = length(find(col_vector~=0));
         s2 = length(find(row_vector~=0));
         rr = find(row_vector~=0);
         cc = find(col_vector~=0);
         for i= 1:s2
             for j = 1:s1
                 rec(rr(i),cc(j)) = 1 - rec(rr(i),cc(j));
             end
         end
         [rec,~,~,error_still_exist] = iterative_decodeing(rec,H,table,r,c);
         if(error_still_exist == 1)
             req = 1;
         end
     end
end
function[rec,col_vector,row_vector,error_still_exist]=iterative_decodeing(rec,H,table,r,c)
    row_vector = zeros(1,r);
    col_vector = zeros(1,c);
    flag_2 = 1;
    error_still_exist = 0;
    while flag_2 == 1
         compare = rec;
         for j = 1:c
              crec = rec(:,j)';
              [cError_exist,cCorrectable,cError_site] = Hdecode(crec,H,table);
               if cError_exist == 1 && cCorrectable == 1
                   rec(cError_site,j) = 1-rec(cError_site,j);
                   col_vector(1,j) = 1;
               elseif cError_exist == 1 && cCorrectable == 0
                   col_vector(1,j) = 1;
                   flag = 1;
               end
         end
         for i = 1:r
             rrec = rec(i,:);
             [rError_exist,rCorrectable,rError_site] = Hdecode(rrec,H,table);
             if rError_exist == 1 && rCorrectable == 1
                   rec(i,rError_site) = 1- rec(i,rError_site);
                   row_vector(1,i)= 1;
             elseif rError_exist == 1 && rCorrectable == 0
                   row_vector(1,i) = 1; 
             end
         end
         flag_2 = ~isequal(compare,rec); 
    end
    for j = 1:c
         crec = rec(:,j)';
         rrec = rec(i,:);
         [rError_exist,~,~] = Hdecode(rrec,H,table);
         [cError_exist,~,~] = Hdecode(crec,H,table);
         if(rError_exist== 1|| cError_exist == 1)
             error_still_exist = 1;
         end
    end
end