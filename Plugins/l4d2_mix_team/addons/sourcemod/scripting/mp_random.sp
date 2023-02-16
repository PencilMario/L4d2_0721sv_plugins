#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <colors>
#include <mix_team>


public Plugin myinfo = { 
	name = "MixMap",
	author = "SirP",
	description = "为mix添加mix地图功能",
	version = "1.0"
};

StringMap g_sOfficialMapsM1,g_sOfficialMapsM2,g_sOfficialMapsM3,g_sOfficialMapsM4,g_sOfficialMapsM5;
