#include <sourcemod>
#include <sdktools>
#include <multicolors>

ConVar SS_1_SiNum;
ConVar SS_2_SiNum;
ConVar SS_3_SiNum;
ConVar SS_4_SiNum;
ConVar SS_1_SiLim;
ConVar SS_2_SiLim;
ConVar SS_3_SiLim;
ConVar SS_4_SiLim;

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
	SS_1_SiNum = CreateConVar("sss_1P", "4", "1人模式特感数量");
	SS_2_SiNum = CreateConVar("sss_2P", "9", "2人模式特感数量");
	SS_3_SiNum = CreateConVar("sss_3P", "14", "3人模式特感数量");
	SS_4_SiNum = CreateConVar("sss_4P", "18", "4人模式特感数量");

	SS_1_SiLim = CreateConVar("sss_1P_Lim", "1", "1人模式特感单类限制");
	SS_2_SiLim = CreateConVar("sss_2P_Lim", "2", "2人模式特感单类限制");
	SS_3_SiLim = CreateConVar("sss_3P_Lim", "3", "3人模式特感单类限制");
	SS_4_SiLim = CreateConVar("sss_4P_Lim", "3", "4人模式特感单类限制");

	HookConVarChange(SS_1_SiNum, reload_script);
	HookConVarChange(SS_2_SiNum, reload_script);
	HookConVarChange(SS_3_SiNum, reload_script);
	HookConVarChange(SS_4_SiNum, reload_script);

}

public reload_script(Handle:convar, const String:oldValue[], const String:newValue[]){
	FakeClientCommand(1, "sm_reloadscript");
}

public int SILimit(int num){
	int Si = num/6;
	if (Si*6 != num) Si++;
	if (Si <= 0) Si++;
	return Si
}

public Action Cmd_SetAiSpawns(int client, int args)
{
	int playermode;
	int SiNum;

	if (args < 2)
	{
		ReplyToCommand(client, "[SM] 使用方式: sm_SetAiSpawns <生还玩家数量> <特感数量>");
		return Plugin_Handled;
	}
	playermode = GetCmdArgInt(1);
	SiNum = GetCmdArgInt(2);
	switch(playermode){
		case 1:
		{
			SS_1_SiNum.IntValue = SiNum;
			SS_1_SiLim.IntValue = SILimit(SiNum);
		}
		case 2:
		{
			SS_2_SiNum.IntValue = SiNum;
			SS_2_SiLim.IntValue = SILimit(SiNum);
		}
		case 3:
		{
			SS_3_SiNum.IntValue = SiNum;
			SS_3_SiLim.IntValue = SILimit(SiNum);
		}
		case 4:
		{
			SS_4_SiNum.IntValue = SiNum;
			SS_4_SiLim.IntValue = SILimit(SiNum);
		}
		default:
		{
			PrintToChat(client, "[SM] 参数错误: sm_SetAiSpawns <生还玩家数量> <特感数量>");
		}
	}
	char name[64];
	GetClientName(client, name, sizeof(name));
	CPrintToChatAll("{green}[{lightgreen}!{green}] {olive}%s{default}修改了特感刷新配置", name);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}刷新配置：{olive}%d - %d - %d - %d",	SS_1_SiNum.IntValue, SS_2_SiNum.IntValue, SS_3_SiNum.IntValue, SS_4_SiNum.IntValue);
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}单种特感限制： {olive}%d - %d - %d - %d",	SS_1_SiNum.IntValue, SS_2_SiNum.IntValue, SS_3_SiNum.IntValue, SS_4_SiNum.IntValue);
	return Plugin_Continue;
}
