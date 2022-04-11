#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <readyup>
#include <l4d2util>

#define PLUGIN_VERSION "1.6"

#define		DN_TAG		"[DHostName]"
#define		SYMBOL_LEFT		'('
#define		SYMBOL_RIGHT	')'

ConVar g_hHostName, g_hReadyUp, l4d_config_name;
char g_sDefaultN[68];

public Plugin myinfo = 
{
	name = "L4D Dynamic中文伺服器名",
	author = "Harry Potter",
	description = "Show what mode is it now on chinese server name with txt file",
	version = PLUGIN_VERSION,
	url = "myself"
}

public void OnPluginStart()
{
	g_hReadyUp = CreateConVar("l4d_current_mode", "", "League notice displayed on server name", FCVAR_SPONLY | FCVAR_NOTIFY);
	g_hHostName	= FindConVar("hostname");
	l4d_config_name = CreateConVar("l4d_congig_name", "", "Configname to display on the ready-up panel", FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);

	g_hHostName.GetString(g_sDefaultN, sizeof(g_sDefaultN));
	if (strlen(g_sDefaultN))//strlen():回傳字串的長度
		ChangeServerName();
	HookEvent("round_end", RoundEnd_Event, EventHookMode_Pre);
}

public Action RoundEnd_Event(Event event, const char[] name, bool dontBroadcast)
{
    if(!iIncondHalfOfRound)//第一回合結束
		iIncondHalfOfRound = true;
}

public void OnMapStart()
{
	iIncondHalfOfRound = false;
}

public void OnConfigsExecuted()
{		
	if (!strlen(g_sDefaultN)) return;
	
	if (g_hReadyUp == INVALID_HANDLE){
	
		ChangeServerName();
		LogMessage("l4d_current_mode no found!");
	}
	else {
	
		char sReadyUpCfgName[128];
		GetConVarString(g_hReadyUp, sReadyUpCfgName, 128);

		ChangeServerName(sReadyUpCfgName);
	}
	
}

void ChangeServerNametoStatus(char sReadyUpCfgName[] = "")
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
			char sNewName[128];
			if(strlen(sReadyUpCfgName) == 0)
				Format(sNewName, sizeof(sNewName), "[%s@%s]%s | %d : %d",l4d_config_name,(iIncondHalfOfRound) ? "2nd" : "1st" ,readData,L4D2Direct_GetVSCampaignScore(L4D2_AreTeamsFlipped()), L4D2Direct_GetVSCampaignScore(!L4D2_AreTeamsFlipped()));
			else
				Format(sNewName, sizeof(sNewName), "%s%c%s%c", readData, SYMBOL_LEFT, sReadyUpCfgName, SYMBOL_RIGHT);
			
			SetConVarString(g_hHostName,sNewName);
			LogMessage("%s New server name \"%s\"", DN_TAG, sNewName);
			
			Format(g_sDefaultN,sizeof(g_sDefaultN),"%s",sNewName);
		}
}


void ChangeServerName(char sReadyUpCfgName[] = "")
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
			char sNewName[128];
			if(strlen(sReadyUpCfgName) == 0)
				Format(sNewName, sizeof(sNewName), "%s", readData);
			else
				Format(sNewName, sizeof(sNewName), "%s%c%s%c", readData, SYMBOL_LEFT, sReadyUpCfgName, SYMBOL_RIGHT);
			
			SetConVarString(g_hHostName,sNewName);
			LogMessage("%s New server name \"%s\"", DN_TAG, sNewName);
			
			Format(g_sDefaultN,sizeof(g_sDefaultN),"%s",sNewName);
		}
}