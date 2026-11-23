N=13;
d2r=pi/180;
Theta0=70;
repeats=[1 repmat([4 2 2 1],[1 6])];
theta_d=atand([1 kron(10.^-(1:6),[4 2 2 1])]);
R0=prod(cosd(theta_d));
Theta=Theta0;
shiftN=0;
shiftC=1;
Cos=R0;
Sin=0;
for ii=1:length(theta_d)
    sgn(ii)=1-2*(Theta<0);
    Theta=Theta-sgn(ii)*theta_d(ii);
    Cos_=Cos-Sin*10^-shiftN*(sgn(ii)*repeats(ii));
    Sin=Sin+Cos*10^-shiftN*(sgn(ii)*repeats(ii));
    Cos=Cos_;
    shiftC=shiftC-1;
    if shiftC==0
        shiftN=shiftN+1;
        shiftC=4;
    end
end
Dt=theta_d(end)/10;
% U=core(10^-7*S);
O=core(0);
sgn2=[];
Sin2=Sin*10^-7;
Cos2=Cos*10^-7;
for n=7:11
    for jj=0:9
        sgn2(end+1)=1-2*(Theta<0);
        Theta=Theta-Dt*sgn2(end);
        Cos=Cos-Sin2*sgn2(end);
        Sin=Sin+Cos2*sgn2(end);
    end
    Dt=Dt/10;
    Cos2=Cos2/10;
    Sin2=Sin2/10;
end




