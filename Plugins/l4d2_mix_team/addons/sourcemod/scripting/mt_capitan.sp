#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <colors>
#include <mix_team>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)

public Plugin myinfo = { 
	name = "MixTeamCapitan",
	author = "TouchMe",
	description = "Adds capitan mix",
	version = "1.0"
};


#define TRANSLATIONS            "mt_capitan.phrases"

#define TEAM_SPECTATOR          1
#define TEAM_SURVIVOR           2
#define TEAM_INFECTED           3

#define MENU_TITTLE_SIZE       128

#define STEP_INIT              0
#define STEP_FIRST_CAPITAN     1
#define STEP_SECOND_CAPITAN    2
#define STEP_PICK_TEAM_FIRST   3
#define STEP_PICK_TEAM_SECOND  4

// Macros
#define IS_REAL_CLIENT(%1)      (IsClientInGame(%1) && !IsFakeClient(%1))
#define IS_SPECTATOR(%1)        (GetClientTeam(%1) == TEAM_SPECTATOR)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == TEAM_SURVIVOR)


int
	g_iFirstCapitan = 0,
	g_iSecondCapitan = 0,
	g_iVoteCount[MAXPLAYERS + 1] = {0, ...};

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
	AddMixType("capitan", (FindConVar("survivor_limit").IntValue * 2));
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
public void OnMixStart() {
	Flow(STEP_INIT);
}

/**
  * Builder menu.
  *
  * @noreturn
  */
public Menu BuildMenu(int iClient, int iStep)
{
	Menu hMenu = new Menu(HandleMenu);

	char sMenuTitle[MENU_TITTLE_SIZE];

	switch(iStep)
	{
		case STEP_FIRST_CAPITAN: {
			Format(sMenuTitle, sizeof(sMenuTitle), "%t", "MENU_TITLE_FIRST_CAPITAN", iClient);
		}

		case STEP_SECOND_CAPITAN: {
			Format(sMenuTitle, sizeof(sMenuTitle), "%t", "MENU_TITLE_SECOND_CAPITAN", iClient);
		}

		case STEP_PICK_TEAM_FIRST, STEP_PICK_TEAM_SECOND: {
			Format(sMenuTitle, sizeof(sMenuTitle), "%t", "MENU_TITLE_PICK_TEAMS", iClient);
		}
	}
	
	hMenu.SetTitle(sMenuTitle);

	char sPlayerInfo[6];
	char sPlayerName[32];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++) 
	{
		if (!IS_REAL_CLIENT(iPlayer) || !IS_SPECTATOR(iPlayer) || !IsMixMember(iPlayer)) {
			continue;
		}

		Format(sPlayerInfo, sizeof(sPlayerInfo), "%d %d", iStep, iPlayer);
		GetClientName(iPlayer, sPlayerName, sizeof(sPlayerName));
		
		hMenu.AddItem(sPlayerInfo, sPlayerName);
	}

	hMenu.ExitButton = false;

	return hMenu.ItemCount > 1 ? hMenu : null;
}

bool DisplayMenuAll(int iStep) 
{
	Menu hMenu;

	for (int iClient = 1; iClient <= MaxClients; iClient++) 
	{
		if (!IS_REAL_CLIENT(iClient) || !IS_SPECTATOR(iClient) || !IsMixMember(iClient)) {
			continue;
		}

		if ((hMenu = BuildMenu(iClient, iStep)) == null) {
			return false;
		}

		DisplayMenu(hMenu, iClient, 10);
	}

	return true;
}

/**
 * Menu item selection handler.
 * 
 * @param hMenu       Menu ID
 * @param iAction     Param description
 * @param iClient     Client index
 * @param iIndex      Item index
 * @return            Return description
 */
public int HandleMenu(Menu hMenu, MenuAction iAction, int iClient, int iIndex)
{
	if (iAction == MenuAction_End) {
		delete hMenu;
	}

	else if (iAction == MenuAction_Select)
	{
		char sInfo[6];
		hMenu.GetItem(iIndex, sInfo, sizeof(sInfo));

		char sStep[2], sClient[3];
		BreakString(sInfo[BreakString(sInfo, sStep, sizeof(sStep))], sClient, sizeof(sClient));

		int iStep = StringToInt(sStep);
		int iTarget = StringToInt(sClient);

		switch(iStep)
		{
			case STEP_FIRST_CAPITAN, STEP_SECOND_CAPITAN: {
				g_iVoteCount[iTarget] ++;
			}
			case STEP_PICK_TEAM_FIRST, STEP_PICK_TEAM_SECOND: 
			{	
				bool bIsPickFirstCapitan = (iStep == STEP_PICK_TEAM_FIRST);

				if (bIsPickFirstCapitan)
				{
					SetClientTeam(iTarget, TEAM_SURVIVOR);	
					CPrintToChatAll("%t", "PICK_TEAM", g_iFirstCapitan, iTarget);

					Flow(STEP_PICK_TEAM_SECOND);
				}

				else
				{
					SetClientTeam(iTarget, TEAM_INFECTED);	
					CPrintToChatAll("%t", "PICK_TEAM", g_iSecondCapitan, iTarget);

					Flow(STEP_PICK_TEAM_FIRST);
				}
			}
		}
	}

	return 0;
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

public void Flow(int iStep)
{
	switch(iStep)
	{
		case STEP_INIT:
		{
			PrepareVote();
			DisplayMenuAll(STEP_FIRST_CAPITAN);

			CreateTimer(11.0, NextStepTimer, STEP_FIRST_CAPITAN);
		}

		case STEP_FIRST_CAPITAN: 
		{
			SetFirstCapitan(GetVoteWinner());
			PrepareVote();
			DisplayMenuAll(STEP_SECOND_CAPITAN);

			CreateTimer(11.0, NextStepTimer, STEP_SECOND_CAPITAN);
		}

		case STEP_SECOND_CAPITAN:
		{
			SetSecondCapitan(GetVoteWinner());

			Flow(STEP_PICK_TEAM_FIRST);
		}

		case STEP_PICK_TEAM_FIRST, STEP_PICK_TEAM_SECOND: 
		{
			int iCapitan = (iStep == STEP_PICK_TEAM_FIRST) ? g_iFirstCapitan : g_iSecondCapitan;

			Menu hMenu = BuildMenu(iCapitan, iStep);

			if (hMenu == null)
			{
				// auto-pick last player
				for (int iClient = 1; iClient <= MaxClients; iClient++) 
				{
					if (!IS_REAL_CLIENT(iClient) || !IS_SPECTATOR(iClient) || !IsMixMember(iClient)) {
						continue;
					}

					SetClientTeam(iClient, FindSurvivorBot() > 0 ? TEAM_SURVIVOR : TEAM_INFECTED);	
					break;
				}

				// Required
				CallEndMix();
			}

			else
			{
				DisplayMenu(hMenu, iCapitan, 1);

				CreateTimer(1.0, NextStepTimer, iStep); 
			}
		}
	}
}

/**
 * Timer.
 */
 public Action NextStepTimer(Handle hTimer, int iStep)
{
	Flow(iStep);

	return Plugin_Stop;
}

void PrepareVote()
{
	for (int iClient = 1; iClient <= MaxClients; iClient++) 
	{
		g_iVoteCount[iClient] = 0;
	}
}

int GetVoteWinner()
{
	int iWinner = -1;

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient) || !IS_SPECTATOR(iClient) || !IsMixMember(iClient)) {
			continue;
		}

		if (iWinner == -1) {
			iWinner = iClient;
		}

		else if (g_iVoteCount[iWinner] < g_iVoteCount[iClient]) {
			iWinner = iClient;
		}
	}

	return iWinner;
}

void SetFirstCapitan(int iClient)
{
	g_iFirstCapitan = iClient;

	SetClientTeam(iClient, TEAM_SURVIVOR);
	CPrintToChatAll("%t", "NEW_FIRST_CAPITAN", iClient, g_iVoteCount[iClient]);
}

void SetSecondCapitan(int iClient)
{
	g_iSecondCapitan = iClient;

	SetClientTeam(iClient, TEAM_INFECTED);
	CPrintToChatAll("%t", "NEW_SECOND_CAPITAN", iClient, g_iVoteCount[iClient]);
}

/**
 * Finds a free bot.
 * 
 * @return     Bot index or -1
 */
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
