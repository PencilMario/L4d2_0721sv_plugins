#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

#define PLUGIN_VERSION "0.1"
#define CONFIG_FILENAME "l4d_fuck_zuolao"

int g_sRestartCount;
int g_sZuoLaoLevel;
int g_teamSafeCountTime;

Handle healtimer;

ConVar g_iZuoLaoLv;  
ConVar g_iZuoLaoHeadShotHpLv, g_iZuoLaoRegHp40Lv, g_iZuoLaoGivePillLv, g_iZuoLaoGiveVomitLv, g_iZuoLaoRegHp100Lv;
ConVar g_iZLGivePillCount, g_iZLGiveVomitCount;
public Plugin myinfo =
{
	name = "[L4D2] ZuolaoAnti",
	author = "SirP",
	description = "在重开多次时给buff帮助通关",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_zuolaoprint", call_Print_Zuolao, "输出坐牢等级");
	HookEvent("infected_death", Infected_Death_Event);
	HookEvent("round_end", RoundEnd_Event);
	HookEvent("round_start", RoundStart_Event);
	HookEvent("player_hurt", PlayerHure_Event);

	CreateConVar("zl_Plugin_Version", PLUGIN_VERSION, "Anti坐牢插件版本")
	g_iZuoLaoLv = CreateConVar("zl_Per_Level_Time", "5", "每个坐牢等级的间隔，坐牢等级的计算公式为(重启次数/cvar值)-1", FCVAR_SPONLY|FCVAR_NOTIFY, true, 1);
	g_iZuoLaoHeadShotHpLv = CreateConVar("zl_Headshot_regHp", "1", "启用爆头CI回血所需要的坐牢等级", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZuoLaoRegHp40Lv = CreateConVar("zl_Slow_RegTo40_Level", "2", "启用缓慢回血至40所需的坐牢等级 *当队伍中任何人受伤时，回血会暂停9s", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZuoLaoGivePillLv = CreateConVar("zl_GivePill_Level", "4", "启用开局药所需的坐牢等级", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZLGivePillCount = CreateConVar("zl_GivePill_Count","4" , "给药数量", FCVAR_SPONLY|FCVAR_NOTIFY, true , 1, true, 4)
	g_iZuoLaoGiveVomitLv = CreateConVar("zl_GiveVomit_Level", "5", "启用开局胆汁所需要的坐牢等级", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZLGiveVomitCount = CreateConVar("zl_GiveVomit_Count","2" , "给胆汁数量", FCVAR_SPONLY|FCVAR_NOTIFY, true , 1, true, 4)
	g_iZuoLaoRegHp100Lv = CreateConVar("zl_Fast_RegTo100_Level", "7", "启用快速回血至100所需的坐牢等级 *当队伍中任何人受伤时，回血会暂停9s", FCVAR_SPONLY|FCVAR_NOTIFY);

	AutoExecConfig(true, CONFIG_FILENAME);
}

public Action call_Print_Zuolao(int client, int args){
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}坐牢等级 \x0B> {olive}%d", g_sZuoLaoLevel);
}

public OnMapStart()
{
	g_sRestartCount = 0;
	g_sZuoLaoLevel = 0;
	g_teamSafeCountTime = 3;
	PrintZuoLaoStatus();
}
public PrintZuoLaoStatus()
{
	//CPrintToChatAll("{green}[{lightgreen}!{green}] {default}坐牢等级 \x0B> {olive}%d", g_sZuoLaoLevel);
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoHeadShotHpLv)) CPrintToChatAll("{default}经过短暂的坐牢旅途, 你明白了必须无时不刻都要准备状态\n{green}现在爆头CI将会回复HP!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoRegHp40Lv)) CPrintToChatAll("{default}经过一次又一次的坐牢, 你明白必须要让自己不能拖累团队\n{green}现在HP低于40将会缓慢恢复!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoGivePillLv)) CPrintToChatAll("{default}出于对坐牢的恐惧, 你做足了准备\n{green}现在开局将会给药!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoGiveVomitLv)) CPrintToChatAll("{default}出于对坐牢的恐惧, 你做足了准备\n{green}现在开局将会给胆汁!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoHeadShotHpLv)) CPrintToChatAll("{default}一次又一次的坐牢使你麻木不堪, 你已不想再继续坐牢了\n{green}现在HP回复的速度更快更多!");
}

// 检测是否坐牢
public Is_FuckZuolao()
{
	g_sZuoLaoLevel = (g_sRestartCount / GetConVarInt(g_iZuoLaoLv)) - 1
}

//---------------------------------------
// 坐牢等级 5 + 5x
// 
// 1. 爆头+1hp | 10
// 2. <40缓慢回至40
// 3. 
// 4. 开局额外4*药 
// 5. 开局额外2*胆汁 
// 6. 
// 7. 更快的回血速度 

// 坐牢计数器
public Action RoundEnd_Event(Event event, const String:name[], bool:dontBroadcast){
	g_sRestartCount++;
	Is_FuckZuolao();
	KillTimer(healtimer);
	healtimer = INVALID_HANDLE;
}

public Action PlayerHure_Event(Event event, const String:name[], bool:dontBroadcast){
	int player = GetClientOfUserId(event.GetInt("userid"))
	if (IsClientInGame(player) && GetClientTeam(player)==L4D_TEAM_SURVIVOR){
		g_teamSafeCountTime = 3;
	}
}

// 爆头回血
public Action Infected_Death_Event(Event event, const String:name[], bool:dontBroadcast){
	if (event.GetBool("headshot") == false) return;
	int client = GetClientOfUserId(event.GetInt("attacker"));
	int health = GetPlayerHealth(client);
	if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoHeadShotHpLv)){
		if (health < 100) SetPlayerHealth(client, health + 1);
	}
}

public int GetPlayerHealth(int player){
	return GetEntProp(player, Prop_Data, "m_iHealth");
}

public void SetPlayerHealth(int player, int health){
	SetEntProp(player, Prop_Data, "m_iHealth", health);
}

// 呼吸回血
public Action Timer_Re_Health(Handle Timer){
	if (g_teamSafeCountTime > 0){
		g_teamSafeCountTime--;
	}
	else
	{
		if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoRegHp40Lv)){
			for (new p = 1; p <= MaxClients; p++){
				if (IsClientInGame(p) && GetClientTeam(p)==2){
					int health = GetPlayerHealth(p);
					if (health < 40){
						SetPlayerHealth(p, health + 1);
					}
					if(health < 100 && g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoRegHp100Lv)){
						SetPlayerHealth(p, health + 4);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
// 开局给药
public Action RoundStart_Event(Event event, const String:name[], bool:dontBroadcast){
	// TIMER
	healtimer = CreateTimer(3.0, Timer_Re_Health, _,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	GivePill();
	GiveVomitjar();
}

public GivePill(){
	if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoGivePillLv)){
		int count = 0
		new flags = GetCommandFlags("give");	
		SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
		for (new i = 1; i <= MaxClients; i++)
		{
			count++
			if (IsClientInGame(i) && GetClientTeam(i)==2) FakeClientCommand(i, "give pain_pills");
			if (count == GetConVarInt(g_iZLGivePillCount)) break;
		}
		SetCommandFlags("give", flags|FCVAR_CHEAT);
	}
}


public GiveVomitjar(){
	if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoGiveVomitLv)){
		int count = 0;
		new flags = GetCommandFlags("give");	
		SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
		for (new i = 1; i <= MaxClients; i++)
		{
			count++
			if (IsClientInGame(i) && GetClientTeam(i)==2) FakeClientCommand(i, "give vomitjar");
			if (count==GetConVarInt(g_iZLGiveVomitCount)) break;
		}
		SetCommandFlags("give", flags|FCVAR_CHEAT);
	}
}