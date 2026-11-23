N=13;
S=10^(N-1);
%　最悪case
% Ai=[4 repmat(9,[1 N-1])]*double(idivide(int64(2*S-1),int64(10.^(0:N-1)))).'/S;
% Bi=2-1/S;
M=10000;
T=array2table(zeros(M,4),"VariableNames",["A" "B" "D" "E"]);
for iter=1:M
    while true
        Ai=rand*9+1;
        Bi=rand*9+1;
        if Ai/Bi<10
            break
        end
    end
    A=core(Ai*S);
    B=core(Bi*S);
    U=core(S);
    O=core(0);
    for ii=0:N-2
        for jj=0:9
            if A<B
                break
            end
            A=A-B;
            O=O+U;
        end
        B=B.shift;
        U=U.shift;
    end
    Oans=core(Ai/Bi*S);

    T{iter,:}=[Ai Bi Ai/Bi abs(double(O.n-Oans.n))];
end
histogram(T{:,"E"},[0:39 5*(8:11)])
text(0.7,0.7,"mean:"+mean(T{:,"E"}),'Units','normalized','FontSize',14)
%%
title("error deviding for 0~N-1, n=10000")
xlabel error[eps]
ylabel occurence
savefig("toSAVE/dev_error2.fig")
%%
sum(T.E>9)/M
