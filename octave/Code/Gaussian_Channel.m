function [frame_error,bit_error] = Gaussian_Channel()
[H,G,N,K] = hammgen(3);
G2 = hammgen(3);
[row,col] = size(G2);
G2 = [G2,zeros(row,1);ones(1,col+1)];
G2 = rem(abs(rref(G2)),2);
C2 = 4;
K2 = 2^4 - 1- 4;
N2 = 2^4;
H2 = gen2par(G2);
rate1 = K*K/(N*N);
rate2 = K*K/((N+1)*(N+1)); 
EbN0db = 10;
Errors = zeros(EbN0db,5);
test_times = 500000;
frame_error = zeros(EbN0db,5);
bit_error = zeros(EbN0db,5);
disp("Start Gaussian Channel Experiments");
for SNR = 1:EbN0db
    en = 10^(SNR/10);
    sigma1 = 1/sqrt(2*rate1*en);
    sigma2 = 1/sqrt(2*rate2*en);
    st = sprintf("Now conduct SNR = %d experiment\n",SNR);
    disp(st);
    tic;
    for times = 1:test_times
        [msg_org] = Binary_generate(K*K);
        msg = reshape(msg_org,[K,K]);
        code1 =  Hamming_Encoding(msg,G);
        code2 = Hamming_Encoding(msg,G2);
        I1 = 2*code1 -1;
        I2 = 2*code2 -1;
        rec1 = I1 + sigma1*randn(N,N);
        rec1 =(sign(rec1)+1)/2;
        rec2 = I2 + sigma2*randn(N+1,N+1);
        rec2 =(sign(rec2)+1)/2;
        table = create_table(H2);
        est_code_1 = Proposed_method2(H,rec1);
        est_code_2 = Double_step(H2,rec2,table,code2);
        est_code_3 = IDPC(H2,rec2,table,code2);
        est_code_4 = Bao(H2,rec2,table);
        est_code_5 = Bao_v3(H2,rec2,table,code2);
        Errors(SNR,1) = length(find(est_code_1 ~= code1));
        Errors(SNR,2) = length(find(est_code_2 ~= code2));
        Errors(SNR,3) = length(find(est_code_3 ~= code2));
        Errors(SNR,4) = length(find(est_code_4 ~= code2));
        Errors(SNR,5) = length(find(est_code_5 ~= code2));
        for index = 1:5
            if Errors(SNR,index)
                frame_error(SNR,index) = frame_error(SNR,index)+1;
                bit_error(SNR,index) = bit_error(SNR,index) + Errors(SNR,index);
            end
        end
        if(mod(times,50000) == 0)
            t = toc;
            fprintf("Now conduct %d times, total is %d times\n Consumed %0.3f second\n",times,test_times,t);
            tic;
        end
    end
    frame_error(SNR,:) = frame_error(SNR,:)/test_times;
    bit_error(SNR,1) =  bit_error(SNR,1)/(test_times*N*N);
    bit_error(SNR,2:end) = bit_error(SNR,2:end)/(test_times *(N+1)*(N+1));
end
toc;
    %save('Two_D_EH_Gaussian_FE.mat','frame_error');
    %save('Two_D_EH_Gaussian_BE.mat','bit_error');
%     snr = 1:EbN0db;
%     %semilogy(snr,frame(:,1),'ob-');
%     semilogy(snr,frame_error(:,2),'ob-');
%     hold on;
%     semilogy(snr,frame_error(1:9,3),'or-');
%     semilogy(snr,frame_error(1:9,4),'oy-');
%     semilogy(snr,frame_error(1:9,5),'og-');
%     xlabel("Eb/No");
%     ylabel("Word Error Rate");
%     title(['Performance of [',num2str(N+1),',',num2str(K),']X[',num2str(N+1),',',num2str(K),'] product code']);
%     grid on;
%     hold off;
%     legend('Double step','IDPC','Bao Method','Proposed method');
%     saveas(gcf,strcat("WER_Second_",num2str(N),'_',num2str(K),'.png'));
%     semilogy(snr,bit_error(1:9,2),'ob-');
%     hold on;
%     semilogy(snr,bit_error(1:9,3),'or-');
%     semilogy(snr,bit_error(1:9,4),'oy-');
%     semilogy(snr,bit_error(1:9,5),'og-');
%     xlabel("Eb/No");
%     ylabel("Bit Error Rate");
%     title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
%     grid on;
%     hold off;
%     legend('Double step','IDPC','Bao Method','Proposed method');
%     saveas(gcf,strcat("BER_Second_",num2str(N),'_',num2str(K),'.png'));
end