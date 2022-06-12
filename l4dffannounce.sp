/* Plugin Template generated by Pawn Studio */
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#define CVAR_FLAGS				FCVAR_NOTIFY
#define MAXENTITIES 2048

public Plugin myinfo = 
{
	name = "L4D FF Announce Plugin",
	author = "Frustian & HarryPotter",
	description = "Adds Friendly Fire Announcements",
	version = "1.5",
	url = ""
}
//cvar handles
ConVar FFenabled;
ConVar AnnounceType;
ConVar directorready;

//Various global variables
int DamageCache[MAXPLAYERS+1][MAXPLAYERS+1]; //Used to temporarily store Friendly Fire Damage between teammates
Handle FFTimer[MAXPLAYERS+1]; //Used to be able to disable the FF timer when they do more FF
bool FFActive[MAXPLAYERS+1]; //Stores whether players are in a state of friendly firing teammates

public void OnPluginStart()
{
	FFenabled = CreateConVar("l4d_ff_announce_enable", "1", "Enable Announcing Friendly Fire",CVAR_FLAGS);
	AnnounceType = CreateConVar("l4d_ff_announce_type", "1", "Changes how ff announce displays FF damage (1:In chat; 2: In Hint Box; 3: In center text)",CVAR_FLAGS);
	directorready = FindConVar("director_ready_duration");
	HookEvent("player_hurt_concise", Event_HurtConcise, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath);

	//Autoconfig for plugin
	AutoExecConfig(true, "l4dffannounce");
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if ( victim == 0 || !IsClientInGame(victim)) return;
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if (attacker == 0 || !IsClientInGame(attacker) ) return;
	if(GetClientTeam(attacker) == 2 ) //人類 kill
	{
		if(GetClientTeam(victim) == 2 && victim != attacker)//友傷
			CPrintToChatAll("{green}[提示] {lightgreen}%N {default}星爆气流斩 {olive}%N{default}.",attacker, victim);
	}	
}
public Action Event_HurtConcise(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = event.GetInt("attackerentid");
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (FFenabled.BoolValue == false || directorready.IntValue == 0 || attacker > MaxClients || attacker < 1 || !IsClientInGame(attacker) || IsFakeClient(attacker) || GetClientTeam(attacker) != 2 || !IsClientInGame(victim) || GetClientTeam(victim) != 2)
		return;  //if director_ready_duration is 0, it usually means that the game is in a ready up state like downtown1's ready up mod.  This allows me to disable the FF messages in ready up.
	int damage = event.GetInt("dmg_health");
	if (FFActive[attacker])  //If the player is already friendly firing teammates, resets the announce timer and adds to the damage
	{
		Handle pack;
		DamageCache[attacker][victim] += damage;
		KillTimer(FFTimer[attacker]);
		FFTimer[attacker] = CreateDataTimer(1.0, AnnounceFF, pack);
		WritePackCell(pack,attacker);
	}
	else //If it's the first friendly fire by that player, it will start the announce timer and store the damage done.
	{
		DamageCache[attacker][victim] = damage;
		Handle pack;
		FFActive[attacker] = true;
		FFTimer[attacker] = CreateDataTimer(1.0, AnnounceFF, pack);
		WritePackCell(pack,attacker);
		for (int i = 1; i < 19; i++)
		{
			if (i != attacker && i != victim)
			{
				DamageCache[attacker][i] = 0;
			}
		}
	}
}
public Action AnnounceFF(Handle timer, Handle pack) //Called if the attacker did not friendly fire recently, and announces all FF they did
{
	char victim[128];
	char attacker[128];
	ResetPack(pack);
	int attackerc = ReadPackCell(pack);
	FFActive[attackerc] = false;
	if (IsClientInGame(attackerc) && !IsFakeClient(attackerc))
		GetClientName(attackerc, attacker, sizeof(attacker));
	else
		attacker = "Disconnected Player";
	for (int i = 1; i < MaxClients; i++)
	{
		if (DamageCache[attackerc][i] != 0 && attackerc != i)
		{
			if (IsClientInGame(i))
			{
				GetClientName(i, victim, sizeof(victim));
				switch(AnnounceType.IntValue)
				{
					case 1:
					{
						if (IsClientInGame(attackerc) && !IsFakeClient(attackerc))
							PrintToChat(attackerc, "\x01[\x05!\x01] \x01你刚黑了 \x04%d \x01滴血給 \x03%s\x01.",DamageCache[attackerc][i],victim);
						if (IsClientInGame(i) && !IsFakeClient(i))
							PrintToChat(i, "\x01[\x05!\x01] \x03%s \x01黑了 \x04%d \x01滴血給你.",attacker,DamageCache[attackerc][i]);
					}
					case 2:
					{
						if (IsClientInGame(attackerc) && !IsFakeClient(attackerc))
							PrintHintText(attackerc, "\x01你剛射 \x04%d \x01滴血給 \x03%s",DamageCache[attackerc][i],victim);
						if (IsClientInGame(i) && !IsFakeClient(i))
							PrintHintText(i, "\x03%s \x01射了 \x04%d \x01滴血給你",attacker,DamageCache[attackerc][i]);
					}
					case 3:
					{
						if (IsClientInGame(attackerc) && !IsFakeClient(attackerc))
							PrintCenterText(attackerc, "\x01你剛射 \x04%d \x01滴血給 \x03%s",DamageCache[attackerc][i],victim);
						if (IsClientInGame(i) && !IsFakeClient(i))
							PrintCenterText(i, "\x03%s \x01射了 \x04%d \x01滴血給你",attacker,DamageCache[attackerc][i]);
					}
				}
			}
			DamageCache[attackerc][i] = 0;
		}
	}
}
