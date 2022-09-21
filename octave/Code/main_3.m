function [] = main_3(check_bit)
G = hammgen(check_bit);
[row,col] = size(G);
G = [G,zeros(row,1);ones(1,col+1)];
G = rem(abs(rref(G)),2);
c = check_bit+1;
k = 2^check_bit - 1- check_bit;
n = 2^check_bit;
H = gen2par(G);
EbN0db = 10;
table = create_table(H);
rate = k/n;
ferrlim = 10000;
error_set_1 ={};
error_set_2 = {};
error_set_3 = {};
error_set_4 = {};
Errors = {};
numE = [];
numEE = [];
numE2 = [];
numE3 = [];
frame = zeros(EbN0db,3);
error_bit =  zeros(EbN0db,3);
    for nEN = 1:EbN0db
        req_2 = 0;
        req_3 = 0;
        req_4 = 0;
        count = 0;
        count1 = 0;
        count2 = 0;
        count3 = 0;
        en = 10^(nEN/10);
        sigma = 1/sqrt(2*rate*en);
        nframe = 0;
        while nframe < ferrlim
            nframe = nframe+1;
            [msg_org] = Binary_generate(k*k);
            msg = reshape(msg_org,[k,k]);
            code = Hamming_Encoding(msg,G);
            I = 2*code -1;
            rec = I + sigma*randn(n,n);
            rec =(sign(rec)+1)/2;
            est_code = Bao(H,rec,table);
            [est_code2,req] = Bao_v3(H,rec,table,code);
            [est_code3,req2] = Double_step(H,rec,table,code);
            [est_code4,req3] = IDPC(H,rec,table,code);
            if isequal(est_code2,code) == 0
                count1 = count1+1;                  
                numE = [numE,length(find(rec ~= code)==1)];
                error_set_1 = [error_set_1,code~= rec ];
                Errors = [Errors,est_code2 ~= code];
                req_2 = req_2 + req;
                if isequal(est_code2,code) ~= 1-req
                    disp("error");
                end
            end
            if isequal(est_code,code) == 0
                error_set_2 = [error_set_2,code~= rec ];
                numEE = [numEE,length(find(rec ~= code)==1)];
                count = count+1;
            end
            if isequal(est_code3,code) == 0
                error_set_3 = [error_set_3,code~= rec ];
                numE2 = [numE2,length(find(rec ~= code)==1)];
                count2 = count2+1;
                req_3 = req_3 + req2;
            end
            if isequal(est_code4,code) == 0
                error_set_4 = [error_set_4,code~= rec ];
                numE3 = [numE3,length(find(rec ~= code)==1)];
                count3 = count3+1;
                req_4 = req_4 + req3;
            end
        end
    end
end