
Tval=array2table(int64(zeros(0,9)),"VariableNames",["D" "C" "C0" "C1" "C2" "M1" " M2" "M4" "time"]);
N=13;
S=10^12;
d2r=pi/180;
repeats=[1 repmat([4 2 2 1],[1 6])];
theta_d=[atand([1 kron(10.^-(1:4),[4 2 2 1])]),...
    kron(10.^-(1:2),atand(10^-4*[4 2 2 1]))];
R0=prod(cosd(theta_d));
% Theta0=12.3;
delayc=[8 repmat([7 5 5 4],[1 6])]*60;
delays=[0 1 1 1 2 2]*60;
Theta_r=core(Theta0*S/10);
shiftN=0;
shiftC=1;
Cos=core(R0*S);
Sin=core(R0*S);
Theta_r=Theta_r-core(theta_d(1)*S/10);
delay=delayc(1);
Tval(end+1,:)={shiftN shiftC Theta_r.n Sin.n Cos.n Cos.n Sin.n core(theta_d(1)*S/10).n,...
    delay};
for ii=2:length(theta_d)

    shiftC=shiftC-1;
    if shiftC==0
        shiftN=shiftN+1;
        shiftC=4;
    end
    Cos2=Cos.shift(shiftN);
    Sin2=Sin.shift(shiftN);
    sgn(ii)=1-2*(Theta_r<core(0));
    Theta_r=Theta_r-core(sgn(ii)*theta_d(ii)*S/10);
    Cos=Cos-Sin2*(sgn(ii)*repeats(ii));
    Sin=Sin+Cos2*(sgn(ii)*repeats(ii));
    delay=delay+delayc(ii)+delays(shiftN);
    Tval(end+1,:)={shiftN shiftC Theta_r.n Sin.n Cos.n Cos2.n Sin2.n core(sgn(ii)*theta_d(ii)*S/10).n,...
        delay};
end

Dt=core(theta_d(end)*S/10).shift;
% U=core(10^-7*S);
O=core(0);
sgn2=[];
Sin2=Sin2.shift;
Cos2=Cos2.shift;
Theta2=core(sgn(ii)*theta_d(ii)*S/100);
% delay=delay+120;
for n=7:11
    for jj=9:-1:1
        sgn2(end+1)=1-2*(Theta_r<core(0));
        Theta_r=Theta_r-Dt*sgn2(end);
        Cos=Cos-Sin2*sgn2(end);
        Sin=Sin+Cos2*sgn2(end);
        delay=delay+120;
        Tval(end+1,:)={n jj Theta_r.n Sin.n Cos.n Cos2.n Sin2.n Theta2.n,...
            delay};
    end
    Dt=Dt.shift;
    Cos2=Cos2.shift;
    Sin2=Sin2.shift;
    Theta2=Theta2.shift;
end

function out=shiftTime(in)
    if in<2
        out=1;
    elseif in<5
        out=2;
    else
        out=3;
    end
end
