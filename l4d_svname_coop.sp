#include <sourcemod>
#include <l4d2util>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

bool isFirstRound,isLive;

char g_sDefultName[128];
char g_sNewName[128];
char g_sConfigName[32];
new Handle:g_hHostName = INVALID_HANDLE;

int g_sRestartCount = 0;

ConVar getConfigName;
public Plugin:myinfo =
{
	name = "动态服务器名称",
	description = "SP的绝境动态服名",
	author = "SirP",
	version = "0.2",
	url = ""
}

public void OnPluginStart()
{
	Format(g_sDefultName, sizeof(g_sDefultName), "[绝境14特]不要再坐牢了辣");
    Format(g_sNewName, sizeof(g_sNewName), g_sDefultName);
	g_hHostName = FindConVar("hostname");

    HookEvent("round_end", RoundEnd_Event, EventHookMode_Pre);
    HookEvent("player_disconnect", PlayerDisconnect_Event, EventHookMode_Pre);
	HookEvent("player_connect", PlayerConnect_Event, EventHookMode_Pre);
	HostNameChange();
}

public OnMapStart()
{
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
	g_sRestartCount++;
    HostNameChange();
	CPrintToChat("{green}[{red}!{green}] {lightgreen}重启次数 -{default}{olive}%u{default}.", g_sRestartCount);
}


public void OnConfigsExecuted()
{
	GetFileHostname();
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
	int iGameMode = L4D_GetGameModeType()
	// [绝境18特]你也来坐牢啊 - 重启:0
    Format(g_sNewName, sizeof(g_sNewName), "%s - 重启:%s", g_sDefultName, g_sRestartCount);
	SetConVarString(g_hHostName, g_sNewName, false, false);		

	//SetConVarString(g_hHostName, g_sNewName, false, false);
}