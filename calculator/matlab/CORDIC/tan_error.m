array=[];
M=10000;
N=13;
% for N_T=N-[4 3]
N_T=9;

S=10^12;
d2r=pi/180;
T=array2table(zeros(M,7),"VariableNames",["X" "S" "C" "T" "SE" "CE" "TE"]);
for iter=1:M
    while true
        Theta0=90*rand;
        if tand(Theta0)<10&&tand(Theta0)>1
            break
        end
    end
    repeats=[1 repmat([4 2 2 1],[1 6])];
    theta_d=atand([1 kron(10.^-(1:6),[4 2 2 1])]);
    R0=prod(cosd(theta_d));



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
    Tan=core(0);
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



    A=Sin;
    B=Cos;
    U=core(S);
    Tan=core(0);
    for ii=0:N_T
        for jj=0:9
            if A<B
                break
            end
            A=A-B;
            Tan=Tan+U;
        end
        B=B.shift;
        U=U.shift;
    end

    T{iter,:}=[Theta0 sind(Theta0) cosd(Theta0) tand(Theta0),...
        Sin.do-sind(Theta0) Cos.do-cosd(Theta0) Tan.do-tand(Theta0)];
    % T{iter,:}=[Ai Bi Ai/Bi abs(double(O.n-Oans.n))];
end

%%
histfit(T.TE)
pd=fitdist(T.TE,"Normal");
title("tan error n="+N+", N_T="+N_T)
ylabel occurence
xlabel error
text(0.7,0.7,"σ:"+pd.sigma,'Units','normalized','FontSize',14)
savefig("toSAVE/tan_error_normpdf_NT="+N_T+".fig")

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
    Eest(ii)=rwide*(-1+2*rand(size(rwide)))'*10^-12;
end
histfit(Eest)
pd2=fitdist(Eest',"Normal")
