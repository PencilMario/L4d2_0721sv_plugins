#include <sourcemod>
#include <multicolors>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

int g_iFrindlyKillCount[MAXPLAYERS+1] = {0};
int g_iContFKCount[MAXPLAYERS+1] = {0};
int g_iContFKTime[MAXPLAYERS+1] = {0};
bool g_bHaveFirstBlood = false;

public Plugin myinfo = {
    name = "连杀公报，但是连杀的是队友",
    author = "sp",
    description = "当击杀队友时进行语音播报",
    version = "1.0.0",
    url = "https://github.com/PencilMario/L4d2_0721sv_plugins/"
};
public void OnPluginStart(){
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_start", RoundStart_Event);
}
public void OnMapStart(){
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_double_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_triple_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_ultra_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_rampage_01.wav");

    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_1stblood_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_spree_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_dominate_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_mega_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_unstop_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_wicked_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_monster_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_godlike_01.wav");
    AddFileToDownloadsTable("sound/announcer_killing_spree/announcer_kill_holy_01.wav");

    PrecacheSound("announcer_killing_spree/announcer_kill_double_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_triple_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_ultra_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_rampage_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_1stblood_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_spree_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_dominate_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_mega_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_unstop_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_wicked_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_monster_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_godlike_01.wav");
    PrecacheSound("announcer_killing_spree/announcer_kill_holy_01.wav");
}

public void RoundStart_Event(Event event, const char[] name, bool dontBroadcast)
{
	for(int i = 1;i<MaxClients;i++){
        g_iContFKTime[i] = 0;
        g_iContFKCount[i] = 0;
    }
    g_bHaveFirstBlood = false;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if ( victim == 0 || !IsClientInGame(victim)) return;
	
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if (attacker == 0 || !IsClientInGame(attacker) ) return;
	if(GetClientTeam(attacker) == 2 ) //人類 kill
	{
		if(GetClientTeam(victim) == 2 && victim != attacker){
			g_iFrindlyKillCount[attacker]++;
            g_iContFKCount[attacker]++;
            g_iContFKTime[attacker] = 1;
            if (!g_bHaveFirstBlood){
                char cname[64];
                GetClientName(attacker, cname, sizeof(cname));
                CPrintToChatAll("[{red}!{default}] %s 拿下了{green}第一滴血！",cname);
                PlaySound("announcer_killing_spree/announcer_1stblood_01.wav");
                g_bHaveFirstBlood = true;
            }
            else{
                AnnounceSound(attacker);
            }
        }
	}	
}

void AnnounceSound(int client){
    char cname[64];
    GetClientName(client, cname, sizeof(cname));
    // 连杀状态
    if (g_iContFKTime[client]){
        if (g_iContFKCount[client] > 5){
            g_iContFKCount[client] = 5;
        } 
        switch (g_iContFKCount[client]){
            case 2:
                AaP(client, "[{red}!{default}] %s {green}双杀！", "announcer_killing_spree/announcer_kill_double_01.wav");
            case 3:
                AaP(client, "[{red}!{default}] %s {olive}三杀！", "announcer_killing_spree/announcer_kill_triple_01.wav");
            case 4:
                AaP(client, "[{red}!{default}] %s 正在{red}疯狂杀戮！", "announcer_killing_spree/announcer_kill_ultra_01.wav");
            case 5:
                AaP(client, "[{red}!{default}] %s 已经{red}暴走了！", "announcer_killing_spree/announcer_kill_rampage_01.wav");
        }
    }
    else{
        if (g_iFrindlyKillCount[client] > 9){
            g_iFrindlyKillCount[client] = 9;
        }
        switch (g_iFrindlyKillCount[client]){
            case 2:
                AaP(client, "[{red}!{default}] %s 正在{green}大杀特杀！", "announcer_killing_spree/announcer_kill_spree_01.wav");
            case 3:
                AaP(client, "[{red}!{default}] %s 已经{olive}主宰求生了！", "announcer_killing_spree/announcer_kill_dominate_01.wav");
            case 4:
                AaP(client, "[{red}!{default}] %s {olive}杀人如麻！", "announcer_killing_spree/announcer_kill_mega_01.wav");
            case 5:
                AaP(client, "[{red}!{default}] %s {olive}无人可挡！", "announcer_killing_spree/announcer_kill_unstop_01.wav");
            case 6:
                AaP(client, "[{red}!{default}] %s 正在{red}变态杀戮！", "announcer_killing_spree/announcer_kill_wicked_01.wav");
            case 7:
                AaP(client, "[{red}!{default}] %s 就像{red}一只恶魔！", "announcer_killing_spree/announcer_kill_monster_01.wav");
            case 8:
                AaP(client, "[{red}!{default}] %s 已经化身{red}求生之神！", "announcer_killing_spree/announcer_kill_godlike_01.wav");
            case 9:
                AaP(client, "{red}[!] %s 超神了！！！", "announcer_killing_spree/announcer_kill_holy_01.wav");
        }
    }
}

public void AaP(int client, const char[] message, const char[] sound){
    char cname[64];
    GetClientName(client, cname, sizeof(cname));
    CPrintToChatAll(message,cname);
    PlaySound(sound);
}
void PlaySound(const char[] sound){
    for (int i = 0; i < MaxClients + 1; i++){
        if (IsClientInGame(i)){
        EmitSoundToClient(i, sound);
        }
    }
}



