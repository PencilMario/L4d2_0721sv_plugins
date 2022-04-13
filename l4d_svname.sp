#include <sourcemod>
#include <readyup>

char g_sDefultName[64];
char g_sNewName[64];
char g_sVersusConf[32];
new Handle:g_hHostName = INVALID_HANDLE;
ConVar g_getConfigName;
ConVar sp_DefaultName;
new Handle:g_sp_DefaultName = INVALID_HANDLE;
new Handle:g_sp_sendtoRdup = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "Hostname change",
	description = "服务器中文状态",
	author = "Mengsk Sorakoi",
	version = "0.2",
	url = ""
}

public void OnPluginStart()
{		
    g_sp_sendtoRdup = FindConVar("l4d_ready_server_cvar");
	sp_DefaultName = CreateConVar("sp_DefaultName", "", "服务器传给readyup的名称?", FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);
	g_sp_DefaultName = FindConVar("sp_DefaultName");
					
	Format(g_sDefultName, sizeof(g_sDefultName), "Rumbling #1");//此处为服务器名称
	SetConVarString(g_sp_DefaultName, g_sDefultName, false, false);
    Format(g_sNewName, sizeof(g_sNewName), g_sDefultName);
	g_hHostName = FindConVar("hostname");
	HookConVarChange(g_hHostName, OnConVarChange);
	HostNameChange();
}
public void OnRoundIsLive()
{
	g_getConfigName = FindConVar("l4d_ready_cfg_name");
	g_getConfigName.GetString(g_sVersusConf, sizeof(g_sVersusConf));
	Format(g_sNewName, sizeof(g_sNewName), "[%s] %s", g_sVersusConf, g_sDefultName);
	HostNameChange();
}
public void OnReadyUpInitiatePre()
{
	SetConVarString(g_sp_sendtoRdup, g_sDefultName)
	Format(g_sNewName, sizeof(g_sNewName), g_sDefultName);
	HostNameChange();
}
public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	HostNameChange();
}

HostNameChange()
{
	SetConVarString(g_hHostName, g_sNewName, false, false);
}