logFilePath="/Users/nisimoriyuuya/MinecraftUser/Fabric2/logs/latest.log";
logs = readlines(logFilePath);
% keyWord="[Render thread/INFO]: [System] [CHAT] value:";
keyWord="[Render thread/INFO]: [System] [CHAT] time:";
idx=contains(logs,keyWord);
Data=logs(idx);
idx=find(contains(Data,"time:0 0"),1,"last");
disp(Data(idx))
Data=double(split(extractAfter(Data(idx+1:end),"time:")));
m=length(unique(Data(:,1)));
c=cell(1,m);
for ii=1:size(Data,1)
    c{Data(ii,1)}(end+1)=Data(ii,2)/10;
end
m(2)=max(cellfun(@length,c));
Ttime=array2table(nan(m).',VariableNames="A"+(1:m(1)));
for ii=1:m(1)
    Ttime{1:length(c{ii}),ii}=c{ii}.';
end
Ttime.Properties.VariableNames={'I12' 'O12' 'S12s' 'S12e' 'O3' 'U1' 'U2' 'O4'};
% T=T(1:50,[1:5 8])
Ttime
%%
% idx=contains(logs,"OutputSignal");
% logs(idx)
%%

ND=cell2mat(arrayfun(@(str)double(split(extractAfter(str,"value:"),",")'),Data,'UniformOutput',false));
ND(circshift(ND(:,3)==0,1),3)+1
%%

extractSB=@(key)cell2mat(arrayfun(@(str)double(split(extractAfter(str,key),",")'),Data,'UniformOutput',false));
t=extractSB("time:")';
t0=t(1);
t=(t-t0)/2;

%%

timerLog=@(tag)disp("/tellraw @p [{""text"":""time:"+tag+""",""color"":""yellow""},"" "",{""score"":{""name"":""akaghef"",""objective"":""time""}}]");
timerLog("a")
%%

t=extractSB("time:");
c=cell(1,5);
for ii=1:size(t,1)
    c{t(ii,1)+1}(end+1)=t(ii,2);
end
c0=cellfun(@(x)x(1),c);
d=c0(1)*ones(max(cellfun(@length,c)),length(c0));
for ii=1:length(c0)
    d(1:length(c{ii}),ii)=c{ii}';
end
d2=(d-c0(1))/2
%%
outputfilename="debug.xlsx";
writetable(Tval2,outputfilename)
% writetable(Tval,outputfilename,'Range',"Z1:AH100")
%%
A=Ttime.S12e';
B=Ttime.S12s';
for ii=1:size(A,2)
    a=find(A(1,ii)<B,1,"first");
    if isempty(a)
        continue
    end
    A(2,ii)=B(a);
end
