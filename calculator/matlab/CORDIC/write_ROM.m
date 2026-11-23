o1=[144 -60 87];
d1=[0 0 1];
o2=[136 -31 58];
% o2=[136 -31 87];
d2=[-7.5 0 0];
d3=[-8 0 0];
d4=[0 0 2];
d5=[0 -1 0];

theta_d=[atand([1 kron(10.^-(1:4),[4 2 2 1])]),...
         kron(10.^-(1:2),atand(10^-4*[4 2 2 1]))];
R0=prod(cosd(theta_d));
idx=1+(0:3)*4+[1 2 4]';
val=int64([R0*10,theta_d(idx(:))]*10^11);
T=table([],[],'VariableNames',["src" "dst"]);

c2=o2+d2;
for n=1:13
    for m=1:13
        v=mod(floor(double(val(n))/10^(13-m)),10);
        if m<7
            T(end+1,:)={o1+v*d1,c2+(-1)^n*(d2-d3)+(m-0.5)*d4+(n-1)*d5};
        else
            T(end+1,:)={o1+v*d1,c2+(-1)^n*d2+(m-7)*d4+(n-1)*d5};
        end
    end
end

for ii=1:size(T,1)
    str(ii)=sprintf("clone %d %d %d %d %d %d %d %d %d\n", ...
            [T{ii,"src"},T{ii,"src"},T{ii,"dst"}]);
    
end
writelines(join(str,""),"toSAVE/write_rom.mcfunction")