
x0=[100 -31 38];
dx0=[0 0 -9];
p1=[2 0 3];%トーチ
p2=[-3 0 0];%コンパレータ
x1=[72 -38 36];%トーチ
dx1=[0 0 -2];
x2=[71 -36 36];%コンパレータ
posc=cell(13,4);
xc=x0+dx0/2;
dxc=-dx0/2;
dy=[0 1 0];
flip3=[1 1 -1];
for kk=0:12
    posc{kk+1,1}=xc+flip3.^kk.*(dxc+p1)-dy*kk-dy;
    posc{kk+1,2}=xc+flip3.^kk.*(dxc+p2)-dy*kk-dy;
    posc{kk+1,3}=x1+dx1*kk;
    posc{kk+1,4}=x2+dx1*kk;

end
cpos=cell(13,1);
disp(newline)
for kk=0:12
    fprintf("clone %d %d %d %d %d %d %d %d %d\n", ...
            [posc{kk+1,[1 1 3]}])
    fprintf("clone %d %d %d %d %d %d %d %d %d\n", ...
            [posc{kk+1,[2 2 4]}])
end
