function [] = test()
Per = 0.2;
n = 8;
k = 4;
I = eye(4);
X = [0 1 1 1; 1 0 1 1; 1 1 0 1; 1 1 1 0];
G = [I X];
H = mod([-X' eye(4)],2);
[msg_org] = Binary_generate(k);
code = Encode(msg_org,G);
rec = rem(code+(rand(1,n) <= Per),2);
number = length(find(code ~= rec) == 1);
[correctedcode] = Decode(rec,H);
end
function [v] = Encode(u,G)
v = mod(u*G,2);
end
function [correctedcode] = Decode(w,H)
slt = syndtable(H);
syndrome = rem(w*H',2);
syndrome_de = bi2de(syndrome,'left-msb');
disp(['Sydrome = ',num2str(syndrome_de),...,
    '(decimal),',num2str(syndrome),'(binary)']);
corrvect = slt(1+syndrome_de,:);
correctedcode = rem(corrvect+w,2);
end