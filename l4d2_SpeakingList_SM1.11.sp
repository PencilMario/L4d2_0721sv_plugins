#pragma semicolon 1
#pragma newdecls required

#include <sdktools_voice>
#include <l4d2util>

public Plugin myinfo = 
{
	name = "[L4D2] Speaking List",
	author = "Sir.P (fork Accelerator (Fork by Dragokas, Grey83))",
	description = "Voice Announce. Print To Center Message who's Speaking",
	version = "1.4.4",
	url = "https://forums.alliedmods.net/showthread.php?t=339934"
}

/*
	ChangeLog:
	
	 * 1.4.1 (26-Jan-2020) (Dragokas)
	  - Client in game check fixed
	  - Code is simplified
	  - New syntax
	  
	 * 1.4.2 (23-Dec-2020) (Dragokas)
	  - Updated to use with SM 1.11
	  - Timer is increased 0.7 => 1.0
	  
	 * 1.4.4 (10-Oct-2022) (Grey83)
	  - Optimization: timer moved from OnPluginStart to OnMapStart.
	  - Optimization: max. buffer checks and caching.
*/

bool g_bSpeaking[MAXPLAYERS+1];
char g_sPlayers[PLATFORM_MAX_PATH];

public void OnMapStart()
{
    for( int i = 1; i <= MaxClients; i++ )
	{
		g_bSpeaking[i] = false;
	}
    CreateTimer(0.5, Timer_List, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientSpeaking(int client)
{
	g_bSpeaking[client] = true;
}

/*
public void OnClientSpeakingEnd(int client)
{
	g_bSpeaking[client] = false;
}
*/

public Action Timer_List(Handle timer)
{
	static int i, g;
	static bool show;
	char team[16];
	for( g = 1; g <= MaxClients; g++){
		for( int z = 1; i <= sizeof(g_sPlayers); i++ )
		{
			g_sPlayers[z] = 0;
		}
		show = false;
		if( !IsClientInGame(g) ) continue;
		for( i = 1; i <= MaxClients; i++ )
		{
			if( g_bSpeaking[i] )
			{
				g_bSpeaking[i] = false;
				if( !IsClientInGame(i) ) continue;
				if ( GetClientTeam(g) != L4D2Team_Spectator){
					if (GetClientTeam(g) != GetClientTeam(i)) continue;
				}
				if (GetClientTeam(i) == L4D2Team_Infected)
				{
					team = "(Inf.)";
				}
				else if ((GetClientTeam(i) == L4D2Team_Survivor))
				{
					team = "(Sur.)";
				}
				else if (GetClientTeam(i) == L4D2Team_Spectator)
				{
					team = "(Spec.)";
				}
				else
				{
					team = "(None)";
				}
				if( Format(g_sPlayers, sizeof(g_sPlayers), "%s\n%s%N", g_sPlayers, team, i) >= (sizeof(g_sPlayers) - 1) ) break;
				show = true;
			}
		}
		if( show )
		{
			Format(g_sPlayers, sizeof(g_sPlayers), "%s\n%s", "正在说话:", g_sPlayers);
			PrintCenterText(g, g_sPlayers);
		}
	}
	return Plugin_Continue;
}