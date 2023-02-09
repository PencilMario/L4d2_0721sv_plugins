#include <sourcemod>
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

char g_sName[64];

public Plugin myinfo = {
    name = "Description",
    author = "sp",
    description = "修改游戏desc",
    version = "1.0.0",
    url = ""
};

public void OnMapStart()
{
    Format(g_sName, sizeof(g_sName), "漏风牢房");
}

public void OnGameFrame()
{
    SteamWorks_SetGameDescription(g_sName);
}
