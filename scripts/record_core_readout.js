// Record the copied reference calculator, without supplying expected results.
(function(){
var E=Java.loadClass("net.fabricmc.fabric.api.event.lifecycle.v1.ServerTickEvents");
var T=Java.loadClass("net.fabricmc.fabric.api.event.lifecycle.v1.ServerTickEvents$EndTick");
var Speed=Java.loadClass("carpet.helpers.TickSpeed");
// This entry point is restricted to the dedicated verification copy.
var cwd=""+new (Java.loadClass("java.io.File"))(".").getCanonicalPath();
if(!cwd.endsWith("/.local/instances/calculator-complete-log"))throw new Error("Use the isolated calculator-complete-log copy");
if(!Speed.isPaused())throw new Error("Freeze the copied circuit before resetting");
var age=0,limit=7000,done=false,resetStable=0,startAge=null;var out="core-readout.jsonl";
if(AutoJS.exists(out))throw new Error("Preserve previous trace; choose a new output");
var board=AutoJS.server().method_3845(),timeObj=board.method_1165("time"),valObj=board.method_1165("Val");
function score(name,obj){return Number(board.method_1180(name,obj).method_1126());}
function val(x,y,z){var b=AutoJS.blockEntity(x,y,z);if(!b)return null;var m=(""+AutoJS.nbt(b)).match(/OutputSignal:(-?\d+)/);return m?Number(m[1]):null;}
function last(x,y,z){var b=AutoJS.blockEntity(x,y,z);if(!b)return null;var m=(""+AutoJS.nbt(b)).match(/LastExecution:(-?\d+)L/);return m?Number(m[1]):null;}
var names=["Au","Al","M1u","M1l","M2u","M2l","M4u","M4l","Iu","Il","t","sgn"];
AutoJS.write(out,"");AutoJS.command("function c:pulse2");if(Speed.isPaused())AutoJS.command("tick freeze");
E.END_SERVER_TICK.register(new JavaAdapter(T,{onEndTick:function(s){
 if(done)return;
 try{
 var ev="";
 if(age===0)ev="pulse2_before_unfreeze";

 var regs={A:[],M1:[],M2:[],M4:[],I:[]};
 for(var i=0;i<13;i++){
  regs.A.push(val(99,-44+i,i%2===0?69:62));regs.M1.push(val(114,-43+i,i%2===0?74:69));
  regs.M2.push(val(114,-43+i,i%2===0?62:57));regs.M4.push(val(114,-43+i,i%2===0?68:63));regs.I.push(val(101,-43+i,i%2===0?68:63));
 }
 var cleared=true;for(var k=0;k<13;k++)if(regs.A[k]>1||regs.M1[k]!==0||regs.M2[k]!==0||regs.I[k]!==0)cleared=false;
if(startAge===null){resetStable=cleared?resetStable+1:0;if(age>=100&&resetStable>=24){AutoJS.command("function c:pulse1");ev="pulse1";startAge=age;}}
var scores={};for(var j=0;j<names.length;j++)scores[names[j]]=score(names[j],valObj);
 var frozen=Speed.isPaused();
 var row={age:age,event:ev,server_tick:JSON.parse(""+AutoJS.snapshot()).tick,clock:score("#clock",timeObj),paused:frozen,regs:regs,scores:scores,sign:val(106,-30,71),tell_execution:last(107,-52,78),start_execution:last(96,-50,74)};
 row.reset_stable_ticks=resetStable;row.start_age=startAge;row.timing_events=[last(119,-30,62),last(111,-29,72),last(110,-30,70),last(118,-43,70),last(124,-46,54),last(105,-29,63),last(105,-32,57),last(111,-29,66)];
 if((frozen&&startAge!==null&&age>startAge+100)||age===limit-1){row.terminal_reason=frozen?"circuit_requested_freeze":"capture_limit";done=true;}
 AutoJS.append(out,JSON.stringify(row)+"\n");age++;
 }catch(e){AutoJS.append(out,JSON.stringify({age:age,error:""+e})+"\n");done=true;}
}}));return "complete observer registered";
})()
