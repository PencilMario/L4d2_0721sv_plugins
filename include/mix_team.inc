/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#if defined  _mix_team_included_
 #endinput
#endif
#define _mix_team_included_

#define TYPE_NONE               -1

#define STATE_NONE              -1
#define STATE_VOTING            0
#define STATE_IN_PROGRESS       1

#define MIX_NAME_SIZE           16
#define DISPLAY_MSG_SIZE        128
#define VOTEEND_MSG_SIZE        128


native void CallCancelMix();

native void CallEndMix();

native int AddMixType(char[] sName, int iMinPlayers, int iTimeout);

/**
 * @brief Returns the status of the mix
 *
 * @return              STATE_NONE | STATE_VOTING | STATE_IN_PROGRESS
 **/
native int GetMixState();

/**
 * @brief Returns the mix type
 * @remarks The mix type is equal to the index of the element in the TypeList
 *
 * @return              TypeList Index or TYPE_NONE
 **/
native int GetMixType();

/**
 * @brief Returns whether the player is a member of the mix
 *
 * @param iClient       Client ID
 *
 * @return              true or false
 **/
native bool IsMixMember(int iClient);

/**
 * @brief Returns the team the player was on after voting for the mix
 *
 * @param iClient       Client ID
 *
 * @return              Returns the command if the player was in the mix, otherwise -1
 **/
native int GetLastTeam(int iClient);

/**
 * @brief Called when the mix completes successfully
 * @remarks The mix name is the same as the first argument AddMixType()
 *
 * @param sMixName      Mix name
 *
 * @noreturn
 */
forward void OnMixSuccess(const char[] sMixName);

/**
 * @brief Called when the mix is ​​interrupted
 * @remarks The mix name is the same as the first argument AddMixType()
 *
 * @param sMixName      Mix name
 *
 * @noreturn
 */
forward void OnMixFailed(const char[] sMixName);

public SharedPlugin __pl_mix_team =
{
	name = "mix_team",
	file = "mix_team.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mix_team_SetNTVOptional()
{
	MarkNativeAsOptional("AddMixType");
	MarkNativeAsOptional("GetMixState");
	MarkNativeAsOptional("GetMixType");
	MarkNativeAsOptional("CallCancelMix");
	MarkNativeAsOptional("CallEndMix");
	MarkNativeAsOptional("IsMixMember");
	MarkNativeAsOptional("GetLastTeam");
}
#endif


#define TEAM_NONE               0
#define TEAM_SPECTATOR          1
#define TEAM_SURVIVOR           2
#define TEAM_INFECTED           3

// Macros
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == TEAM_SURVIVOR)
#define IS_SPECTATOR(%1)        (GetClientTeam(%1) == TEAM_SPECTATOR)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == TEAM_INFECTED)

/**
 * Sets the client team.
 * 
 * @param iClient     Client index
 * @param iTeam       Param description
 * @return            true if success
 */
stock bool SetClientTeam(int iClient, int iTeam)
{
	if (iClient <= 0 || iClient > MaxClients) {
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

/**
 * Hack to execute cheat commands.
 * 
 * @noreturn
 */
stock void CheatCommand(int iClient, const char[] sCmd, const char[] sArgs = "")
{
	int iFlags = GetCommandFlags(sCmd);
	SetCommandFlags(sCmd, iFlags & ~FCVAR_CHEAT);
	FakeClientCommand(iClient, "%s %s", sCmd, sArgs);
	SetCommandFlags(sCmd, iFlags);
}

/**
 * Finds a free bot.
 * 
 * @return     Bot index or -1
 */
stock int FindSurvivorBot()
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient) || !IsFakeClient(iClient) || GetClientTeam(iClient) != TEAM_SURVIVOR) {
			continue;
		}

		return iClient;
	}

	return -1;
}
