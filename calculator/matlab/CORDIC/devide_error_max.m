N=13;
S=10^(N-1);
Ai=[4 repmat(9,[1 N-1])]*double(idivide(int64(2*S-1),int64(10.^(0:N-1)))).'/S;
Bi=2-1/S;
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
errorN=O.n-Oans.n;
