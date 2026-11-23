%座標
pos0=[99 -44 69];
pos1=[0 0 -3.5];
pos2=[0 1 0];
posM0={[114 -43 74],[114 -43 62],[114 -43 68],[101 -43 68]};
posM1={[0 0 -2.5],[0 0 -2.5],[0 0 -2.5],[0 0 -2.5]};
PName=[string(1:10) reshape(["M4" "M2" "M1" "A"] +["l";"u"],[1,8])];
% ファイル操作
SBName="Val";
funcpath=string(getenv("MINECRAFT_FUNCTIONS_DIR"));
assert(strlength(funcpath)>0,"Set MINECRAFT_FUNCTIONS_DIR to the datapack functions folder.");
filename=struct("B","begin_val.mcfunction","L","loop_val.mcfunction","T","tell_val.mcfunction");

% 関数
ofs=@(n)(10^n-1)/9;
fil=10^8;
CtoSB=@(VN,XYZ,SC)sprintf(join(["execute store result score",VN,SBName,"run data get block %d %d %d OutputSignal",SC]),XYZ);
SetSB=@(VN,V)join(["scoreboard players set",VN,SBName,V]);
ProdSB=@(VN1,VN2)join(["scoreboard players operation",VN1,SBName,"*=",VN2,SBName]);
AddSB=@(VN1,VN2)join(["scoreboard players operation",VN1,SBName,"+=",VN2,SBName]);
SubsSB=@(VN1,VN2)join(["scoreboard players operation",VN1,SBName,"=",VN2,SBName]);
getSB=@(SBName_,PName_)"{""score"":{""name"":"""+PName_+""",""objective"":"""+SBName_+"""}}";
textSB=@(txt,col)"{""text"":"""+txt+""",""color"":"""+col+"""}";
tellLog=@(str)"tellraw @p ["+join(str,",")+"]";
% getVal=@()

% 変数
commandL="";
commandB="";
commandT="";
T=cell2table(cell(0,7),"VariableNames",["n" "b" "A" "M1" "M2" "M4" "I"]);

pos0=pos0+pos1;
posM0{1}=posM0{1}+posM1{1};
posM0{2}=posM0{2}+posM1{2};
posM0{3}=posM0{3}+posM1{3};
posM0{4}=posM0{4}+posM1{4};
for ii=1:13
    T(ii,:)={ii,10^(ii-1),...
        pos0+(-1)^ii*pos1+(ii-1)*pos2,...
        posM0{1}+(-1)^ii*posM1{1}+(ii-1)*pos2,...
        posM0{2}+(-1)^ii*posM1{2}+(ii-1)*pos2,...
        posM0{3}+(-1)^ii*posM1{3}+(ii-1)*pos2,...
        posM0{4}+(-1)^ii*posM1{4}+(ii-1)*pos2};
end
T.b(8:end)=T.b(8:end)/10^7;
T.cn="#c"+T.n;
T.bn="b"+T.n;



%Loop
commandL(end+1)=SubsSB("#Au2","");
commandL(end+1)=SetSB("Au",18*fil-ofs(6));
commandL(end+1)=SetSB("Al",17*fil-ofs(7));
commandL(end+1)=SetSB("M1u",16*fil);
commandL(end+1)=SetSB("M1l",15*fil);
commandL(end+1)=SetSB("M2u",14*fil);
commandL(end+1)=SetSB("M2l",13*fil);
commandL(end+1)=SetSB("M4u",12*fil-2*ofs(6));
commandL(end+1)=SetSB("M4l",11*fil-2*ofs(7));
commandL(end+1)=SetSB("Iu",9*fil);
commandL(end+1)=SetSB("Il",8*fil);

commandL=makecomL(commandL,"A",T);
commandL=makecomL(commandL,"M1",T);
commandL=makecomL(commandL,"M2",T);
commandL=makecomL(commandL,"M4",T);
commandL=makecomL(commandL,"I",T);

commandL(end+1)="scoreboard players operation t Val = akaghef time";
commandL(end+1)=CtoSB("sgn",[106 -30 71],1);
%tell
commandT=makecomT(commandT,"A",T,1);
commandT=makecomT(commandT,"M1",T,2);
commandT=makecomT(commandT,"M2",T,3);
commandT=makecomT(commandT,"M4",T,4);
commandT(end+1)=tellLog([textSB("val:"+5,"red") """ """ getSB("Val","sgn")]);


%show
disp("#begin")
arrayfun(@disp,commandB)

disp("#loop")
arrayfun(@disp,commandL)
disp("#tell")
arrayfun(@disp,commandT)

%%
%write
writelines(compose(join(commandB(2:end),"\n")),fullfile(funcpath,filename.B))
writelines(compose(join(commandL(2:end),"\n")),fullfile(funcpath,filename.L))
writelines(compose(join(commandT(2:end),"\n")),fullfile(funcpath,filename.T))
%%
logFilePath="/Users/nisimoriyuuya/MinecraftUser/Fabric2/logs/latest.log";
logs = readlines(logFilePath);
% keyWord="[Render thread/INFO]: [System] [CHAT] value:";

idx=find(contains(logs,"time:0 0"),1,"last");
disp(logs(idx))
Data=logs(idx+1:end);
idx=contains(Data,"[Render thread/INFO]: [System] [CHAT] val:");
Data=Data(idx);
% Data=double(split(extractAfter(Data(idx),"val:")));
% m=length(unique(Data(:,1)));
% c=cell(1,m);
%%
c=cell(1,5);

for ii=1:sum(idx)
    datanum=double(split(extractAfter(Data(ii),"val:")));
    c{datanum(1)}(end+1,:)=datanum(2:end);
end
c2=cell(1,5);
d2=cell(1,5);
offset=1;
offset2=[1 0 0 2 0];
for ii=1:length(c{1})
    for jj=1:5
        if jj==5
            datanum=c{jj}(ii);
        else
            datanum=c{jj}(ii,1:end-1)-offset2(jj);
            datanum(datanum<0)=0;
            datanum=int64(double(join(string(datanum),"")));
            d2{jj}(ceil(ii/3),1)=c{jj}(ii,end);
        end
        c2{jj}(floor((ii+offset)/3)+1,mod(ii+offset,3)+1)=datanum;

    end
end
len=size(c2{1},1);
d2{1}(len+1)=-1;
d2{1}(len+1:end)=[];
Tval2=table((1:len).',c2{1}(:,1),c2{1}(:,2),c2{1}(:,3),c2{5}(:,1),c2{5}(:,2),c2{5}(:,3),d2{1}, ...
    VariableNames=["idx" "core0" "core1" "core2" "s0" "s1" "s2" "time"]);
Tval2=[Tval2 table(c2{2}(:,1),c2{2}(:,2),c2{2}(:,3),...
        VariableNames=["m1_0" "m1_1" "m1_2"])];
Tval2.signerror=arrayfun(@(x,y)mod(x+y+1,2),Tval2.s0,Tval2.s1);
TT=Tval2(175:200,:)

% getN=@(x)
% c{1}=max(c{1}-1,0);
% m(2)=max(cellfun(@length,c));
%%
cs=cellfun(@(x)struct("N",int64(double(join(string(x(:,1:end-1)),""))),"T",int64(x(:,end))),c);
phase=floor(mod(double(cs(1).T.')+4,6)/2)+1;
tarray=cs(1).T.';
cs=arrayfun(@(x,y){x.N-int64(y{1}(:,1)/9*10^13)},cs,c);



function com=makecomL(com,name,T)
    CtoSB=evalin("base","CtoSB");
    AddSB=evalin("base","AddSB");
    for ii=1:13
        com(end+1)=CtoSB(T.cn(ii),T{ii,name},T.b(ii));
    end
    for ii=1:7
        com(end+1)=AddSB(name+"l",T.cn(ii));
    end
    for ii=8:13
        com(end+1)=AddSB(name+"u",T.cn(ii));
    end
end
function com=makecomT(com,name,T,index)
        CtoSB=evalin("base","CtoSB");
        getSB=evalin("base","getSB");
        tellLog=evalin("base","tellLog");
        textSB=evalin("base","textSB");
        for ii=1:13
            com(end+1)=CtoSB(T.cn(ii),T{ii,name},1);
        end
        str1=[arrayfun(@(n)getSB("Val",n),flip(T.cn)') getSB("time","akaghef")];
        str2=repmat(""" """,size(str1));

        com(end+1)=tellLog([textSB("val:"+index,"red") reshape([str2;str1],1,length(str1)*2)]);
end
