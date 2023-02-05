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

#define MIX_TYPE_SIZE           16
#define VOTE_TITLE_SIZE         128
#define VOTE_MSG_SIZE           128


native int AddMixType(char[] sName, int iMinPlayers);

native int GetMixState();

native int GetMixType();

native int CallCancelMix();

native int CallEndMix();

native int IsMixMember(int iClient);

native int GetLastTeam(int iClient);

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