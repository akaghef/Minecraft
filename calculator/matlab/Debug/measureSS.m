names="A"+[1:9];

funcpath="/Users/nisimoriyuuya/MinecraftUser/Fabric2/saves/New World (1)/datapacks/testpack/data/c/functions";
%関数
armset=@(name)"summon minecraft:armor_stand ~ ~ ~ {CustomName:'{""text"":"""+name+"""}',CustomNameVisible:true,Tags:["""+name+"""]}";
measure=@(name)"execute at @e[type=minecraft:armor_stand,tag="+name+"] run " + ...
    "execute store result score "+name+" mobMeasure run data get block ~ ~ ~ OutputSignal";
getSB=@(name)"{""score"":{""name"":"""+name+""",""objective"":""mobMeasure""}}";
toLog=@(name)"/tellraw @p [{""text"":""value:"",""color"":""yellow""},"+join(arrayfun(getSB,name),","","",")+"]";

%出力

disp("begin")
disp(toLog(names))
disp("scoreboard objectives add mobMeasure dummy ""SS""")
arrayfun(@(n)disp(armset(n)),names)
%ループ書き込み
command="";
for n=names
    command(end+1)=measure(n);
end
%%
writelines(command(2:end)',fullfile(funcpath,"ss.mcfunction"))
