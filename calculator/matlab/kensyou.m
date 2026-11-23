addpath CORDIC/
addpath Debug/
%% 
% calculate CORDIC

Theta0=12.3;
cordic_latest
%% 
% getVal2.m  read log file

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

%%
TT=Tval2;
names=string(Tval.Properties.VariableNames);
v=find(~isnan(fillnan(Tval.time,TT.time)));
for n=names
    TT{v,n+"_"}=Tval{:,n};
end
fname="debug.xlsx";
writetable(TT,fname)