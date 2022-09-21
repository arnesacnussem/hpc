function [] = main_2()
percent = 0.01:0.01:0.1;
Output_f = zeros(length(percent),3,3);
Output_b = zeros(length(percent),3,3);
for check_bit = 3:4
    [H,G,N,K] = hammgen(check_bit);
    fprintf('[%d,%d,3]\n',N,K);
    ferrlim = 5000000;
    frame = zeros(length(percent),3);
    error_bit =  zeros(length(percent),3);
    tic;
    for Per = 1:length(percent)
        nframe = 0;
        fprintf('Conduct Experiment on %0.2f percent noise\n',percent(Per));
        while nframe <= ferrlim
            if mod(nframe,50000) == 0
                t = toc;
                fprintf('Now have processed %d percent\n',(nframe/ferrlim)*100);
                fprintf('Conduct %.2f seconds\n',t);
                tic;
            end
            nframe = nframe+1;
            [msg_org] = Binary_generate(K*K);
            msg = reshape(msg_org,[K,K]);
            code = Hamming_Encoding(msg,G);
            rec = rem(code+(rand(N,N) <= percent(Per)),2);
            est_code = Proposed_method2(H,rec);
            est_code_three_step = Iterative_decoding_Bao(H,rec);   
            est_code_two_step = Two_step_decoding(H,rec);
            err_1 = length(find(est_code ~= code));
            err_2 = length(find(est_code_three_step ~= code));
            err_3 = length(find(est_code_two_step ~= code));
            if err_2 
                frame(Per,2) = frame(Per,2)+1;
                error_bit(Per,2) =  error_bit(Per,2)+err_2;
            end 
            if err_3
                frame(Per,3) = frame(Per,3)+1;
                error_bit(Per,3) =  error_bit(Per,3)+err_3;
            end
            if err_1
                frame(Per,1) = frame(Per,1)+1;
                error_bit(Per,1) =  error_bit(Per,1)+err_1;
            end
        end
           frame(Per,:) = frame(Per,:)/ferrlim;
           error_bit(Per,:) = error_bit(Per,:)/(ferrlim*N*N);
    end
    Output_f(:,:,check_bit-2) = frame;
    Output_b(:,:,check_bit-2) = error_bit;
    snr = 0.01:0.01:0.1;
    semilogy(snr,frame(:,1),'ob-');
    hold on;
    semilogy(snr,frame(:,2),'or-');
    semilogy(snr,frame(:,3),'oy-');
    xlabel("Symbol error probability");
    ylabel("Frame Error Rate");
    title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
    grid on;
    hold off;
    legend('proposed method','three-step','two-step');
    saveas(gcf,strcat("WER2_",num2str(N),'_',num2str(K),'.png'));
    semilogy(snr,error_bit(:,1),'ob-');
    hold on;
    semilogy(snr,error_bit(:,2),'or-');
    semilogy(snr,error_bit(:,3),'oy-');
    xlabel("Symbol error probability");
    ylabel("Bit Error Rate");
    title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
    grid on;
    hold off;
    legend('proposed method','three-step','two-step');
    saveas(gcf,strcat("BER2_",num2str(N),'_',num2str(K),'.png'));
end
save('Output_f2.mat','Output_f');
save('Output_b2.mat','Output_b');
end