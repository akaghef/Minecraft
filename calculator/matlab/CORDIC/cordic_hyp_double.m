N=13;
Theta0=0.5;
repeats=[repmat([4 2 2 1],[1 6])];
theta_d=atanh([kron(10.^-(1:6),[4 2 2 1])]);
R0=prod(cosh(theta_d));
Theta=Theta0;
shiftN=1;
shiftC=4;
Cosh=R0;
Sinh=0;
for ii=1:length(theta_d)
    sgn(ii)=1-2*(Theta<0);
    Theta=Theta-sgn(ii)*theta_d(ii);
    Cosh_=Cosh+Sinh*10^-shiftN*(sgn(ii)*repeats(ii));
    Sinh=Sinh+Cosh*10^-shiftN*(sgn(ii)*repeats(ii));
    Cosh=Cosh_;
    shiftC=shiftC-1;
    if shiftC==0
        shiftN=shiftN+1;
        shiftC=4;
    end
end


%%
Dt=theta_d(end)/10;
% U=core(10^-7*S);
O=core(0);
sgn2=[];
Sin2=Sinh*10^-7;
Cos2=Cosh*10^-7;
for n=7:11
    for jj=0:9
        sgn2(end+1)=1-2*(Theta<0);
        Theta=Theta-Dt*sgn2(end);
        Cosh=Cosh-Sin2*sgn2(end);
        Sinh=Sinh+Cos2*sgn2(end);
    end
    Dt=Dt/10;
    Cos2=Cos2/10;
    Sin2=Sin2/10;
end




