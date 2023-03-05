#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <colors>
#include <mix_team>
#include <mp_transiation>
#include <readyup>


#define MAP_NAME_MAX_LENGTH     64
#define NULL_MAP                "NULL_MAP"
#define TRANSLATIONS            "mp_random.phrases"
#define MIN_PLAYERS             1
#define PATH_TO_MISSIONS        "addons/sourcemod/data/missions/"

char sBuffer[128];

public Plugin myinfo = { 
	name = "MixThirdMap",
	author = "SirP",
	description = "为mix添加随机选择三方地图功能",
	version = "1.0"
};

ArrayList g_sOfficialMapsM1,g_sOfficialMapsM2,g_sOfficialMapsM3,g_sOfficialMapsM4,g_sOfficialMapsM5;
ArrayList g_sMixMapQueue, g_sOfficialMissionFiles, g_sMapPools;
ArrayList g_sMissionFiles;

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
    g_sMissionFiles = new ArrayList(128);
    g_sOfficialMissionFiles = new ArrayList(128);
    g_sMixMapQueue = new ArrayList(64);
    g_sOfficialMapsM1 = new ArrayList(64);
    g_sOfficialMapsM2 = new ArrayList(64);
    g_sOfficialMapsM3 = new ArrayList(64);
    g_sOfficialMapsM4 = new ArrayList(64);
    g_sOfficialMapsM5 = new ArrayList(64);
    g_sMapPools = new ArrayList(64);

    //InitTranslations();

    // ========================官图========================
    g_sOfficialMissionFiles.PushString("campaign1.txt");
    g_sOfficialMissionFiles.PushString("campaign2.txt");
    g_sOfficialMissionFiles.PushString("campaign3.txt");
    g_sOfficialMissionFiles.PushString("campaign4.txt");
    g_sOfficialMissionFiles.PushString("campaign5.txt");
    g_sOfficialMissionFiles.PushString("campaign6.txt");
    g_sOfficialMissionFiles.PushString("campaign7.txt");
    g_sOfficialMissionFiles.PushString("campaign8.txt");
    g_sOfficialMissionFiles.PushString("campaign9.txt");
    g_sOfficialMissionFiles.PushString("campaign10.txt");
    g_sOfficialMissionFiles.PushString("campaign11.txt");
    g_sOfficialMissionFiles.PushString("campaign12.txt");
    g_sOfficialMissionFiles.PushString("campaign13.txt");
    g_sOfficialMissionFiles.PushString("campaign14.txt");
    g_sOfficialMissionFiles.PushString("credits.txt");
    g_sOfficialMissionFiles.PushString("parishdash.txt");
    g_sOfficialMissionFiles.PushString("shootzones.txt");
    g_sOfficialMissionFiles.PushString("jtsm.txt");
    InitMaps();
    // ========================三方图======================

    // ====================查询指令=========================
    RegConsoleCmd("sm_mixthirdmaps", Cmd_ShowMixedMaps);
    RegConsoleCmd("sm_mappools", Cmd_ShowMapPool);
    //RegAdminCmd("sm_removemixmaps")
    ReadMapList();
}
public void InitMaps(){
    // 遍历文件
    DirectoryListing dirList = OpenDirectory("missions", true, NULL_STRING);
	if (dirList != null)
	{
        FileType type;
        while (dirList.GetNext(sBuffer, sizeof(sBuffer), type))
		{
            if (type == FileType_File)
		    {
                g_sMissionFiles.PushString(sBuffer);
                PrintToConsoleAll(sBuffer);
		    }
        }
    }
    delete dirList;
    // 读取文件信息
    for(int i=0; i<g_sMissionFiles.Length-1;i++){
        char sg_file[128];
        char sNum[8];
        KeyValues hGM = new KeyValues("missions");
        g_sMissionFiles.GetString(i, sBuffer, sizeof(sBuffer));
        if (g_sOfficialMissionFiles.FindString(sBuffer) != -1){
            continue;
        }
	    Format(sg_file, sizeof(sg_file), "missions/%s", sBuffer);
	    hGM.ImportFromFile(sg_file);
    
	    char sDisplayTitle[256];
	    hGM.GetString("DisplayTitle", sDisplayTitle, sizeof(sDisplayTitle));


	    if (hGM.JumpToKey("modes"))
	    {
	    	if (hGM.JumpToKey("versus")){
			{
                g_sMapPools.PushString(sDisplayTitle);
                PrintToConsoleAll(sDisplayTitle);
				int i = 1;
				int l = 1;
				while (i <= l)
				{
					Format(sNum, sizeof(sNum), "%i", i);
					if (hGM.JumpToKey(sNum))
					{
						l += 1;
						char sMapText[256];
						hGM.GetString("Map", sBuffer, sizeof(sBuffer)-1, "");
                        PrintToConsoleAll(sBuffer);
                        PrintToConsoleAll("%i", l);
                        switch (i){
                            case 1:
                                g_sOfficialMapsM1.PushString(sBuffer);
                            case 2:
                                g_sOfficialMapsM2.PushString(sBuffer);
                            case 3:
                                g_sOfficialMapsM3.PushString(sBuffer);
                            case 4:
                                g_sOfficialMapsM4.PushString(sBuffer);
                            case 5:
                                g_sOfficialMapsM5.PushString(sBuffer);
                        }					
						hGM.GoBack();
					}
					i += 1;
				}
            }
        }
        delete hGM;
    }
    }}
public void OnRoundIsLive(){
    int mapfinded;
    char currmap[MAP_NAME_MAX_LENGTH];
    GetCurrentMap(currmap, sizeof(currmap));
    mapfinded = g_sMixMapQueue.FindString(currmap);
    if (mapfinded == -1 && g_sMixMapQueue.Length != 0){
        ResetAllMapTransition();
        g_sMixMapQueue.Clear();
        PrintToChatAll("已切换至非MIX队列地图，地图队列已重置");
    }
    
}
public Action Cmd_ShowMapPool(int iClient, int iArgs){
    CPrintToChat(iClient, "以下为服务器支持的三方图列表");
}

public Action Cmd_ShowMixedMaps(int iClient, int iArgs){
    //PrintToChatAll("start sm_mixmaps");
    char message[MAX_MESSAGE_LENGTH];
    //OnMixStart();
    GetAnnounceString(message, sizeof(message));
    CPrintToChat(iClient, message);
    
}
public void OnAllPluginsLoaded() {
	AddMixType("ranthirdmap", MIN_PLAYERS);
}

public void GetRandomMap(ArrayList maplist, char[] buffer, int maxlen){
    int randm = 0;
    int copednum = 0;
    char selectedmap[MAP_NAME_MAX_LENGTH];
    Format(buffer, maxlen, NULL_MAP);
    //PrintToConsoleAll("maplist.Length - %i", maplist.Length);
    while(StrEqual(buffer, NULL_MAP)){
        randm = GetRandomInt(1, maplist.Length-1);
        copednum = maplist.GetString(randm, buffer, maxlen);
        maplist.GetString(randm, selectedmap, sizeof(selectedmap));
       // PrintToConsoleAll("randommap - %s, %i", selectedmap, copednum);
    }
}

public void GetVoteTitle(int iClient, char[] sTitle) {
	Format(sTitle, VOTE_TITLE_SIZE, "开始随机MixMap", iClient);
}

public void GetVoteMessage(int iClient, char[] sMsg) {
	Format(sMsg, VOTE_MSG_SIZE, "即将切换至m1...", iClient);
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
    ResetAllMapTransition();
    g_sMixMapQueue.Clear();
    //PrintToChatAll("start random map");
    char sMap1[MAP_NAME_MAX_LENGTH], sMap2[MAP_NAME_MAX_LENGTH], sMap3[MAP_NAME_MAX_LENGTH], sMap4[MAP_NAME_MAX_LENGTH], sMap5[MAP_NAME_MAX_LENGTH];
    GetRandomMap(g_sOfficialMapsM1, sMap1, sizeof(sMap1));
    //PrintToConsoleAll("map - %s", sMap1);
    g_sMixMapQueue.PushString(sMap1);
    GetRandomMap(g_sOfficialMapsM2, sMap2, sizeof(sMap1));
    //PrintToConsoleAll("map - %s", sMap2);
    g_sMixMapQueue.PushString(sMap2);
    GetRandomMap(g_sOfficialMapsM3, sMap3, sizeof(sMap1));
    //PrintToConsoleAll("map - %s", sMap3);
    g_sMixMapQueue.PushString(sMap3);
    GetRandomMap(g_sOfficialMapsM4, sMap4, sizeof(sMap1));
    //PrintToConsoleAll("map - %s", sMap4);
    g_sMixMapQueue.PushString(sMap4);

    AddMapTransition(sMap1, sMap2);
    AddMapTransition(sMap2, sMap3);
    AddMapTransition(sMap3, sMap4);
    int m5 = GetRandomInt(1,14);
    if (m5 > 7){
        GetRandomMap(g_sOfficialMapsM5, sMap5, sizeof(sMap1));
        //PrintToConsoleAll("map - %s", sMap5);
        g_sMixMapQueue.PushString(sMap5);
        AddMapTransition(sMap4, sMap5);
    }
    //PrintToChatAll("start add to translation list");

    


    //int pos = 0;
    
    //while(pos + 1 < g_sMixMapQueue.Length - 1){
    //    g_sMixMapQueue.GetString(pos, sMap1, sizeof(sMap1));
    //    g_sMixMapQueue.GetString(pos + 1, sMap1, sizeof(sMap1));
    //    AddMapTransition(sMap1, sMap2);
    //    pos++;
    //}
    
    char message[MAX_MESSAGE_LENGTH];
    
    GetAnnounceString(message, sizeof(message));
    
	CallEndMix();
    CPrintToChatAll(message);
    CPrintToChatAll("使用!mixthirdmaps再次展示");  //  LMCCore.inc
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
        Format(buffer, maxlen, "%s{olive}%s{default} > {olive}%s{default} > {olive}%s{default} > {olive}%s{default} > {olive}%s",
            sPrefix,sMap1,sMap2,sMap3,sMap4,sMap5);
    }
    else if(g_sMixMapQueue.Length == 4){
        g_sMixMapQueue.GetString(0, sMap1, sizeof(sMap1));
        g_sMixMapQueue.GetString(1, sMap2, sizeof(sMap2));
        g_sMixMapQueue.GetString(2, sMap3, sizeof(sMap3));
        g_sMixMapQueue.GetString(3, sMap4, sizeof(sMap4));
        Format(buffer, maxlen, "%s{olive}%s{default} > {olive}%s{default} > {olive}%s{default} > {olive}%s{default}",
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