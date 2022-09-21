function [rec] = Proposed_method(H,rec)
     T = syndtable(H);
     [r,c] = size(rec); 
     vote_table = zeros(r,c);
     for i = 1:r
         S = rem(rec(i,:)*H',2);
         index = Bin2int(S);  
         if index ~= 0
             id = find(T(index+1,:)==1);
             vote_table(i,:) = vote_table(i,:)+1;
             vote_table(i,id) =  vote_table(i,id)+0.5;
         else
             vote_table(i,:) = vote_table(i,:)-1;
         end
     end
     for i = 1:c
          S = rem(rec(:,i)'*H',2);
          index = Bin2int(S);
          if index ~= 0
              id = find(T(index+1,:)==1);
              vote_table(:,i) = vote_table(:,i)+1;
              vote_table(id,i) =  vote_table(id,i)+0.5;
          else
              vote_table(:,i) = vote_table(:,i)-1;
          end
     end
     M = max(max(vote_table));
     change = zeros(r,c);
     if M == 3
         change = vote_table == 3;
     else
         if M > 0
             change = vote_table == 2;
         end
     end
      rec = rem(rec+change,2);
      [rec] = Two_step_decoding(H,rec);
 end

function [Output] = Bin2int(mat)
    Output = 0;
    for i = 1:length(mat)
        Output = Output*2+mat(i);
    end
end
