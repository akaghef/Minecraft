M=10000;
T=array2table(zeros(M,5),"VariableNames",["T" "S" "C" "SE" "CE"]);
    N=13;
    S=10^12;
    d2r=pi/180;

    repeats=[1 repmat([3 3 2 1],[1 6])];
    theta_d=atand([1 kron(10.^-(1:6),[3 3 2 1])]);
    R0=prod(cosd(theta_d));

for iter=1:M
    Theta0=90*rand;

    Theta=core(Theta0*S/10);
    shiftN=0;
    shiftC=1;
    Cos=core(R0*S+10);
    Sin=core(0);
    for ii=1:length(theta_d)
        sgn(ii)=1-2*(Theta<core(0));
        Theta=Theta-core(sgn(ii)*theta_d(ii)*S/10);
        Cos_=Cos-Sin.shift(shiftN)*(sgn(ii)*repeats(ii));
        Sin=Sin+Cos.shift(shiftN)*(sgn(ii)*repeats(ii));
        Cos=Cos_;
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
    % U=core(10^-7*S);
    O=core(0);
    sgn2=[];
    Sin2=Sin.shift(7);
    Cos2=Cos.shift(7);
    for n=7:11
        for jj=1:9
            sgn2(end+1)=1-2*(Theta<core(0));
            Theta=Theta-Dt*sgn2(end);
            Cos=Cos-Sin2*sgn2(end);
            Sin=Sin+Cos2*sgn2(end);
        end
        Dt=Dt.shift;
        Cos2=Cos2.shift;
        Sin2=Sin2.shift;
    end
    T{iter,:}=[Theta0 sind(Theta0) cosd(Theta0),...
        Sin.do-sind(Theta0) Cos.do-cosd(Theta0)];
end
beep
%%
histfit(T.SE)
pd=fitdist(T.SE,"Normal");
title("sin error n=10000")
ylabel occurence
xlabel error
text(0.7,0.7,"σ:"+pd.sigma,'Units','normalized','FontSize',14)
savefig("toSAVE/sin_error_normpdf.fig")
%%
histfit(T.SE)
pd=fitdist(T.SE,"Normal");
mean(sqrt(T.S.^2+T.C.^2)-1)



