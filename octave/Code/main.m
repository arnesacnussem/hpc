function [] = main()
for check_bit = 3:3
    H,G,N,K] = hammgen(check_bit);[
    rate = K*K/(N*N);
    EbN0db = 10;
    ferrlim = 100000;
    error_set ={};
    Errors = {};
    frame = zeros(EbN0db,3);
    error_bit =  zeros(EbN0db,3);
    for nEN = 1:EbN0db
        en = 10^(nEN/10);
        sigma = 1/sqrt(2*rate*en);
        nframe = 0;
        inddex = 0;
        while nframe < ferrlim
            nframe = nframe+1;
            [msg_org] = Binary_generate(K*K);
            msg = reshape(msg_org,[K,K]);
            code = Hamming_Encoding(msg,G);
            I = 2*code -1;
            rec = I + sigma*randn(N,N);
            rec =(sign(rec)+1)/2;
            est_code = Proposed_method2(H,rec);
            est_code_three_step = Iterative_decoding_Bao(H,rec);   
            est_code_two_step = Two_step_decoding(H,rec);
            err_1 = length(find(est_code ~= code));
            err_2 = length(find(est_code_three_step ~= code));
            err_3 = length(find(est_code_two_step ~= code));
            if err_2 
                frame(nEN,2) = frame(nEN,2)+1;
                error_bit(nEN,2) =  error_bit(nEN,2)+err_2;
            end 
            if err_3
                frame(nEN,3) = frame(nEN,3)+1;
                error_bit(nEN,3) =  error_bit(nEN,3)+err_3;
            end
            if err_1
                frame(nEN,1) = frame(nEN,1)+1;
                error_bit(nEN,1) =  error_bit(nEN,1)+err_1;
                if length(find(rec ~= code)) <= 4
                    inddex = inddex+1;
                end
            end
        end
           frame(nEN,:) = frame(nEN,:)/ferrlim;
           error_bit(nEN,:) = error_bit(nEN,:)/(ferrlim*N*N);
    end
    snr = 1:EbN0db;
    semilogy(snr,frame(:,1),'black-');
    hold on;
    semilogy(snr,frame(:,2),'black-');
    semilogy(snr,frame(:,3),'black-');
    xlabel("Eb/No");
    ylabel("Word Error Rate");
    %title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
    grid on;
    hold off;
    %legend('proposed method','three-step','two-step');
    saveas(gcf,strcat("WER_",num2str(N),'_',num2str(K),'_tea.png'));
    semilogy(snr,error_bit(:,1),'-');
    hold on;
    semilogy(snr,error_bit(:,2),'-');
    semilogy(snr,error_bit(:,3),'-');
    xlabel("Eb/No");
    ylabel("Bit Error Rate");
    %title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
    grid on;
    hold off;
    %legend('proposed method','three-step','two-step');
    saveas(gcf,strcat("BER_",num2str(N),'_',num2str(K),'_tea.png'));
end
end