#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <colors>
#include <mix_team>
#include <mp_transiation>


#define MAP_NAME_MAX_LENGTH     64
#define NULL_MAP                "NULL_MAP"
#define TRANSLATIONS            "mp_random.phrases"
#define MIN_PLAYERS             1

public Plugin myinfo = { 
	name = "MixMap",
	author = "SirP",
	description = "为mix添加mix地图功能",
	version = "1.0"
};

ArrayList g_sOfficialMapsM1,g_sOfficialMapsM2,g_sOfficialMapsM3,g_sOfficialMapsM4,g_sOfficialMapsM5;
ArrayList g_sMixMapQueue;

void InitTranslations()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, PLATFORM_MAX_PATH, "translations/" ... TRANSLATIONS ... ".txt");

	if (FileExists(sPath)) {
		LoadTranslations(TRANSLATIONS);
	} else {
		SetFailState("Path %s not found", sPath);
	}
}

public void OnPluginStart()
{
    g_sOfficialMapsM1 = new ArrayList();
    g_sOfficialMapsM2 = new ArrayList();
    g_sOfficialMapsM3 = new ArrayList();
    g_sOfficialMapsM4 = new ArrayList();
    g_sOfficialMapsM5 = new ArrayList();
    g_sMixMapQueue = new ArrayList();

    //InitTranslations();

    // ========================官图m1========================
    g_sOfficialMapsM1.PushString(NULL_MAP);
    g_sOfficialMapsM1.PushString("c1m1_hotel");
    g_sOfficialMapsM1.PushString("c2m1_highway");
    g_sOfficialMapsM1.PushString("c3m1_plankcountry");
    g_sOfficialMapsM1.PushString("c4m1_milltown_a");
    g_sOfficialMapsM1.PushString("c5m1_waterfront");
    g_sOfficialMapsM1.PushString("c6m1_riverbank");
    g_sOfficialMapsM1.PushString("c7m1_docks");
    g_sOfficialMapsM1.PushString("c8m1_apartment");
    g_sOfficialMapsM1.PushString("c9m1_alleys");
    g_sOfficialMapsM1.PushString("c10m1_caves");
    g_sOfficialMapsM1.PushString("c11m1_greenhouse");
    g_sOfficialMapsM1.PushString("c12m1_hilltop");
    g_sOfficialMapsM1.PushString("c13m1_alpinecreek");
    g_sOfficialMapsM1.PushString("c14m1_junkyard");

    // ========================官图m2========================
    g_sOfficialMapsM2.PushString(NULL_MAP);
    g_sOfficialMapsM2.PushString("c1m2_streets");
    g_sOfficialMapsM2.PushString("c2m2_fairgrounds");
    g_sOfficialMapsM2.PushString("c3m2_swamp");
    g_sOfficialMapsM2.PushString("c4m2_sugarmill_a");
    g_sOfficialMapsM2.PushString("c5m2_park");
    g_sOfficialMapsM2.PushString("c6m2_bedlam");
    g_sOfficialMapsM2.PushString("c7m2_barge");
    g_sOfficialMapsM2.PushString("c8m2_subway");
    g_sOfficialMapsM2.PushString("c9m2_lots");
    g_sOfficialMapsM2.PushString("c10m2_drainage");
    g_sOfficialMapsM2.PushString("c11m2_offices");
    g_sOfficialMapsM2.PushString("c12m2_traintunnel");
    g_sOfficialMapsM2.PushString("c13m2_southpinestream");
    g_sOfficialMapsM2.PushString("c14m2_lighthouse");
    // ========================官图m3========================
    g_sOfficialMapsM3.PushString(NULL_MAP);
    g_sOfficialMapsM3.PushString("c1m3_mall");
    g_sOfficialMapsM3.PushString("c2m3_coaster");
    g_sOfficialMapsM3.PushString("c3m3_shantytown");
    g_sOfficialMapsM3.PushString("c4m3_sugarmill_b");
    g_sOfficialMapsM3.PushString("c5m3_cemetery");
    g_sOfficialMapsM3.PushString("c6m3_port");
    g_sOfficialMapsM3.PushString("c7m3_port");
    g_sOfficialMapsM3.PushString("c8m3_sewers");
    g_sOfficialMapsM3.PushString(NULL_MAP);
    g_sOfficialMapsM3.PushString("c10m3_ranchhouse");
    g_sOfficialMapsM3.PushString("c11m3_garage");
    g_sOfficialMapsM3.PushString("c12m3_bridge");
    g_sOfficialMapsM3.PushString("c13m3_memorialbridge");
    g_sOfficialMapsM3.PushString(NULL_MAP);
    // ========================官图m4========================
    g_sOfficialMapsM4.PushString(NULL_MAP);
    g_sOfficialMapsM4.PushString("c1m4_atrium");
    g_sOfficialMapsM4.PushString("c2m4_barns");
    g_sOfficialMapsM4.PushString("c3m4_plantation");
    g_sOfficialMapsM4.PushString("c4m4_milltown_b");
    g_sOfficialMapsM4.PushString("c5m4_quarter");
    g_sOfficialMapsM4.PushString(NULL_MAP);
    g_sOfficialMapsM4.PushString(NULL_MAP);
    g_sOfficialMapsM4.PushString("c8m4_interior");
    g_sOfficialMapsM4.PushString(NULL_MAP);
    g_sOfficialMapsM4.PushString("c10m4_mainstreet");
    g_sOfficialMapsM4.PushString("c11m4_terminal");
    g_sOfficialMapsM4.PushString("c12m4_barn");
    g_sOfficialMapsM4.PushString("c13m4_cutthroatcreek");
    g_sOfficialMapsM4.PushString(NULL_MAP);
    // ========================官图m5========================
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString("c2m5_concert");
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString("c4m5_milltown_escape");
    g_sOfficialMapsM5.PushString("c5m5_bridge");
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString("c8m5_rooftop");
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString("c10m5_houseboat");
    g_sOfficialMapsM5.PushString("c11m5_runway");
    g_sOfficialMapsM5.PushString("c12m5_cornfield");
    g_sOfficialMapsM5.PushString(NULL_MAP);
    g_sOfficialMapsM5.PushString(NULL_MAP);

    // ====================查询指令=========================
    RegConsoleCmd("sm_mixmaps", Cmd_ShowMixedMaps);
}
public Action Cmd_ShowMixedMaps(int iClient, int iArgs){
    PrintToChatAll("start sm_mixmaps");
    char message[MAX_MESSAGE_LENGTH];
    OnMixStart();
    GetAnnounceString(message, sizeof(message));
    CPrintToChat(iClient, message);
    
}
public void OnAllPluginsLoaded() {
	AddMixType("randmap", MIN_PLAYERS);
}

public void GetRandomMap(ArrayList maplist, char[] buffer, int maxlen){
    int randm = 0;
    while(StrEqual(buffer, NULL_MAP)){
        randm = GetRandomInt(1, maplist.Length);
        maplist.GetString(randm, buffer, maxlen);
    }
}

public void GetVoteTitle(int iClient, char[] sTitle) {
	Format(sTitle, VOTE_TITLE_SIZE, "开始MixMap", iClient);
}

public void GetVoteMessage(int iClient, char[] sMsg) {
	Format(sMsg, VOTE_MSG_SIZE, "正在随机地图...", iClient);
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
public void OnMixStart()
{
    PrintToChatAll("start random map");
    char sMap1[MAP_NAME_MAX_LENGTH];
    char sMap2[MAP_NAME_MAX_LENGTH];
    GetRandomMap(g_sOfficialMapsM1, sMap1, sizeof(sMap1));
    g_sMixMapQueue.PushString(sMap1);
    GetRandomMap(g_sOfficialMapsM2, sMap1, sizeof(sMap1));
    g_sMixMapQueue.PushString(sMap1);
    GetRandomMap(g_sOfficialMapsM3, sMap1, sizeof(sMap1));
    g_sMixMapQueue.PushString(sMap1);
    GetRandomMap(g_sOfficialMapsM4, sMap1, sizeof(sMap1));
    g_sMixMapQueue.PushString(sMap1);

    int m5 = GetRandomInt(1,14);
    if (m5 > 7){
        GetRandomMap(g_sOfficialMapsM5, sMap1, sizeof(sMap1));
        g_sMixMapQueue.PushString(sMap1);
    }
    PrintToChatAll("start add to translation list");
    int pos = 0;
    while(pos + 1 < g_sMixMapQueue.Length - 1){
    g_sMixMapQueue.GetString(0, sMap1, sizeof(sMap1));
    g_sMixMapQueue.GetString(1, sMap1, sizeof(sMap1));
    AddMapTransition(sMap1, sMap2);
    }
    PrintToChatAll("start announcing");
    char message[MAX_MESSAGE_LENGTH];
    GetAnnounceString(message, sizeof(message));
	CallEndMix();
    CPrintToChatAll(message);
    CPrintToChatAll("使用!mixmaps再次展示");  //  LMCCore.inc
    CPrintToChatAll("即将切换到第一张地图");  //  LMCCore.inc
    CreateTimer(5.0, ChangeToFirstMap, _,TIMER_FLAG_NO_MAPCHANGE);

}
public void GetAnnounceString(char[] buffer, int maxlen){
    char sPrefix[96];
    Format(sPrefix, sizeof(sPrefix),"Mix地图序列:");
    char sMap1[MAP_NAME_MAX_LENGTH], sMap2[MAP_NAME_MAX_LENGTH], sMap3[MAP_NAME_MAX_LENGTH], sMap4[MAP_NAME_MAX_LENGTH], sMap5[MAP_NAME_MAX_LENGTH];
    if (g_sMixMapQueue.Length == 5){
        g_sMixMapQueue.GetString(0, sMap1, sizeof(sMap1));
        g_sMixMapQueue.GetString(1, sMap2, sizeof(sMap2));
        g_sMixMapQueue.GetString(2, sMap3, sizeof(sMap3));
        g_sMixMapQueue.GetString(3, sMap4, sizeof(sMap4));
        g_sMixMapQueue.GetString(4, sMap5, sizeof(sMap5));
        Format(buffer, maxlen, "%s{olive}%s{default}>{olive}%s{default}>{olive}%s{default}>{olive}%s{default}>{olive}%s",
            sPrefix,sMap1,sMap2,sMap3,sMap4,sMap5);
    }
    else if(g_sMixMapQueue.Length == 4){
        g_sMixMapQueue.GetString(0, sMap1, sizeof(sMap1));
        g_sMixMapQueue.GetString(1, sMap2, sizeof(sMap2));
        g_sMixMapQueue.GetString(2, sMap3, sizeof(sMap3));
        g_sMixMapQueue.GetString(3, sMap4, sizeof(sMap4));
        Format(buffer, maxlen, "%s{olive}%s{default}>{olive}%s{default}>{olive}%s{default}>{olive}%s{default}",
        sPrefix,sMap1,sMap2,sMap3,sMap4);
    }
    else{
        Format(buffer, maxlen,"队列中没有地图");
    }
}
public Action ChangeToFirstMap(Handle timer){
    char sNextMapName[MAP_NAME_MAX_LENGTH];
    g_sMixMapQueue.GetString(0, sNextMapName, sizeof(sNextMapName));
    ForceChangeLevel(sNextMapName, "Map Transitions");
}