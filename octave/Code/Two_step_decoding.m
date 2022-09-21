function [rec] = Two_step_decoding(H,rec)
     T = syndtable(H);
     [r,c] = size(rec);
     % row decoding
     for i = 1:r
         S = rem(rec(i,:)*H',2);
         index = Bin2int(S);
         rec(i,:) = rem(rec(i,:)+T(index+1,:),2);
     end
     % col decoding
     for i = 1:c
         S = rem(rec(:,i)'*H',2);
         index = Bin2int(S);
         rec(:,i) = rem(rec(:,i)'+ T(index+1,:),2)';
     end
end
function [Output] = Bin2int(mat)
    Output = 0;
    for i = 1:length(mat)
        Output = Output*2+mat(i);
    end
end