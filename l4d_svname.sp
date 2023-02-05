#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <readyup>


bool isFirstRound,isLive;

char g_sDefultName[128];
char g_sNewName[128];
char g_sConfigName[32];
new Handle:g_hHostName = INVALID_HANDLE;

ConVar getConfigName;
public Plugin:myinfo =
{
	name = "Hostname change",
	description = "服务器中文名字",
	author = "Mengsk",
	version = "0.2",
	url = ""
}

public void OnPluginStart()
{											//此处改为你的服务器名
	Format(g_sDefultName, sizeof(g_sDefultName), "二次元差不多得了");
    Format(g_sNewName, sizeof(g_sNewName), g_sDefultName);
	g_hHostName = FindConVar("hostname");

    HookEvent("round_end", RoundEnd_Event, EventHookMode_Pre);
    HookEvent("player_disconnect", PlayerDisconnect_Event, EventHookMode_Pre);
	HookEvent("player_connect", PlayerConnect_Event, EventHookMode_Pre);
	HostNameChange();
}

public OnMapStart()
{
	isFirstRound = true;
	HostNameChange();
}

public Action PlayerConnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	HostNameChange();
}

public Action PlayerDisconnect_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
    HostNameChange();
}

public Action RoundEnd_Event(Event event, const char[] name, bool dontBroadcast)
{
	isFirstRound = false;
    HostNameChange();
}

public void OnRoundIsLive()
{
	isLive = true;
	HostNameChange();
}

public void OnReadyUpInitiate()
{
	isLive = false;
	HostNameChange();
}

public void OnConfigsExecuted()
{
	GetFileHostname();
}
stock int GetSeriousClientCount(bool inGame = false)
{
	int clients = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (inGame)
		{
			if (IsClientInGame(i) && !IsFakeClient(i)) clients++;
		}
		else
		{
			if (IsClientConnected(i) && !IsFakeClient(i)) clients++;
		}
	}
	
	return clients;
}
void GetFileHostname()
{
	char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath),"configs/hostname/server_hostname.txt");//檔案路徑設定

	Handle file = OpenFile(sPath, "r");//讀取檔案
    if(file == INVALID_HANDLE)
	{
		LogMessage("file configs/hostname/server_hostname.txt doesn't exist!");
		return;
	}

	char readData[256];
    if(!IsEndOfFile(file) && ReadFileLine(file, readData, sizeof(readData)))//讀一行
    {
		Format(g_sDefultName, sizeof(g_sDefultName), "%s", readData);
	}
}

HostNameChange()
{
    getConfigName = FindConVar("l4d_ready_cfg_name");
	int iGameMode = L4D_GetGameModeType()
	if(getConfigName != null)
	{
        getConfigName.GetString(g_sConfigName, sizeof(g_sConfigName));
		if(L4D_GetGameModeType() & (GAMEMODE_VERSUS))
		{
			if(GetSeriousClientCount() == 0)
			{
                Format(g_sNewName, sizeof(g_sNewName), "[闲置] %s", g_sDefultName);
				SetConVarString(g_hHostName, g_sNewName, false, false);
				return
			}
			if(g_sConfigName[0] != '\0')
			{
			    Format(g_sNewName, sizeof(g_sNewName), "[%s] %s - %d:%d R#%s-%s",
			    g_sConfigName, 
				g_sDefultName, 
				L4D2Direct_GetVSCampaignScore(L4D2_AreTeamsFlipped()),
				L4D2Direct_GetVSCampaignScore(!L4D2_AreTeamsFlipped()),
                (isFirstRound) ? "1" : "2",
				(isLive) ? "Live" : "Unready"
				);
			}		
		}
		else
		{
			Format(g_sNewName, sizeof(g_sNewName), "[摸鱼中] %s", g_sDefultName);
		}
	}
	else
	{
		Format(g_sNewName, sizeof(g_sNewName), "[闲置] %s", g_sDefultName);
	}
	SetConVarString(g_hHostName, g_sNewName, false, false);
}