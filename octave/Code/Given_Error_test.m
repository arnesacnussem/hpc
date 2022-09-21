function [error_number,error_bit,error_set_1,error_set_2] = Given_Error_test(Ne,test_times,n,num_algorithm,G,H)
K = 4;
error_number = zeros(1,num_algorithm);
error_bit = zeros(1,num_algorithm);
estimate = zeros(n,n,num_algorithm);
error_set_1 ={};
error_set_2 = {};
if test_times == -1
  Array = nchoosek(linspace(1,n*n,n*n),Ne);
  [test_times,~] = size(Array);
else
    Array=zeros(test_times,Ne);
    for i = 1:test_times
        Array(i,:) = randperm(n*n,Ne);
    end
end
%[row,~] = size(Array);
tic;
for i = 1:test_times
    if mod(i,50000) == 0
        t = toc;
        fprintf("Repeated %d times/%d, consumed %.2f s\n",i,test_times,t);
        tic;
        disp(error_number);
    end
    [msg_org] = Binary_generate(K*K);
    msg = reshape(msg_org,[K,K]);
    code = Hamming_Encoding(msg,G);
    code_sent = reshape(code,[1,n*n]);
    %current =randperm(numel(1:row),1);
    for j = 1:Ne
        code_sent(Array(i,j)) = 1 - code_sent(Array(i,j));
    end
    code_sent = reshape(code_sent,[n,n]);
    if num_algorithm == 4
        table = create_table(H);
        [estimate(:,:,1),~] = Double_step(H,code_sent,table,code);
        [estimate(:,:,2)]= IDPC(H,code_sent,table,code);
        estimate(:,:,3) =  Bao(H,code_sent,table);
        [estimate(:,:,4),~] = Bao_v3(H,code_sent,table,code); %proposed method
    elseif num_algorithm == 3
        table = create_table(H);
        estimate(:,:,1) = Double_step(H,code_sent,table,code);
        estimate(:,:,2)= Iterative_decoding_Bao(H,code_sent);
        estimate(:,:,3) = Proposed_method2(H,code_sent);
    end
    for j = 1:num_algorithm
        if isequal(estimate(:,:,j),code) == 0
            error_number(j) =  error_number(j)+1;
            error_bit(j) = error_bit(j)+sum(sum(estimate(:,:,j)~=code));
        end
    end
end
toc;
end