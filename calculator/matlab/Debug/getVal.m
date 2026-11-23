%座標
pos0=[99 -44 69];
pos1=[0 0 -3.5];
pos2=[0 1 0];
% ファイル操作
SBName="Val";
funcpath=string(getenv("MINECRAFT_FUNCTIONS_DIR"));
assert(strlength(funcpath)>0,"Set MINECRAFT_FUNCTIONS_DIR to the datapack functions folder.");
filename=struct("B","begin_val.mcfunction","L","loop_val.mcfunction");

% 関数群
CtoSB=@(VN,XYZ)sprintf(join(["execute store result score",VN,SBName,"run data get block %d %d %d OutputSignal"]),XYZ);
SetSB=@(VN,V)join(["scoreboard players set",VN,SBName,V]);
ProdSB=@(VN1,VN2)join(["scoreboard players operation",VN1,SBName,"*=",VN2,SBName]);
AddSB=@(VN1,VN2)join(["scoreboard players operation",VN1,SBName,"+=",VN2,SBName]);
SubsSB=@(VN1,VN2)join(["scoreboard players operation",VN1,SBName,"=",VN2,SBName]);

% 変数
commandL="";
commandB="";
T=cell2table(cell(0,3),"VariableNames",["n" "c" "b"]);

pos0=pos0+pos1;
for ii=1:13
    T(ii,:)={ii,pos0+(-1)^ii*pos1+(ii-1)*pos2,10^(ii-1)};
end
T.b(8:end)=T.b(8:end)/10^7;
T.cn="c"+T.n;
T.bn="b"+T.n;

%Begin
for ii=1:13
    commandB(end+1)=SetSB(T.bn(ii),T.b(ii));
    % commandB(end+1)=SetSB(T.cn(ii),0);
end
commandB(end+1)=SetSB("s1",0);
commandB(end+1)=SetSB("s2",0);
commandB(end+1)=SetSB("f",10^9);

%Loop
commandL(end+1)=SubsSB("s1","f");
commandL(end+1)=SubsSB("s2","f");
commandL(end+1)=AddSB("s2","f");
for ii=1:13
    commandL(end+1)=CtoSB(T.cn(ii),T{ii,"c"});
end
for ii=1:13
    commandL(end+1)=ProdSB(T.cn(ii),T.bn(ii)); 
end
for ii=1:7
    commandL(end+1)=AddSB("s1",T.cn(ii));
end
for ii=8:13
    commandL(end+1)=AddSB("s2",T.cn(ii));
end

%show
disp("begin")
arrayfun(@disp,commandB)

disp("loop")
arrayfun(@disp,commandL)
%%
%write
writelines(compose(join(commandB(2:end),"\n")),fullfile(funcpath,filename.B))
writelines(compose(join(commandL(2:end),"\n")),fullfile(funcpath,filename.L))