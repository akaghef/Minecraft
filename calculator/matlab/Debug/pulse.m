pos=[92 -49 64];
N=2;%1:set,2:reset
duration=4;%gt

funcpath="/Users/nisimoriyuuya/MinecraftUser/Fabric2/saves/New World (1)/datapacks/testpack/data";
subfuncpath=["c/functions" "func/functions"];
filename=fullfile(funcpath,subfuncpath([1 2 2]),["pulse" "setred" "setair"]+N+".mcfunction");
command="";
command(1)="function func:setred"+N;
command(2)="schedule function func:setair"+N+" "+duration+"t";
command(3)=join(["setblock" pos "minecraft:redstone_block"]);
command(4)=join(["setblock" pos "air"]);

writelines(command([1 2]),filename(1));
writelines(command(3),filename(2));
writelines(command(4),filename(3));
