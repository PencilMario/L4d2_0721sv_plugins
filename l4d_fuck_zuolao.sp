#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

int g_sRestartCount;
int g_sZuoLaoLevel;
int g_teamSafeCountTime;

Handle healtimer;

ConVar g_iZuoLaoLv;  
ConVar g_iZuoLaoHeadShouHpLv, g_iZuoLaoRegHp40Lv, g_iZuoLaoGivePillLv, g_iZuoLaoGiveVomitLv, g_iZuoLaoRegHp100Lv;
public Plugin myinfo =
{
	name = "[L4D2] ZuolaoAnti",
	author = "SirP",
	description = "在重开多次时给buff帮助通关",
	version = "0.1",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_zuolaoprint", call_Print_Zuolao, "输出坐牢等级");
	HookEvent("infected_death", Infected_Death_Event);
	HookEvent("round_end", RoundEnd_Event);
	HookEvent("round_start", RoundStart_Event);
	HookEvent("player_hurt", PlayerHure_Event);
}

public Action call_Print_Zuolao(int client, int args){
	CPrintToChatAll("{green}[{lightgreen}!{green}] {default}坐牢等级 \x0B> {olive}%d", g_sZuoLaoLevel);
}

public OnMapStart()
{
	g_sRestartCount = 0;
	g_sZuoLaoLevel = 0;
	g_teamSafeCountTime = 3;
}

// 检测是否坐牢
public Is_FuckZuolao()
{
	g_sZuoLaoLevel = (g_sRestartCount / 5) - 1
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
	if (g_sZuoLaoLevel >= 1){
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
		if (g_sZuoLaoLevel >= 2){
			for (new p = 1; p <= MaxClients; p++){
				if (IsClientInGame(p) && GetClientTeam(p)==2){
					int health = GetPlayerHealth(p);
					if (health < 40){
						SetPlayerHealth(p, health + 1);
					}
					if(health < 100 && g_sZuoLaoLevel >= 7){
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
	healtimer = CreateTimer(3.0, Timer_Re_Health, _,TIMER_REPEAT);
	GivePill();
	GiveVomitjar();
}

public GivePill(){
	if (g_sZuoLaoLevel >= 4){
		new flags = GetCommandFlags("give");	
		SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i)==2) FakeClientCommand(i, "give pain_pills");
		}
		SetCommandFlags("give", flags|FCVAR_CHEAT);
	}
}


public GiveVomitjar(){
	if (g_sZuoLaoLevel >= 5){
		int count = 0;
		new flags = GetCommandFlags("give");	
		SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
		for (new i = 1; i <= MaxClients; i++)
		{
			count++
			if (IsClientInGame(i) && GetClientTeam(i)==2) FakeClientCommand(i, "give vomitjar");
			if (count==2) break;
		}
		SetCommandFlags("give", flags|FCVAR_CHEAT);
	}
}