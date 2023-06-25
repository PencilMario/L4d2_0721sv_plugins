#include <sourcemod>
#include <sdktools>
#include <multicolors>

bool isFirstRound,isLive;

char g_sDefultName[128];
char g_sNewName[128];
char g_sConfigName[32];
new Handle:g_hHostName = INVALID_HANDLE;

int g_sRestartCount;

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
    Format(g_sDefultName, sizeof(g_sDefultName), "[CN]私の0721を見てけダサい");
    Format(g_sNewName, sizeof(g_sNewName), g_sDefultName);
    g_hHostName = FindConVar("hostname");
    g_sRestartCount = 0;
    HookEvent("round_end", RoundEnd_Event, EventHookMode_Pre);
    HookEvent("player_disconnect", PlayerDisconnect_Event, EventHookMode_Pre);
    HookEvent("player_connect", PlayerConnect_Event, EventHookMode_Pre);
    HostNameChange();
    RegConsoleCmd("sm_recount", Call_PrintRestartCount, "输出失败的次数");
}

public OnMapStart()
{
    g_sRestartCount = 0;
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
    CreateTimer(4.0, PrintRestartCount)
}


public void OnConfigsExecuted()
{
    GetFileHostname();
}

public Action PrintRestartCount(Handle timer)
{
    CPrintToChatAll("{green}[{lightgreen}!{green}] {default}团灭次数 \x0B> {default}{olive}%d{default}.", g_sRestartCount);
}

public Action Call_PrintRestartCount(int client, int args)
{
    CPrintToChatAll("{green}[{lightgreen}!{green}] {default}团灭次数 \x0B> {default}{olive}%d{default}.", g_sRestartCount);
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
    // [绝境18特]你也来坐牢啊 - 重启:0
    Format(g_sNewName, sizeof(g_sNewName), "%s - 重启%d", g_sDefultName, g_sRestartCount);
    SetConVarString(g_hHostName, g_sNewName, false, false);		
}
