function [frame,error_bit] = BSC_channel()
disp("Conduct BSC_channel Experiments");
percent = 0.01:0.01:0.15;
G = hammgen(3);
ferrlim = 500000;
[row,col] = size(G);
G = [G,zeros(row,1);ones(1,col+1)];
G = rem(abs(rref(G)),2);
H = gen2par(G);
table = create_table(H);
K = 4;
N = 8;
frame = zeros(length(percent),4);
error_bit =  zeros(length(percent),4);
tic;
error_distribute = zeros(4,64);
 for Per = 1:length(percent)
      nframe = 0;
      fprintf('Conduct Experiment on %0.2f percent noise\n',percent(Per));
      for nframe = 1:ferrlim
          if mod(nframe,50000) == 0
              t = toc;
              fprintf('Now have processed %d percent\n',(nframe/ferrlim)*100);
              fprintf('Conduct %.2f seconds\n',t);
              disp(frame(Per,:));
              disp(error_bit(Per,:));
              disp(error_distribute);
              tic;
          end
          [msg_org] = Binary_generate(K*K);
          msg = reshape(msg_org,[K,K]);
          code = Hamming_Encoding(msg,G);
          rec = rem(code+(rand(N,N) <= percent(Per)),2);
          est_code_1 = Double_step(H,rec,table,code);
          est_code_2 = IDPC(H,rec,table,code);
          est_code_3 = Bao(H,rec,table);
          est_code_4 = Bao_v3(H,rec,table,code); 
          err_1 = length(find(est_code_1 ~= code));
          err_2 = length(find(est_code_2 ~= code));
          err_3 = length(find(est_code_3 ~= code));
          err_4 = length(find(est_code_4 ~= code));
           if err_1 
                frame(Per,1) = frame(Per,1)+1;
                error_bit(Per,1) =  error_bit(Per,1)+err_1;
                ee = length(find(rec~=code));
                error_distribute(1,ee) =  error_distribute(1,ee)+1;
            end 
            if err_2
                frame(Per,2) = frame(Per,2)+1;
                error_bit(Per,2) =  error_bit(Per,2)+err_2;
                ee = length(find(rec~=code));
                error_distribute(2,ee) =  error_distribute(2,ee)+1;
            end
            if err_3
                frame(Per,3) = frame(Per,3)+1;
                error_bit(Per,3) =  error_bit(Per,3)+err_3;
                ee = length(find(rec~=code));
                error_distribute(3,ee) =  error_distribute(3,ee)+1;
            end
            if err_4
                frame(Per,4) = frame(Per,4)+1;
                error_bit(Per,4) =  error_bit(Per,4)+err_4;
                ee = length(find(rec~=code));
                error_distribute(4,ee) =  error_distribute(4,ee)+1;
            end
      end
       frame(Per,:) = frame(Per,:)/ferrlim;
       error_bit(Per,:) = error_bit(Per,:)/(ferrlim*N*N);
 end
 toc;
     %save('BSC_EH_FE.mat','frame');
     %save('BSC_EH_BE.mat','error_bit'); 
 end
