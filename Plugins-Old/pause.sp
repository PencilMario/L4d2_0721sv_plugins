/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <colors>
#include <builtinvotes>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util>
#undef REQUIRE_PLUGIN
#include <readyup>

public Plugin myinfo =
{
	name = "Pause plugin",
	author = "CanadaRox, Sir, Forgetest",
	description = "Adds pause functionality without breaking pauses, also prevents SI from spawning because of the Pause.",
	version = "6.6",
	url = "https://github.com/SirPlease/L4D2-Competitive-Rework"
};

// Game ConVar
ConVar
	sv_pausable,
	sv_noclipduringpause;

// Plugin Forwards
Handle
	pauseForward,
	unpauseForward;

// Plugin ConVar
ConVar
	pauseDelayCvar,
	initiatorReadyCvar,
	l4d_ready_delay,
	pauseLimitCvar,
	serverNamerCvar;

// Pause Handle
Handle
	readyCountdownTimer,
	deferredPauseTimer,
	attackingPauseTimer;
int
	readyDelay,
	pauseDelay;
bool
	isPaused,
	RoundEnd,
	isCedapug,
	listened;

// Pause Info
int
	initiatorId,
	maxPauseTime;
bool
	adminPause,
	teamReady[L4D2Team_Size],
	initiatorReady;
char
	initiatorName[MAX_NAME_LENGTH];
float
	pauseTime;
int
	pauseTeam;

// Pause Panel
bool hiddenPanel[MAXPLAYERS+1];

// Ready Up Available
bool readyUpIsAvailable;

// Pause Fix
Handle SpecTimer[MAXPLAYERS+1];

StringMap playerPauseCount;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("IsInPause", Native_IsInPause);
	pauseForward = CreateGlobalForward("OnPause", ET_Ignore);
	unpauseForward = CreateGlobalForward("OnUnpause", ET_Ignore);

	RegPluginLibrary("pause");
	return APLRes_Success;
}

public void OnPluginStart()
{
	pauseDelayCvar = CreateConVar("sm_pausedelay", "0", "Delay to apply before a pause happens.  Could be used to prevent Tactical Pauses", FCVAR_NONE, true, 0.0);
	initiatorReadyCvar = CreateConVar("sm_initiatorready", "1", "Require or not the pause initiator should ready before unpausing the game", FCVAR_NONE, true, 0.0);
	pauseLimitCvar = CreateConVar("sm_pauselimit", "1", "Limits the amount of pauses a player can do in a single game.", FCVAR_NONE, true, 0.0);
	l4d_ready_delay = FindConVar("l4d_ready_delay");
	
	playerPauseCount = new StringMap();

	FindServerNamer();
	
	sv_pausable = FindConVar("sv_pausable");
	sv_noclipduringpause = FindConVar("sv_noclipduringpause");

	RegConsoleCmd("sm_spectate", Spectate_Cmd, "Moves you to the spectator team");
	RegConsoleCmd("sm_spec", Spectate_Cmd, "Moves you to the spectator team");
	RegConsoleCmd("sm_s", Spectate_Cmd, "Moves you to the spectator team");
	
	RegConsoleCmd("sm_pause", Pause_Cmd, "Pauses the game");
	RegConsoleCmd("sm_unpause", Unpause_Cmd, "Marks your team as ready for an unpause");
	RegConsoleCmd("sm_ready", Unpause_Cmd, "Marks your team as ready for an unpause");
	RegConsoleCmd("sm_unready", Unready_Cmd, "Marks your team as ready for an unpause");
	RegConsoleCmd("sm_toggleready", ToggleReady_Cmd, "Toggles your team's ready status");
	
	RegAdminCmd("sm_forcepause", ForcePause_Cmd, ADMFLAG_BAN, "Pauses the game and only allows admins to unpause");
	RegAdminCmd("sm_forceunpause", ForceUnpause_Cmd, ADMFLAG_BAN, "Unpauses the game regardless of team ready status.  Must be used to unpause admin pauses");

	RegConsoleCmd("sm_show", Show_Cmd, "Hides the pause panel so other menus can be seen");
	RegConsoleCmd("sm_hide", Hide_Cmd, "Shows a hidden pause panel");

	HookEvent("round_end", RoundEnd_Event, EventHookMode_PostNoCopy);
	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
}

// ======================================
// Readyup Available
// ======================================

public void OnAllPluginsLoaded() { readyUpIsAvailable = LibraryExists("readyup"); FindServerNamer(); }
public void OnLibraryAdded(const char[] name) { if (StrEqual(name, "readyup")) readyUpIsAvailable = true; FindServerNamer(); }
public void OnLibraryRemoved(const char[] name) { if (StrEqual(name, "readyup")) readyUpIsAvailable = false; FindServerNamer(); }

// ======================================
// Custom Server Namer
// ======================================

void FindServerNamer()
{
	if ((serverNamerCvar = FindConVar("l4d_ready_server_cvar")) != null)
	{
		char buffer[128];
		serverNamerCvar.GetString(buffer, sizeof buffer);
		serverNamerCvar = FindConVar(buffer);
	}
	
	if (serverNamerCvar == null)
	{
		serverNamerCvar = FindConVar("hostname");
	}
}

// ======================================
// Forwards
// ======================================

public void OnCedapugStarted(int regionArg)
{
	isCedapug = true;
}

public void OnClientPutInServer(int client)
{
	if (isPaused)
	{
		if (!IsFakeClient(client))
		{
			CPrintToChatAll("{default}[{green}!{default}] {olive}%N {default}加载完成", client);
		}
	}
}

public void OnClientDisconnect_Post(int client)
{
	if (isPaused && !adminPause && CheckFullReady())
	{
		InitiateLiveCountdown();
	}

	hiddenPanel[client] = false;
}

public void OnMapEnd()
{
	RoundEnd = true;
	Unpause(false);
}

public void RoundEnd_Event(Event event, const char[] name, bool dontBroadcast)
{
	if (deferredPauseTimer != null)
	{
		delete deferredPauseTimer;
	}
	if (attackingPauseTimer != null)
	{
		delete deferredPauseTimer;
	}
	RoundEnd = true;
	Unpause(false);
}

public void RoundStart_Event(Event event, const char[] name, bool dontBroadcast)
{
	RoundEnd = false;
	initiatorId = 0;
}

// ======================================
// Commands
// ======================================

public Action Pause_Cmd(int client, int args)
{
	if (readyUpIsAvailable && IsInReady())
		return Plugin_Continue;
	
	if (!IsPlayer(client))
		return Plugin_Continue;
		
	if (RoundEnd)
		return Plugin_Continue;

	if (pauseDelay == 0 && !isPaused)
	{
		if (isCedapug && !AddPauseCount(client))
			return Plugin_Continue;

		initiatorId = GetClientUserId(client);
		pauseTeam = GetClientTeam(client);
		GetClientName(client, initiatorName, sizeof(initiatorName));
		
		CPrintToChatAll("{default}[{green}!{default}] {olive}%N {blue}暂停了{default}.", client);
		
		pauseDelay = pauseDelayCvar.IntValue;
		if (pauseDelay == 0)
		{
			AttemptPause();
		}
		else
		{
			CreateTimer(1.0, PauseDelay_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	return Plugin_Handled;
}

public Action PauseDelay_Timer(Handle timer)
{
	if (pauseDelay == 0)
	{
		CPrintToChatAll("{default}[{green}!{default}] {red}暂停了");
		AttemptPause();
		return Plugin_Stop;
	}
	else
	{
		CPrintToChatAll("{default}[{green}!{default}] {blue}即将暂停{default}: {olive}%d", pauseDelay);
		pauseDelay--;
	}
	return Plugin_Continue;
}

public Action ForcePause_Cmd(int client, int args)
{
	if (!isPaused)
	{
		adminPause = true;
		if (client == 0){
			ConVar host = FindConVar("hostname")
			GetConVarString(host, initiatorName, sizeof(initiatorName))
			initiatorId = 0;
		}else{
			initiatorId = GetClientUserId(client);
			GetClientName(client, initiatorName, sizeof(initiatorName));
		}
		CPrintToChatAll("{default}[{green}!{default}] {blue}管理员{default}发起了{green}强制暂停{default}({olive}%s{default})", initiatorName);
		Pause();
	}

	return Plugin_Handled;
}

public Action Unpause_Cmd(int client, int args)
{
	if (isPaused && IsPlayer(client))
	{
		int clientTeam = GetClientTeam(client);
		int initiator = GetClientOfUserId(initiatorId);
		if (!teamReady[clientTeam])
		{
			switch (clientTeam)
			{
				case L4D2Team_Survivor:
				{
					CPrintToChatAll("{default}[{green}!{default}] {olive}%N %s{default}表示 {blue}%s {default}准备完毕.", client, (initiatorReady && client == initiator) ? "{default}作为{green}发起者 " : "", L4D2_TeamName[clientTeam]);
				}
				case L4D2Team_Infected:
				{
					CPrintToChatAll("{default}[{green}!{default}] {olive}%N %s{default}表示 {red}%s {default}准备完毕.", client, (initiatorReady && client == initiator) ? "{default}作为 {green}发起者 " : "", L4D2_TeamName[clientTeam]);					
				}
			}
		}
		if (initiatorReadyCvar.BoolValue)
		{
			if (client == initiator && !initiatorReady)
			{
				initiatorReady = true;
				if (teamReady[clientTeam])
				{
					CPrintToChatAll("{default}[{green}!{default}] {olive}%N {default}表示 {green}发起者 {default}准备完毕.", client);
				}
			}
		}
		teamReady[clientTeam] = true;
		if (CheckFullReady())
		{
			if (!adminPause)
			{
				InitiateLiveCountdown();
			}
			else
			{
				CPrintToChatAll("{default}[{green}!{default}] {olive}所有队伍{default}准备完毕. 请等待{blue}管理员{default}进行{green}确认{default}.");
			}
		}
	}

	return Plugin_Handled;
}

public Action Unready_Cmd(int client, int args)
{
	if (isPaused && IsPlayer(client))
	{
		int initiator = GetClientOfUserId(initiatorId);
		int clientTeam = GetClientTeam(client);
		if (teamReady[clientTeam])
		{
			switch (clientTeam)
			{
				case L4D2Team_Survivor:
				{
					CPrintToChatAll("{default}[{green}!{default}] {olive}%N %s{default}表示 {blue}%s {default}未准备好.", client, (initiatorReady && client == initiator) ? "{default}作为 {green}发起者 " : "", L4D2_TeamName[clientTeam]);
				}
				case L4D2Team_Infected:
				{
					CPrintToChatAll("{default}[{green}!{default}] {olive}%N %s{default}表示 {red}%s {default}未准备好", client, (initiatorReady && client == initiator) ? "{default}作为 {green}发起者 " : "", L4D2_TeamName[clientTeam]);
				}
			}
		}
		if (initiatorReadyCvar.BoolValue)
		{
			if (client == initiator && initiatorReady)
			{
				initiatorReady = false;
				if (!teamReady[clientTeam])
				{
					CPrintToChatAll("{default}[{green}!{default}] {olive}%N {default}表示 {green}发起者 {default}未准备好", client);
				}
			}
		}
		teamReady[clientTeam] = false;
		
		if (!adminPause)
		{
			CancelFullReady(client);
		}
	}

	return Plugin_Handled;
}

public Action ForceUnpause_Cmd(int client, int args)
{
	if (isPaused)
	{
		adminPause = true;
		if (client != 0){
			CPrintToChatAll("{default}[{green}!{default}] {blue}管理员{default}({olive}%N{default})强制{green}取消暂停", client);
		}
		else{
			char Svname[64];
			GetConVarString(FindConVar("hostname"), Svname, sizeof(Svname));
			CPrintToChatAll("{default}[{green}!{default}] {blue}管理员{default}({olive}%s{default})强制{green}取消暂停", Svname);
		}
		InitiateLiveCountdown();
	}

	return Plugin_Handled;
}

public Action ToggleReady_Cmd(int client, int args)
{
	int clientTeam = GetClientTeam(client);
	teamReady[clientTeam] ? Unready_Cmd(client, 0) : Unpause_Cmd(client, 0);

	return Plugin_Handled;
}

// ======================================
// Pause Process
// ======================================

bool AddPauseCount(int client)
{
	char authId[18];
	GetClientAuthId(client, AuthId_SteamID64, authId, 18, false);
	int pauseCount = 0;
	playerPauseCount.GetValue(authId, pauseCount);

	if (pauseCount >= pauseLimitCvar.IntValue)
	{
		CPrintToChat(client, "{blue}[{green}!{blue}] {default}你已耗尽暂停次数!");
		return false;
	}

	pauseCount++;
	playerPauseCount.SetValue(authId, pauseCount);

	return true;
}

void AttemptPause()
{
	if (deferredPauseTimer == null)
	{
		if (IsSurvivorReviving())
		{
			CPrintToChatAll("{default}[{green}!{default}] {red}暂停将推迟到扶人结束!");
			deferredPauseTimer = CreateTimer(0.1, DeferredPause_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			
		}
		else if (IsAnyInfectedSpawned())
		{
			maxPauseTime = 160;
			CPrintToChatAll("{default}[{green}!{default}] {red}暂停将推迟到没有正在进攻的特感/进攻超过16s!");
			attackingPauseTimer = CreateTimer(0.1, Timer_InfAttacking, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			Pause();
		}
	}
}
public bool IsAnyInfectedSpawned()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsInfected(i))
		{
			if(!IsInfectedGhost(i)) //特感为复活状态
			{
				if (!IsPlayerAlive(i))
				{
					continue;
				}
				if (GetInfectedClass(i) == L4D2Infected_Tank) //不是tank
				{
					continue;
				}
				return true;
			}
		}
	}
	return false;
}
public Action Timer_InfAttacking(Handle timer)
{
	if(IsAnyInfectedSpawned() && maxPauseTime>0)
	{
		maxPauseTime--;
		return Plugin_Continue;
	}
	else
	{
		attackingPauseTimer = null;
		Pause();
		return Plugin_Stop;
	}
	
}
public Action DeferredPause_Timer(Handle timer)
{
	if (!IsSurvivorReviving())
	{
		deferredPauseTimer = null;
		Pause();
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

void Pause()
{
	for (int team; team < L4D2Team_Size; team++)
	{
		teamReady[team] = false;
	}
	
	initiatorReady = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		hiddenPanel[i] = false;
	}

	isPaused = true;
	pauseTime = GetEngineTime();
	readyCountdownTimer = null;
	
	ToggleCommandListeners(true);
	
	CreateTimer(1.0, MenuRefresh_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	bool pauseProcessed = false;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			int team = GetClientTeam(client);
			
			if (team == L4D2Team_Infected && IsInfectedGhost(client))
			{
				SetEntProp(client, Prop_Send, "m_hasVisibleThreats", 1);
				int buttons = GetClientButtons(client);
				if (buttons & IN_ATTACK)
				{
					buttons &= ~IN_ATTACK;
					SetClientButtons(client, buttons);
					CPrintToChat(client, "{default}[{green}!{default}] {default}你的{red}复活{default}因为暂停被阻止了");
				}
			}
			
			if (!pauseProcessed)
			{
				sv_pausable.BoolValue = true;
				FakeClientCommand(client, "pause");
				sv_pausable.BoolValue = false;
				pauseProcessed = true;
			}
			
			if (team == L4D2Team_Spectator)
			{
				sv_noclipduringpause.ReplicateToClient(client, "1");
			}
		}
	}
	
	Call_StartForward(pauseForward);
	Call_Finish();
}

void Unpause(bool real = true)
{
	isPaused = false;
	adminPause = false;
	
	ToggleCommandListeners(false);

	pauseTeam = L4D2Team_None;
	initiatorId = 0;
	initiatorReady = false;
	initiatorName = "";
	
	readyCountdownTimer = null;
	
	if (real)
	{
		bool unpauseProcessed = false;
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && !IsFakeClient(client))
			{
				if(!unpauseProcessed)
				{
					sv_pausable.BoolValue = true;
					FakeClientCommand(client, "unpause");
					sv_pausable.BoolValue = false;
					unpauseProcessed = true;
				}
				
				if (GetClientTeam(client) == L4D2Team_Spectator)
				{
					sv_noclipduringpause.ReplicateToClient(client, "0");
				}
			}
		}
		
		Call_StartForward(unpauseForward);
		Call_Finish();
	}
}

// ======================================
// Pause Panel
// ======================================

public Action Show_Cmd(int client, int args)
{
	if (isPaused)
	{
		hiddenPanel[client] = false;
		CPrintToChat(client, "[{olive}Pause{default}] 面板已{blue}打开{default}.");
	}

	return Plugin_Handled;
}

public Action Hide_Cmd(int client, int args)
{
	if (isPaused)
	{
		hiddenPanel[client] = true;
		CPrintToChat(client, "[{olive}Pause{default}] 面板已{red}关闭{default}.");
	}

	return Plugin_Handled;
}

public Action MenuRefresh_Timer(Handle timer)
{
	if (isPaused)
	{
		UpdatePanel();
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public int DummyHandler(Menu menu, MenuAction action, int param1, int param2) { return 1; }

void UpdatePanel()
{
	Panel menuPanel = new Panel();
	
	char info[512];
	serverNamerCvar.GetString(info, sizeof(info));
	
	Format(info, sizeof(info), "♞<[%s] - [%d/%d] - %s>", info, GetSeriousClientCount(), FindConVar("sv_maxplayers").IntValue, adminPause ? "**强制暂停**":"**玩家发起的暂停**");
	menuPanel.DrawText(info);
	
	FormatTime(info, sizeof(info), "♞<%m/%d/%Y - %I:%M%p>");
	menuPanel.DrawText(info);
	
	menuPanel.DrawText(" ");
	menuPanel.DrawText("♞<--准备状态-->");

	if (adminPause)
	{
		menuPanel.DrawText("<!!需要管理员解除暂停!!>");
		menuPanel.DrawText(teamReady[L4D2Team_Survivor] ? "->1. 生还者: ★" : "->1. 生还者: ☆");
		menuPanel.DrawText(teamReady[L4D2Team_Infected] ? "->2. 感染者: ★" : "->2. 感染者: ☆");
	}
	else if (initiatorReadyCvar.BoolValue)
	{
		menuPanel.DrawText(initiatorReady ? "->1. 发起者: ★" : "->1. 发起者: ☆");
		menuPanel.DrawText(teamReady[L4D2Team_Survivor] ? "->2. 生还者: ★" : "->2. 生还者: ☆");
		menuPanel.DrawText(teamReady[L4D2Team_Infected] ? "->3. 感染者: ★" : "->3. 感染者: ☆");
	} 
	else
	{
		menuPanel.DrawText(teamReady[L4D2Team_Survivor] ? "->1. 生还者: ★" : "->1. 生还者: ☆");
		menuPanel.DrawText(teamReady[L4D2Team_Infected] ? "->2. 感染者: ★" : "->2. 感染者: ☆");
	}

	menuPanel.DrawText(" ");
	
	char name[MAX_NAME_LENGTH];

	int initiator = GetClientOfUserId(initiatorId);
	if (initiator > 0)
	{
		GetClientName(initiator, name, sizeof(name));
	}

	if (adminPause)
	{
		Format(info, sizeof(info), "♞<--%s (Admin)发起了强制暂停-->", strlen(name) ? name : initiatorName);
	}
	else
	{
		Format(info, sizeof(info), "♞<--暂停发起者: %s (%s)-->", strlen(name) ? name : initiatorName, L4D2_TeamName[pauseTeam]);
	}
	
	menuPanel.DrawText(info);
		
	int duration = RoundToNearest(GetEngineTime() - pauseTime);
	FormatEx(info, sizeof(info), "♞<暂停时间: %02d:%02d>", duration / 60, duration % 60);
	menuPanel.DrawText(info);
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && !hiddenPanel[client])
		{
			if (!BuiltinVote_IsVoteInProgress() || !IsClientInBuiltinVotePool(client))
			{
				menuPanel.Send(client, DummyHandler, 1);
			}
		}
	}
	
	delete menuPanel;
}

// ======================================
// Unpause Process
// ======================================

void InitiateLiveCountdown()
{
	if (readyCountdownTimer == null)
	{
		CPrintToChatAll("{default}[{green}!{default}] 在聊天栏输入 {olive}!unready {default}取消");
		readyDelay = l4d_ready_delay.IntValue;
		readyCountdownTimer = CreateTimer(1.0, ReadyCountdownDelay_Timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action ReadyCountdownDelay_Timer(Handle timer)
{
	if (readyDelay == 0)
	{
		Unpause();
		PrintHintTextToAll("游戏继续!");
		return Plugin_Stop;
	}
	else
	{
		CPrintToChatAll("{default}[{green}!{default}] {blue}准备开始{default}: {olive}%d{default}...", readyDelay);
		readyDelay--;
	}
	return Plugin_Continue;
}

bool CheckFullReady()
{
	int InitiatorClient = GetClientOfUserId(initiatorId);

	return (teamReady[L4D2Team_Survivor] || GetTeamHumanCount(L4D2Team_Survivor) == 0)
		&& (teamReady[L4D2Team_Infected] || GetTeamHumanCount(L4D2Team_Infected) == 0)
		&& (!initiatorReadyCvar.BoolValue || initiatorReady || !IsPlayer(InitiatorClient));
}

void CancelFullReady(int client)
{
	if (readyCountdownTimer != null && !adminPause)
	{
		delete readyCountdownTimer;
		CPrintToChatAll("{default}[{green}!{default}] {olive}%N {default}取消了倒计时!", client);
	}
}

// ======================================
// Spectate Fix
// ======================================

public Action Spectate_Cmd(int client, int args)
{
	if (SpecTimer[client] != null)
	{
		delete SpecTimer[client];
	}
	
	SpecTimer[client] = CreateTimer(3.0, SecureSpec, client);

	return Plugin_Handled;
}

public Action SecureSpec(Handle timer, any client)
{
	SpecTimer[client] = null;
	return Plugin_Stop;
}

// ======================================
// Command Listeners
// ======================================

void ToggleCommandListeners(bool enable)
{
	if (enable && !listened)
	{
		AddCommandListener(Say_Callback, "say");
		AddCommandListener(TeamSay_Callback, "say_team");
		AddCommandListener(Unpause_Callback, "unpause");
		AddCommandListener(Callvote_Callback, "callvote");
		listened = true;
	}
	else if (!enable && listened)
	{
		RemoveCommandListener(Say_Callback, "say");
		RemoveCommandListener(TeamSay_Callback, "say_team");
		RemoveCommandListener(Unpause_Callback, "unpause");
		RemoveCommandListener(Callvote_Callback, "callvote");
		listened = false;
	}
}

public Action Callvote_Callback(int client, char[] command, int argc)
{
	if (GetClientTeam(client) == L4D2Team_Spectator)
	{
		CPrintToChat(client, "{blue}[{green}!{blue}] {default}旁观不允许投票.");
		return Plugin_Handled;
	}

	if (SpecTimer[client])
	{
		CPrintToChat(client, "{blue}[{green}!{blue}] {default}你刚刚换了队伍, 暂时无法投票.");
		return Plugin_Handled;
	}
	
	// kick vote from client, "callvote %s \"%d %s\"\n;"
	if (argc < 2)
	{
		return Plugin_Continue;
	}
	
	char votereason[16];
	GetCmdArg(1, votereason, 16);
	if (!!strcmp(votereason, "kick", false))
	{
		return Plugin_Continue;
	}
	
	char therest[256];
	GetCmdArg(2, therest, sizeof(therest));
	
	int userid;
	int spacepos = FindCharInString(therest, ' ', false);
	if (spacepos > -1)
	{
		char temp[12];
		strcopy(temp, L4D2Util_GetMin(spacepos + 1, sizeof(temp)), therest);
		userid = StringToInt(temp);
	}
	else
	{
		userid = StringToInt(therest);
	}
	
	int target = GetClientOfUserId(userid);
	if (target < 1)
	{
		return Plugin_Continue;
	}
	
	AdminId clientAdmin = GetUserAdmin(client);
	AdminId targetAdmin = GetUserAdmin(target);
	if (clientAdmin == INVALID_ADMIN_ID && targetAdmin == INVALID_ADMIN_ID)
	{
		return Plugin_Continue;
	}
	
	if (CanAdminTarget(clientAdmin, targetAdmin))
	{
		return Plugin_Continue;
	}
	
	CPrintToChat(client, "{blue}[{green}!{blue}] {default}你不能踢出管理员.", target);
	return Plugin_Handled;
}

public Action Say_Callback(int client, char[] command, int argc)
{
	if (isPaused)
	{
		char buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		StripQuotes(buffer);
		if (IsChatTrigger() || buffer[0] == '!' || buffer[0] == '/')  // Hidden command or chat trigger
		{
			return Plugin_Handled;
		}
		if (client == 0)
		{
			PrintToChatAll("Console : %s", buffer);
		}
		else
		{
			CPrintToChatAllEx(client, "{teamcolor}%N{default} : %s", client, buffer);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action TeamSay_Callback(int client, char[] command, int argc)
{
	if (isPaused)
	{
		char buffer[256];
		GetCmdArgString(buffer, sizeof(buffer));
		StripQuotes(buffer);
		if (IsChatTrigger() || buffer[0] == '!' || buffer[0] == '/')  // Hidden command or chat trigger
		{
			return Plugin_Handled;
		}
		PrintToTeam(client, GetClientTeam(client), buffer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Unpause_Callback(int client, char[] command, int argc)
{
	return (isPaused) ? Plugin_Handled : Plugin_Continue;
}

// ======================================
// Natives
// ======================================

public int Native_IsInPause(Handle plugin, int numParams)
{
	return isPaused;
}

// ======================================
// Helpers
// ======================================

stock bool IsPlayer(int client)
{
	if (!client) return false;
	
	int team = GetClientTeam(client);
	return !SpecTimer[client] && (team == L4D2Team_Survivor || team == L4D2Team_Infected);
}

stock void PrintToTeam(int author, int team, const char[] buffer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == team)
		{
			CPrintToChatEx(client, author, "(%s) {teamcolor}%N{default} :  %s", L4D2_TeamName[GetClientTeam(author)], author, buffer);
		}
	}
}

stock int GetSeriousClientCount()
{
	int clients = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && !IsFakeClient(i))
		{
			clients++;
		}
	}
	
	return clients;
}

stock int GetTeamHumanCount(int team)
{
	int humans = 0;
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == team)
		{
			humans++;
		}
	}
	
	return humans;
}

stock bool IsSurvivorReviving()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == L4D2Team_Survivor && IsPlayerAlive(client))
		{
			if (GetEntProp(client, Prop_Send, "m_reviveTarget") > 0)
			{
				return true;
			}
		}
	}
	return false;
}

stock void SetClientButtons(int client, int buttons)
{
	if (IsClientInGame(client))
	{
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}
