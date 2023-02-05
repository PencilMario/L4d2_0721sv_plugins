#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <mix_team>


public Plugin myinfo = { 
	name = "MixTeamRandom",
	author = "TouchMe",
	description = "Adds random mix",
	version = "1.0"
};


#define TRANSLATIONS            "mt_random.phrases"

#define TEAM_SURVIVOR           2 
#define TEAM_INFECTED           3

#define MIN_PLAYERS             4

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
	AddMixType("random", MIN_PLAYERS);
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
public void OnMixStart()
{
	// save current player / team setup
	int g_iPreviousCount[4];
	int g_iPreviousTeams[4][MAXPLAYERS + 1];

	for (int iClient = 1, iTeam; iClient <= MaxClients; iClient++)
	{
		if (!IS_REAL_CLIENT(iClient) || !IsMixMember(iClient)) {
			continue;
		}
		
		iTeam = GetLastTeam(iClient);
		g_iPreviousTeams[iTeam][g_iPreviousCount[iTeam]] = iClient;
		g_iPreviousCount[iTeam]++;
	}

	// if there are uneven players, move one to the other
	if ((g_iPreviousCount[TEAM_SURVIVOR] + g_iPreviousCount[TEAM_INFECTED]) < (2 * MIN_PLAYERS))
	{
		int tmpDif = g_iPreviousCount[TEAM_SURVIVOR] - g_iPreviousCount[TEAM_INFECTED];
		int iTeamA, iTeamB;

		while (tmpDif > 1 || tmpDif < -1) 
		{
			if (tmpDif > 1) {
				iTeamA = TEAM_SURVIVOR;
				iTeamB = TEAM_INFECTED;	
			}
			else if (tmpDif < -1) {
				iTeamA = TEAM_INFECTED;
				iTeamB = TEAM_SURVIVOR;	
			}

			g_iPreviousCount[iTeamA]--;
			g_iPreviousTeams[iTeamB][g_iPreviousCount[iTeamB]] = g_iPreviousTeams[iTeamA][g_iPreviousCount[iTeamA]];
			g_iPreviousCount[iTeamB]++;

			tmpDif = g_iPreviousCount[TEAM_SURVIVOR] - g_iPreviousCount[TEAM_INFECTED];
		}
	}

	// do shuffle: swap at least teamsize/2 rounded up players
	bool bShuffled[MAXPLAYERS + 1];
	int iShuffleCount = RoundToCeil(float(g_iPreviousCount[TEAM_INFECTED] > g_iPreviousCount[TEAM_SURVIVOR] ? g_iPreviousCount[TEAM_INFECTED] : g_iPreviousCount[TEAM_SURVIVOR]) / 2.0);

	int pickA, pickB;
	int spotA, spotB;

	for (int j = 0; j < iShuffleCount; j++ )
	{
		pickA = -1;
		pickB = -1;

		while (pickA == -1 || bShuffled[pickA]) {
			spotA = GetRandomInt(0, g_iPreviousCount[TEAM_SURVIVOR] - 1);
			pickA = g_iPreviousTeams[TEAM_SURVIVOR][spotA];
		}

		while (pickB == -1 || bShuffled[pickB]) {
			spotB = GetRandomInt(0, g_iPreviousCount[TEAM_INFECTED] - 1);
			pickB = g_iPreviousTeams[TEAM_INFECTED][spotB];
		}

		bShuffled[pickA] = true;
		bShuffled[pickB] = true;

		g_iPreviousTeams[TEAM_SURVIVOR][spotA] = pickB;
		g_iPreviousTeams[TEAM_INFECTED][spotB] = pickA;
	}

	// now place all the players in the teams according to previousteams (silly name now, but ok)
	for (int iTeam = TEAM_SURVIVOR, iClient; iTeam <= TEAM_INFECTED; iTeam++)
	{
		for (iClient = 0; iClient < g_iPreviousCount[iTeam]; iClient++)
		{
			ChangeClientTeam(g_iPreviousTeams[iTeam][iClient], iTeam);
		}
	}

	// Required
	CallEndMix();
}