#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>


#define PLUGIN_VERSION "0.3"
#define CONFIG_FILENAME "l4d_fuck_zuolao"
int g_sRestartCount;
int g_sZuoLaoLevel;
int g_teamSafeCountTime;
new g_SafeCountTime[MAXPLAYERS+1] = 0;
int g_respawntarget = 0;
bool g_respawnused;
Handle healtimer;
Handle respawntimer;

static Float:g_pos[3];
static Handle:hRoundRespawn = INVALID_HANDLE;
static Handle:hBecomeGhost = INVALID_HANDLE;
static Handle:hState_Transition = INVALID_HANDLE;
static Handle:hGameConf = INVALID_HANDLE;

ConVar g_iZuoLaoLv;  
ConVar g_iZuoLaoHeadShotHpLv, g_iZupLaoRegMoreFast, g_iZuoLaoRegHp40Lv, g_iZuoLaoGivePillLv, g_iZuoLaoGiveVomitLv, g_iZuoLaoRegHp100Lv, g_iZuoLaoStart;
ConVar g_iZLGivePillCount, g_iZLGiveVomitCount, g_iHealingCooldownTime, g_iZlIgnoreIncapHurt, g_iZlRespawnFirstDied;
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
	RegConsoleCmd("sm_zllv", call_Print_Zuolao, "输出坐牢等级");
	HookEvent("infected_death", Infected_Death_Event);
	HookEvent("round_end", RoundEnd_Event);
	HookEvent("round_start", RoundStart_Event);
	HookEvent("player_hurt", PlayerHure_Event);
	HookEvent("player_death", PlayerDeath_Event);

	CreateConVar("zl_Plugin_Version", PLUGIN_VERSION, "Anti坐牢插件版本")
	g_iZuoLaoLv = CreateConVar("zl_Per_Level_Time", "3", "每个坐牢等级的间隔，坐牢等级的计算公式为(重启次数/cvar值)-1", FCVAR_SPONLY|FCVAR_NOTIFY, true, 1);
	g_iZuoLaoHeadShotHpLv = CreateConVar("zl_Headshot_regHp", "1", "启用爆头回血所需要的坐牢等级", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZuoLaoRegHp40Lv = CreateConVar("zl_Slow_RegTo40_Level", "2", "启用缓慢回血至40所需的坐牢等级 *当受伤时，回血会暂停", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZuoLaoGivePillLv = CreateConVar("zl_GivePill_Level", "4", "启用开局药所需的坐牢等级", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZLGivePillCount = CreateConVar("zl_GivePill_Count","4" , "给药数量", FCVAR_SPONLY|FCVAR_NOTIFY, true , 1, true, 4)
	g_iZuoLaoGiveVomitLv = CreateConVar("zl_GiveVomit_Level", "5", "启用开局胆汁所需要的坐牢等级", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZLGiveVomitCount = CreateConVar("zl_GiveVomit_Count","2" , "给胆汁数量", FCVAR_SPONLY|FCVAR_NOTIFY, true , 1, true, 4)
	g_iZuoLaoRegHp100Lv = CreateConVar("zl_Fast_RegTo100_Level", "7", "启用快速回血至100所需的坐牢等级 *当受伤时，回血会暂停", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZupLaoRegMoreFast= CreateConVar("zl_Fast_RegTo100More_Level", "8", "启用更快的回血所需的坐牢等级（每次回‘坐牢等级’点hp） *当受伤时，回血会暂停", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZlIgnoreIncapHurt = CreateConVar("zl_Ignore_Incap_Hurted", "10", "倒地时继续回血至100", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZlRespawnFirstDied = CreateConVar("zl_respawnFirstDied", "16", "复活第一个死亡的人(30s)", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_iZuoLaoStart = CreateConVar("zl_extra_level", "0", "额外的坐牢等级")
	g_iHealingCooldownTime = CreateConVar("zl_healing_cooldowntime", "3", "受伤回血cd*2")
	AutoExecConfig(true, CONFIG_FILENAME);

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(LoadGameConfigFile("l4drespawn"), SDKConf_Signature, "RoundRespawn");
	hRoundRespawn = EndPrepSDKCall();
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
public PrintZuoLaoStatus()
{
	//CPrintToChatAll("{green}[{lightgreen}!{green}] {default}坐牢等级 \x0B> {olive}%d", g_sZuoLaoLevel);
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoHeadShotHpLv)) CPrintToChatAll("{default}经过短暂的坐牢旅途, 你明白了必须无时不刻都要准备状态\n{green}现在击杀僵尸将会回复HP!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoRegHp40Lv)) CPrintToChatAll("{default}经过一次又一次的坐牢, 你明白必须要让自己不能拖累团队\n{green}现在HP低于40将会缓慢恢复!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoGivePillLv)) CPrintToChatAll("{default}出于对坐牢的恐惧, 你做足了准备\n{green}现在开局将会给药!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoGiveVomitLv)) CPrintToChatAll("{default}出于对坐牢的恐惧, 你做足了准备\n{green}现在开局将会给胆汁!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZuoLaoRegHp100Lv)) CPrintToChatAll("{default}一次又一次的坐牢使你麻木不堪, 你已不想再继续坐牢了\n{green}现在HP回复的速度更快更多!");
	if (g_sZuoLaoLevel == GetConVarInt(g_iZupLaoRegMoreFast)) CPrintToChatAll("{default}你已经麻辣！\n{green}现在HP每次回复 %d 点hp!", g_sZuoLaoLevel);
	if (g_sZuoLaoLevel == GetConVarInt(g_iZlIgnoreIncapHurt)) CPrintToChatAll("{default}你在倒地时想起自己推过的gal，充满了力量！\n{green}现在倒地<100hp会继续回血了!", g_sZuoLaoLevel);
	if (g_sZuoLaoLevel == GetConVarInt(g_iZlRespawnFirstDied)) CPrintToChatAll("{default}你在去世时想起了三司绫濑，你觉着你不能这么死去！\n{green}现在第一个死的倒霉蛋会在60s后复活...一般是第一个", g_sZuoLaoLevel);

}

// 检测是否坐牢
public Is_FuckZuolao()
{
	g_sZuoLaoLevel = (g_sRestartCount / GetConVarInt(g_iZuoLaoLv)) - 1 + GetConVarInt(g_iZuoLaoStart)
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
	KillTimer(respawntimer);
	healtimer = INVALID_HANDLE;
	respawntimer = INVALID_HANDLE;
	g_respawntarget = 0;
}

public Action PlayerDeath_Event(Event event, const String:name[], bool:dontBroadcast){
	//if (event.GetBool("headshot") == false) return;
	int client = GetClientOfUserId(event.GetInt("attacker"));
	if (GetClientTeam(client)==L4D_TEAM_SURVIVOR){ 
		int health = GetPlayerHealth(client);
		if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoHeadShotHpLv)){
			if (health < 100) SetPlayerHealth(client, health + 1);
		}
	}

	// 死亡复活
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (GetClientTeam(victim) == L4D_TEAM_SURVIVOR && g_respawnused == false && g_sZuoLaoLevel >= GetConVarInt(g_iZlRespawnFirstDied)){
		if (g_respawnused == false){
		CPrintToChatAll("{default}[{green}!{default}] 有人开始打复活赛喽");}
		g_respawntarget = victim;
		respawntimer = CreateTimer(60.0, Timer_Respawn, _,TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action PlayerHure_Event(Event event, const String:name[], bool:dontBroadcast){
	int player = GetClientOfUserId(event.GetInt("userid"))
	if (IsClientInGame(player) && GetClientTeam(player)==L4D_TEAM_SURVIVOR){
		if (!IsIncapacitated(player))
		{
			g_SafeCountTime[player] = GetConVarInt(g_iHealingCooldownTime);
		}
		else if (g_sZuoLaoLevel >= GetConVarInt(g_iZlIgnoreIncapHurt))
		{
			g_SafeCountTime[player] = 0;
		}

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
// https://forums.alliedmods.net/showthread.php?p=862618
static RespawnPlayer(client, player_id)
{
	switch(GetClientTeam(player_id))
	{
		case 2:
		{
			new bool:canTeleport = SetTeleportEndPoint(client);
		
			SDKCall(hRoundRespawn, player_id);
			
			CheatCommand(player_id, "give", "first_aid_kit");
			CheatCommand(player_id, "give", "smg");
			
			if(canTeleport)
			{
				PerformTeleport(client,player_id,g_pos);
			}
		}
		
		case 3:
		{
			decl String:game_name[24];
			GetGameFolderName(game_name, sizeof(game_name));
			if (StrEqual(game_name, "left4dead", false)) return;
		
			SDKCall(hState_Transition, player_id, 8);
			SDKCall(hBecomeGhost, player_id, 1);
			SDKCall(hState_Transition, player_id, 6);
			SDKCall(hBecomeGhost, player_id, 1);
		}
	}
}
public int GetPlayerHealth(int player){
	return GetSurvivorPermanentHealth(player);
}
public int GetPlayerTempHealth(int player){
	return GetSurvivorTemporaryHealth(player)
}

public void SetPlayerHealth(int player, int health){
	if (health >= 100) health=100;
	new h2;
	h2 = GetPlayerTempHealth(player);
	if(h2 + health < 100){
		SetEntityHealth(player, health);
	}
	else{
		SetEntityHealth(player, 100-h2);
	}
}
// 30s后复活
public Action Timer_Respawn(Handle Timer){
	for (new i=1;i<MaxClients;i++){
		if (IsClientInGame(i) && GetClientTeam(i) == L4D2Team_Survivor && IsPlayerAlive(i) && !g_respawnused && !IsPlayerAlive(g_respawntarget)){
			RespawnPlayer(i, g_respawntarget)
			if (g_respawnused == false){
			CPrintToChatAll("{default}[{green}!{default}] 有人复活赛打赢了，我不说是谁");}
			g_respawntarget = 0
			g_respawnused = true
			break
		}
	}
	
}
// 呼吸回血
public Action Timer_Re_Health(Handle Timer){

	if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoRegHp40Lv)){
		for (new p = 1; p <= MaxClients; p++){
			if (IsClientInGame(p) && GetClientTeam(p)==2){
				if (g_SafeCountTime[p] > 0){
					g_SafeCountTime[p] = g_SafeCountTime[p] - 1
					continue
				}
				int health = GetPlayerHealth(p);
				if (health < 40){
					SetPlayerHealth(p, health + 1);
				}
				if(health < 100 && g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoRegHp100Lv)){
					SetPlayerHealth(p, health + 4);
				}
				if(health < 100 && g_sZuoLaoLevel >= GetConVarInt(g_iZupLaoRegMoreFast)){
					SetPlayerHealth(p, health + g_sZuoLaoLevel);
				}
			}
		}
	}

	return Plugin_Continue;
}
// 开局给药
public Action RoundStart_Event(Event event, const String:name[], bool:dontBroadcast){
	// TIMER
	healtimer = CreateTimer(2.0, Timer_Re_Health, _,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	GivePill();
	GiveVomitjar();
	PrintZuoLaoStatus();
	g_respawnused = false
}

public GivePill(){
	if (g_sZuoLaoLevel >= GetConVarInt(g_iZuoLaoGivePillLv)){
		int count = 0
		new flags = GetCommandFlags("give");	
		SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i)==2)
			{
				FakeClientCommand(i, "give pain_pills");
				count++;
			}
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
			if (IsClientInGame(i) && GetClientTeam(i)==2)
			{
				FakeClientCommand(i, "give vomitjar");
				count++
			}
			if (count==GetConVarInt(g_iZLGiveVomitCount)) break;
		}
		SetCommandFlags("give", flags|FCVAR_CHEAT);
	}
}
stock CheatCommand(client, String:command[], String:arguments[]="")
{
	new userflags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}
public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
} 
static bool:SetTeleportEndPoint(client)
{
	decl Float:vAngles[3], Float:vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	//get endpoint for teleport
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(trace))
	{
		decl Float:vBuffer[3], Float:vStart[3];

		TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		new Float:Distance = -35.0;
		GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		PrintToChat(client, "[SM] %s", "Could not teleport player after respawn");
		CloseHandle(trace);
		return false;
	}
	CloseHandle(trace);
	return true;
}


PerformTeleport(client, target, Float:pos[3])
{
	pos[2]+=40.0;
	TeleportEntity(target, pos, NULL_VECTOR, NULL_VECTOR);
	
	LogAction(client,target, "\"%L\" teleported \"%L\" after respawning him" , client, target);
}