#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <colors>
#include <mix_team>
#include <ripext/http>

#define VALVEURL "ISteamUserStats/GetUserStatsForGame/v0002/?appid=550"
char VALVEKEY[32];
enum struct Player{
	int id;
	int rankpoint;  // 综合评分
	int gametime;	// 真实游戏时长
	int tankrocks;	// 坦克饼命中数
	float winrounds;	//胜场百分比（0-1）, <500置默认
	int versustotal;
	int versuswin;
}

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_REAL_CLIENT(%1)      (IsClientInGame(%1) && !IsFakeClient(%1))
#define IS_SPECTATOR(%1)        (GetClientTeam(%1) == TEAM_SPECTATOR)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == TEAM_SURVIVOR)

public Plugin myinfo = { 
	name = "MixTeamTime",
	author = "SirP",
	description = "Adds mix team by time",
	version = "1.0"
};


#define TRANSLATIONS            "mt_team.phrases"

#define TEAM_SURVIVOR           2 
#define TEAM_INFECTED           3

#define MIN_PLAYERS             8

// Macros
#define IS_REAL_CLIENT(%1)      (IsClientInGame(%1) && !IsFakeClient(%1))


/**
 * Loads dictionary files. On failure, stops the plugin execution.
 * 
 * @noreturn
 */
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

/**
 * Called when the plugin is fully initialized and all known external references are resolved.
 * 
 * @noreturn
 */
public void OnPluginStart() {
	InitTranslations();
}

public void OnAllPluginsLoaded() {
	AddMixType("team", MIN_PLAYERS, 0);
}

public void GetVoteTitle(int iClient, char[] sTitle) {
	Format(sTitle, VOTE_TITLE_SIZE, "%T", "VOTE_TITLE", iClient);
}

public void GetVoteMessage(int iClient, char[] sMsg) {
	Format(sMsg, VOTE_MSG_SIZE, "%T", "VOTE_MESSAGE", iClient);
}

/**
 * Starting the mix.
 * 
 * @noreturn
 */
public void OnMixInProgress()
{
	Handle hPlayers = CreateArray(sizeof(Player));
	Player tPlayer;

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient) || !IsMixMember(iClient)) {
			continue;
		}

		tPlayer.id = iClient;
		GetClientRP(tPlayer)
		PushArrayArray(hPlayers, tPlayer);
	}
	SortADTArrayCustom(hPlayers, SortByRank);

	int surv[4];
	int infs[4];

	// 假设hPlayers是一个Player数组，已经按rankpoint从大到小排序
	// 假设surv和infs是两个int数组，用来存放分配后的玩家id
	// 假设n是玩家的总数，这里是8
	n = 8
	// 定义一个二维数组dp，dp[i][j]表示前i个玩家中有j个分配给surv队伍时，两队的评分差距的最小值
	int dp[n+1][n/2+1];

	// 初始化dp数组为无穷大
	for (int i = 0; i <= n; i++) {
		for (int j = 0; j <= n/2; j++) {
			dp[i][j] = 2147483647;
		}
	}

	// 定义一个二维数组path，path[i][j]表示前i个玩家中有j个分配给surv队伍时，第i个玩家是分配给surv队伍还是infs队伍
	bool path[n+1][n/2+1];

	// 初始化path数组为false
	for (int i = 0; i <= n; i++) {
		for (int j = 0; j <= n/2; j++) {
			path[i][j] = false;
		}
	}

	// 定义一个变量sum，表示所有玩家的评分总和
	int sum = 0;

	// 计算sum的值
	for (int i = 0; i < n; i++) {
		sum += hPlayers[i].rankpoint;
	}

	// 动态规划的状态转移方程为：
	// dp[i][j] = min(dp[i-1][j], dp[i-1][j-1] + abs(2 * hPlayers[i-1].rankpoint - sum / (n/2)))
	// path[i][j] = true if dp[i-1][j-1] + abs(2 * hPlayers[i-1].rankpoint - sum / (n/2)) < dp[i-1][j], else false

	// 边界条件为：
	// dp[0][0] = 0
	dp[0][0] = 0;

	// 遍历所有状态，更新dp和path数组
	for (int i = 1; i <= n; i++) {
		for (int j = 0; j <= n/2; j++) {
			// 如果j等于0，表示前i个玩家都分配给infs队伍，那么dp[i][j]等于前i个玩家的评分总和减去平均值的绝对值
			if (j == 0) {
				dp[i][j] = abs(sum - i * sum / (n/2));
			}
			// 如果j等于i，表示前i个玩家都分配给surv队伍，那么dp[i][j]等于前i个玩家的评分总和减去平均值的绝对值
			else if (j == i) {
				dp[i][j] = abs(sum - (n - i) * sum / (n/2));
			}
			// 否则，根据状态转移方程更新dp[i][j]和path[i][j]
			else {
				int temp = dp[i-1][j-1] + abs(2 * hPlayers[i-1].rankpoint - sum / (n/2));
				if (temp < dp[i-1][j]) {
					dp[i][j] = temp;
					path[i][j] = true;
				}
				else {
					dp[i][j] = dp[i-1][j];
					path[i][j] = false;
				}
			}
		}
	}

	int surrankpoint, infrankpoint = 0;

	// 根据path数组回溯找出最优的分配方案
	int i = n;
	int j = n/2;
	PrintToConsoleAll("Mix成员 经验评分 = 2*对抗胜率*(0.75*真实游戏时长+TANK饼命中数)");
	PrintToConsoleAll("-----------------------------------------------------------")
	while (i > 0 && j >= 0) {
		// 如果path[i][j]为true，表示第i个玩家分配给surv队伍
		if (path[i][j]) {
			// 将第i个玩家的id存入surv数组
			surv[j-1] = hPlayers[i-1].id;
			PrintToConsoleAll("%N  %i=2*%.2f*(0.75*%i+%i)",hPlayers[i-1].id, hPlayers[i-1].rankpoint);
			surrankpoint = surrankpoint + hPlayers[i-1].rankpoint;
			// 更新i和j的值
			i--;
			j--;
		}
		// 否则，表示第i个玩家分配给infs队伍
		else {
			// 将第i个玩家的id存入infs数组
			infs[n/2 - j - 1] = hPlayers[i-1].id;
			PrintToConsoleAll("%N  %i=2*%.2f*(0.75*%i+%i)",hPlayers[i-1].id, hPlayers[i-1].rankpoint);
			infrankpoint = infrankpoint + hPlayers[i-1].rankpoint;
			// 更新i的值
			i--;
		}
	}

	

	// 分配队伍
	for(int tosurv = 0; tosurv < sizeof(surv); tosurv++){
		if (IsMixMember(tosurv)){
			SetClientTeam(tosurv, L4D2Team_Survivor);
		}
	}
	for(int toinf = 0; tosurv < sizeof(infs); toinf++){
		if (IsMixMember(toinf)){
			SetClientTeam(toinf, L4D2Team_Infected);
		}
	}
	CPrintToChatAll("[{green}!{default}] {olive}队伍分配完毕!");
	CPrintToChatAll("生还者经验分平均为 {blue}%i");
	CPrintToChatAll("特感者经验分平均为 {red}%i");
	CPrintToChatAll("[{green}!{default}] {olive}你可以查看控制台输出来获取每个人的经验信息!");
	// Required
	CallEndMix();
}

int SortByRank(int indexFirst, int indexSecond, Handle hArrayList, Handle hndl)
{
	Player tPlayerFirst, tPlayerSecond;

	GetArrayArray(hArrayList, indexFirst, tPlayerFirst);
	GetArrayArray(hArrayList, indexSecond, tPlayerSecond);

	if (tPlayerFirst.rankpoint < tPlayerSecond.rankpoint) {
		return -1;
	}

	if (tPlayerFirst.rankpoint > tPlayerSecond.rankpoint) {
		return 1;
	}

	return 0;
}
/**
 * 获取Steam api key
 * 
 * @noreturn
 */
void GetKeyinFile()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath),"configs/api_key.txt");//檔案路徑設定

    Handle file = OpenFile(sPath, "r");//讀取檔案
    if(file == INVALID_HANDLE)
    {
        SetFailState("file configs/api_key.txt doesn't exist!");
        return;
    }

    char readData[256];
    if(!IsEndOfFile(file) && ReadFileLine(file, readData, sizeof(readData)))//讀一行
    {
        Format(VALVEKEY, sizeof(VALVEKEY), "%s", readData);
    }
}

/**
 * 获取玩家的游戏时间
 * 失败时，时长和丢饼数会默认为700/700
 * 
 * @param iPlayer 玩家对象
 * @noreturn
 */
int GetClientRP(Player iPlayer)
{
	// 获取信息
	decl String:URL[1024];
	decl String:id64[64];
	GetClientAuthId(client,AuthId_SteamID64,id64,sizeof(id64));
	if(StrEqual(id64,"STEAM_ID_STOP_IGNORING_RETVALS")){
		iPlayer.gametime = 700;
		iPlayer.tankrocks = 700;
		iPlayer.winrounds = 0.5;
		iPlayer.rankpoint = 2 * iPlayer.winrounds * (0.75 * iPlayer.gametime + iPlayer.tankrocks);
		return;
	}
	HTTPClient httpClient = new HTTPClient("http://api.steampowered.com");
	Format(URL,sizeof(URL),"%s&key=%s&steamid=%s",VALVEURL,VALVEKEY,id64);
	PrintToServer("%s",URL);
	httpClient.Get(URL,OnReceived,iPlayer);
}
public void OnReceived(HTTPResponse response, Player iPlayer)
{
	decl String:buff[50];
	if (response.Data == null) {
        PrintToServer("Invalid JSON response");
		player_time[i]=0;
		//CPrintToChatAll("{red}%N加入了游戏，真实游戏时长 Unkown",i); 
		iPlayer.gametime = 700;
		iPlayer.tankrocks = 700;
		iPlayer.winrounds = 0.5;
		iPlayer.rankpoint = 2 * iPlayer.winrounds * (0.75 * iPlayer.gametime + iPlayer.tankrocks);
        return;  
    }
	JSONObject json=view_as<JSONObject>response.Data;
	json=view_as<JSONObject>json.Get("playerstats");
	JSONArray jsonarray=view_as<JSONArray>json.Get("stats");
	for(int j=0;j<jsonarray.Length;j++)
	{
		json=view_as<JSONObject>jsonarray.Get(j);
		json.GetString("name",buff,sizeof(buff));
		if(StrEqual(buff,"Stat.TotalPlayTime.Total"))		
		{
			iPlayer.gametime = json.GetInt("value")/3600;
		}else if(StrEqual(buff,"Stat.SpecAttack.Tank")){
			iPlayer.tankrocks = json.GetInt("value");
		}else if(StrEqual(buff,"Stat.GamesPlayed.Versus")){
			iPlayer.versustotal = json.GetInt("value");
		}else if(StrEqual(buff,"tat.GamesWon.Versus")){
			iPlayer.versuswin = json.GetInt("value");
		}
	}
	iPlayer.winrounds = iPlayer.versuswin / iPlayer.versustotal;
	iPlayer.rankpoint = 2 * iPlayer.winrounds * (0.75 * iPlayer.gametime + iPlayer.tankrocks);
}

/**
 * Hack to execute cheat commands.
 * 
 * @noreturn
 */
void CheatCommand(int iClient, const char[] sCmd, const char[] sArgs = "")
{
    int iFlags = GetCommandFlags(sCmd);
    SetCommandFlags(sCmd, iFlags & ~FCVAR_CHEAT);
    FakeClientCommand(iClient, "%s %s", sCmd, sArgs);
    SetCommandFlags(sCmd, iFlags);
}
/**
 * Sets the client team.
 * 
 * @param iClient     Client index
 * @param iTeam       Param description
 * @return            true if success
 */
bool SetClientTeam(int iClient, int iTeam)
{
    if (!IS_VALID_CLIENT(iClient)) {
        return false;
    }

    if (GetClientTeam(iClient) == iTeam) {
        return true;
    }

    if (iTeam != TEAM_SURVIVOR) {
        ChangeClientTeam(iClient, iTeam);
        return true;
    }
    else if (FindSurvivorBot() > 0)
    {
        CheatCommand(iClient, "sb_takecontrol");
        return true;
    }

    return false;
}
int FindSurvivorBot()
{
    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (!IsClientInGame(iClient) || !IsFakeClient(iClient) || !IS_SURVIVOR(iClient)) {
            continue;
        }

        return iClient;
    }

    return -1;
}