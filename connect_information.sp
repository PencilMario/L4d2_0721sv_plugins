#pragma semicolon 1
#define DEBUG
#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <geoipcity>
#define PLUGIN_VERSION "1.6"

char ClientIP[36];
char country[45];
char code2[3];
new String: city[45];
new String:user_steamid[21];
new String:user_ip[36];
new String:region[45];
new String:country_name[45];
new String:country_code[3];
new String:country_code3[4];


public Plugin:myinfo =
{
    name = "Connect & Disconnect Info",
    author = "Hoongdou",
    description = "Show SteamID 、Country and IP while Ccnnecting,when leaving the game would print the reasons.",
    version = PLUGIN_VERSION,
    url = ""
};

public OnPluginStart() {
    HookEvent("player_disconnect", playerDisconnect, EventHookMode_Pre);
}


public void OnClientAuthorized(int client, const char[] auth) 
//public void OnClientPutInServer(client)
{
    GetClientIP(client, ClientIP, 20, true);
    GetClientAuthId(client, AuthId_Steam2, user_steamid, sizeof(user_steamid));
    GeoipCountry(ClientIP, country, sizeof(country));
    GeoipCode2(ClientIP, code2);
    GeoipGetRecord(user_ip, city, region, country_name, country_code, country_code3);
    //GeoipCity(ClientIP, city, sizeof(city));
    if (!IsFakeClient(client))
	{
	    PrintToChatAll("\x05%N \x03<%s>\x01connected. \nFrom\x05 %s [%s]\x04%s", client, user_steamid, city, code2, ClientIP);
	}
}

public playerDisconnect(Handle:event, const String:name[], bool:dontBroadcast) {
    SetEventBroadcast(event, true);
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || client > MaxClients) return;
    decl String:steamId[64];
    GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
    //GetClientAuthString(client, steamId, sizeof(steamId));
    if (strcmp(steamId, "BOT") == 0) return;

    decl String:reason[128];
    GetEventString(event, "reason", reason, sizeof(reason));
    decl String:playerName[128];
    GetEventString(event, "name", playerName, sizeof(playerName));
    decl String:timedOut[256];
    Format(timedOut, sizeof(timedOut), "%s timed out", playerName);
    PrintToChatAll("\x05%s \x03<%s> \x01disconnected.\n\x05Reason: \x04%s", playerName, steamId, reason);
    LogMessage("[Connect Info] Player %s <%s> left the game: %s", playerName, steamId, reason);
	
    // If the leaving player crashed, pause.
    if (strcmp(reason, timedOut) == 0 || strcmp(reason, "No Steam logon") == 0) 
	{
        PrintToChatAll("\x05%s \x01crashed.", playerName);
    }
}
	
//no reason:just print disconnected.
/*public OnClientDisconnect(client)  
{
	if (!IsFakeClient(client))
	{
		PrintToChatAll("\x05%N \x01disconnected.", client);
	}
}
*/