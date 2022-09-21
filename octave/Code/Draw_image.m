function Draw_image(frame,error_bit)
    [r,c] = size(frame);
    snr = linspace(0.01,0.15,15);
    %snr = 1:10;
    semilogy(snr,frame(:,1),'black-','Linewidth',3);
    hold on;
    for i = 2:c
        semilogy(snr,frame(:,i),'black-','Linewidth',3);
    end
    xlabel("Eb/No");
    ylabel("Word Error Rate");
%     %title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
    grid on;
    hold off;
    %legend('proposed method','three-step','two-step');
    saveas(gcf,'BSC_EH_FE.png');
    semilogy(snr,error_bit(:,1),'black-','Linewidth',3);
    hold on;
    for i = 2:c
        semilogy(snr,error_bit(:,i),'black-','Linewidth',3);
    end
    xlabel("Eb/No");
    ylabel("Bit Error Rate");
    %title(['Performance of [',num2str(N),',',num2str(K),']X[',num2str(N),',',num2str(K),'] product code']);
    grid on;
    hold off;
    %legend('proposed method','three-step','two-step');
    saveas(gcf,'BSC_EH_BE.png');
end