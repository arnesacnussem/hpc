function [Errors,Errors_bit,real_Error]=Comparision_HPC(Extend_flag)
disp("Conduct 3rd Experiment");
check_bit = 3;
if Extend_flag == 1
    Num_algorithm = 4;
    G = hammgen(check_bit);
    [row,col] = size(G);
    G = [G,zeros(row,1);ones(1,col+1)];
    G = rem(abs(rref(G)),2);
    c = check_bit+1;
    k = 2^check_bit - 1- check_bit;
    n = 2^check_bit;
    H = gen2par(G);
else
   Num_algorithm = 3;
   [H,G,n,k] = hammgen(check_bit);
end
Errors = [];    
Errors_bit = [];
real_Error = [];
test_times = 1000000;
for Ne = 1:12
    if Ne <= 5
        fprintf('conduct %d test. Waiting....\n',Ne);
        tic;
        [Ef,Eb,Es_1,Es_2] = Given_Error_test(Ne,-1,n,Num_algorithm,G,H);
        disp(Ef)
        disp(Eb)
        Errors = [Errors;Ef];
        Errors_bit = [Errors_bit;Eb];
        fprintf('Spend %.2f seconds\n',toc);
    else
        fprintf('conduct %d test. Waiting....\n',Ne);
        tic;
        [Ef,Eb] = Given_Error_test(Ne,test_times,n,Num_algorithm,G,H);
        fprintf('Spend %.2f seconds\n',toc);
        Errors = [Errors;Ef];
        Errors_bit = [Errors_bit;Eb];
        real_Error = [real_Error;Ef/test_times*combntns(n*n,Ne)];
    end
end
end
