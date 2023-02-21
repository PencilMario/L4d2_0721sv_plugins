#include <sourcemod>
#include <sdktools>
#include <multicolors>

ConVar SS_1_SiNum;
ConVar SS_1_SiLim;
ConVar SS_Time;

public Plugin myinfo =
{
	name = "Ast SI Spawn Set Plugin",
	author = "Sir.P",
	description = "修改特感脚本的刷新数量",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_SetAiSpawns", Cmd_SetAiSpawns);
	RegConsoleCmd("sm_SetAiTime", Cmd_SetAiTime);
	SS_1_SiNum = CreateConVar("sss_1P", "18", "特感数量");

	SS_1_SiLim = CreateConVar("sss_1P_Lim", "3", "特感单类限制");

	SS_Time = CreateConVar("SS_Time", "15", "刷新间隔");

	HookEvent("round_start", RoundStart_Event);

	HookConVarChange(SS_1_SiNum, reload_script);
	HookConVarChange(SS_Time, reload_script);
}
public Action RoundStart_Event(Event event, const String:name[], bool:dontBroadcast){
	FakeClientCommand(1, "sm_reloadscript");
}
public reload_script(Handle:convar, const String:oldValue[], const String:newValue[]){
	FakeClientCommand(1, "sm_reloadscript");
}

public int SILimit(int num){
	int Si = num/6;
	if (Si*6 != num) Si++;
	if (Si <= 0) Si=1;
	return Si
}

public Action Cmd_SetAiTime(int client, int args)
{
	int time;
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_SetAiTime <刷新间隔>");
		return Plugin_Handled;
	}
	time = GetCmdArgInt(1);
	SS_Time.IntValue = time;
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d ，单类限制{olive}%d{default}只，单SlotCD{olive}%d",	SS_1_SiNum.IntValue, SS_1_SiLim.IntValue, SS_Time.IntValue);
	FakeClientCommand(1, "sm_reloadscript");
	return Plugin_Continue;
}

public Action Cmd_SetAiSpawns(int client, int args)
{
	int SiNum;

	if (args < 1)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_SetAiSpawns <特感数量>");
		return Plugin_Handled;
	}
	SiNum = GetCmdArgInt(1);
	SS_1_SiNum.IntValue = SiNum;
	SS_1_SiLim.IntValue = SILimit(SiNum);
	
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：最高同屏{olive}%d ，单类限制{olive}%d{default}只，单SlotCD{olive}%d",	SS_1_SiNum.IntValue, SS_1_SiLim.IntValue, SS_Time.IntValue);
	FakeClientCommand(1, "sm_reloadscript");
	return Plugin_Continue;
}
