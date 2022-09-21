function [rec,req] = Double_step(H,rec,table,code)
 [r,c] = size(rec);
 req = 0;
 for i = 1:r
     rrec = rec(i,:);
     [rError_exist,rCorrectable,rError_site] = Hdecode(rrec,H,table);
       if rError_exist == 1 && rCorrectable == 1
           rec(i,rError_site) = 1- rec(i,rError_site);
       elseif rCorrectable == 0
           req = 1;
       end
 end
     for j = 1:c
          crec = rec(:,j)';
          [cError_exist,cCorrectable,cError_site] = Hdecode(crec,H,table);
           if cError_exist == 1 && cCorrectable == 1
               rec(cError_site,j) = 1-rec(cError_site,j); 
           end
     end
end