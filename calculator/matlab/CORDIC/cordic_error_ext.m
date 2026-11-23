M=10000;
T=array2table(zeros(M,7),"VariableNames",["T" "S" "C" "SE" "CE" "SE2" "CE2"]);
    N=13;
    S=10^12;
    d2r=pi/180;

    repeats=[1 repmat([4 2 2 1],[1 6])];
    theta_d=atand([1 kron(10.^-(1:6),[4 2 2 1])]);
    R0=prod(cosd(theta_d));
    Emax=struct("E",0);
for iter=1:M
    Theta0=90*rand;
    
    Theta=core(Theta0*S/10);
    Theta3=Theta0;
    shiftN=0;
    shiftC=1;
    Cos=core(R0*S);
    Sin=core(0);
    Cos3=R0;
    Sin3=0;
    for ii=1:length(theta_d)
        sgn(ii)=1-2*(Theta<core(0));
        sgn3(ii)=1-2*(Theta3<0);
        Theta=Theta-core(sgn(ii)*theta_d(ii)*S/10);
        Theta3=Theta3-sgn3(ii)*theta_d(ii);
        Cos_=Cos-Sin.shift(shiftN)*(sgn(ii)*repeats(ii));
        Sin=Sin+Cos.shift(shiftN)*(sgn(ii)*repeats(ii));
        Cos=Cos_;
        Cos_=Cos3-repeats(ii)*sgn3(ii)*Sin3*10^-shiftN;
        Sin3=Sin3+repeats(ii)*sgn3(ii)*Cos3*10^-shiftN;
        Cos3=Cos_;
        % disp("ii:"+ii+"  sgn:"+sgn(ii)+"  shift"+shiftN)
        % Theta.d;
        % disp(theta_d(ii))
        % Sin.d;
        % Cos.d;

        shiftC=shiftC-1;
        if shiftC==0
            shiftN=shiftN+1;
            shiftC=4;
        end
    end

    Dt=core(theta_d(end)*S/10).shift;
    Dt3=theta_d(end)/10;
    % U=core(10^-7*S);
    O=core(0);
    sgn2=[];
    sgn4=[];
    Sin2=Sin.shift(7);
    Cos2=Cos.shift(7);
    Sin4=Sin3*10^-7;
    Cos4=Cos3*10^-7;
    for n=7:11
        for jj=1:9
            sgn2(end+1)=1-2*(Theta<core(0));
            sgn4(end+1)=1-2*(Theta3<0);
            Theta=Theta-Dt*sgn2(end);
            Theta3=Theta3-Dt3*sgn4(end);
            Cos=Cos-Sin2*sgn2(end);
            Sin=Sin+Cos2*sgn2(end);
            Cos3=Cos3-Sin4*sgn4(end);
            Sin3=Sin3+Cos4*sgn4(end);
        end
        Dt=Dt.shift;
        Dt3=Dt3/10;
        Cos2=Cos2.shift;
        Sin2=Sin2.shift;
        Cos4=Cos4/10;
        Sin4=Sin4/10;
    end
    T{iter,:}=[Theta0 sind(Theta0) cosd(Theta0),...
        Sin.do-sind(Theta0) Cos.do-cosd(Theta0),...
        Sin3-sind(Theta0) Cos3-cosd(Theta0)];
    if abs(Sin.do-sind(Theta0))>Emax.E
        Emax.E=abs(Sin.do-sind(Theta0));
        Emax.Theta0=Theta0;
        Emax.sgn=sgn;
        Emax.sgn2=sgn2;
        Emax.sgn3=sgn3;
        Emax.sgn4=sgn4;
    end
end
pd=fitdist(T.SE,"Normal")
pd2=fitdist(T.SE2,"Normal")
%%
histfit(T.SE)
title("sin error n=10000")
ylabel occurence
xlabel error
text(0.7,0.7,"σ:"+pd.sigma,'Units','normalized','FontSize',14)
savefig("toSAVE/sin_error_normpdf.fig")
%%
histfit(T.SE)
pd=fitdist(T.SE,"Normal");
mean(sqrt(T.S.^2+T.C.^2)-1)
%%
% analyzeError
rwide=[repeats 9*ones(1,5)];
NE=10000;
Eest=zeros(1,NE);
for ii=1:NE
Eest(ii)=rwide*(2*normrnd(0,1,size(rwide)))';
end
histfit(Eest)
pd2=fitdist(Eest',"Normal")
%%
Eacc=[];
Theta0=Emax.Theta0;
    
    Theta=core(Theta0*S/10);
    Theta3=Theta0;
    shiftN=0;
    shiftC=1;
    Cos=core(R0*S);
    Sin=core(0);
    Cos3=R0;
    Sin3=0;
    for ii=1:length(theta_d)
        sgn(ii)=1-2*(Theta<core(0));
        sgn3(ii)=1-2*(Theta3<0);
        Theta=Theta-core(sgn(ii)*theta_d(ii)*S/10);
        Theta3=Theta3-sgn3(ii)*theta_d(ii);
        Cos_=Cos-Sin.shift(shiftN)*(sgn(ii)*repeats(ii));
        Sin=Sin+Cos.shift(shiftN)*(sgn(ii)*repeats(ii));
        Cos=Cos_;
        Cos_=Cos3-repeats(ii)*sgn3(ii)*Sin3*10^-shiftN;
        Sin3=Sin3+repeats(ii)*sgn3(ii)*Cos3*10^-shiftN;
        Cos3=Cos_;
        % disp("ii:"+ii+"  sgn:"+sgn(ii)+"  shift"+shiftN)
        % Theta.d;
        % disp(theta_d(ii))
        % Sin.d;
        % Cos.d;
        Eacc(end+1)=Sin.do-Sin3;
        shiftC=shiftC-1;
        if shiftC==0
            shiftN=shiftN+1;
            shiftC=4;
        end
    end

    Dt=core(theta_d(end)*S/10).shift;
    Dt3=theta_d(end)/10;
    % U=core(10^-7*S);
    O=core(0);
    sgn2=[];
    sgn4=[];
    Sin2=Sin.shift(7);
    Cos2=Cos.shift(7);
    Sin4=Sin3*10^-7;
    Cos4=Cos3*10^-7;
    for n=7:12
        for jj=1:9
            sgn2(end+1)=1-2*(Theta<core(0));
            sgn4(end+1)=1-2*(Theta3<0);
            Theta=Theta-Dt*sgn2(end);
            Theta3=Theta3-Dt3*sgn4(end);
            Cos=Cos-Sin2*sgn2(end);
            Sin=Sin+Cos2*sgn2(end);
            Cos3=Cos3-Sin4*sgn4(end);
            Sin3=Sin3+Cos4*sgn4(end);
        end
        Dt=Dt.shift;
        Dt3=Dt3/10;
        Cos2=Cos2.shift;
        Sin2=Sin2.shift;
        Cos4=Cos4/10;
        Sin4=Sin4/10
        Sin2.do
        Eacc(end+1)=Sin.do-Sin3;
    end
    %%
    plot(Eacc*10^13)
    sum(reshape(sgn2,[9,6]))
    hold on 
    plot(diff(Eacc*10^13))
    yline(0)
