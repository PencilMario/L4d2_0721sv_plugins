/**
 * =============================================================================
 * Copyright https://steamcommunity.com/id/dr_lex/
 *
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <www.sourcemod.net/license.php>.
 *
*/

#pragma semicolon 1
#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#include <sdkhooks>

#tryinclude <l4d2_changelevel>

TopMenu hTopMenuHandle;

char sg_file[160];
char sBuffer[128];
char sMode[32];
char sNum[64];
char sNumFileTxt[128];
char sName[256];
int iList;

public Plugin myinfo = 
{
	name = "[l4d2] List of missions",
	author = "dr.lex (Exclusive Coop-17)",
	description = "Automatic reading of all available campaigns",
	version = "1.2.1",
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_amaps", CMD_AMaps, ADMFLAG_UNBAN, "");
	RegAdminCmd("sm_aupdate", CMD_AUpdate, ADMFLAG_UNBAN, "");
	RegConsoleCmd("sm_votedlc", CMD_VoteDlc, "", 0);
	
	TopMenu hTop_Menu;
	if (LibraryExists("adminmenu") && ((hTop_Menu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(hTop_Menu);
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == hTopMenuHandle)
	{
		return;
	}
	
	hTopMenuHandle = view_as<TopMenu>(topmenu);
	TopMenuObject ServerCmdCategory = hTopMenuHandle.FindCategory(ADMINMENU_SERVERCOMMANDS);
	if (ServerCmdCategory != INVALID_TOPMENUOBJECT)
	{
		hTopMenuHandle.AddItem("sm_amaps", AdminMenu_Maps, ServerCmdCategory, "sm_amaps", ADMFLAG_UNBAN);
	}
}

public void AdminMenu_Maps(TopMenu Top_Menu, TopMenuAction action, TopMenuObject object_id, int param, char[] Buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(Buffer, maxlength, "List of Companies (Maps)");
		case TopMenuAction_SelectOption: CMD_AMaps(param, 0);
	}
}

public Action CMD_AMaps(int client, int args)
{
	if (client)
	{
		ConVar g_Mode = FindConVar("mp_gamemode");
		GetConVarString(g_Mode, sMode, sizeof(sMode));
		
		iList = 0;
		
		KeyValues hGM = new KeyValues("missions");
		Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/basic_dlc.txt");
		hGM.ImportFromFile(sg_file);
		if (hGM.JumpToKey("Total"))
		{
			iList = hGM.GetNum("List", 0);
			hGM.GoBack();
		}
		delete hGM;
		
		if (1 <= iList)
		{
			Menu menu = new Menu(AMapsHandler);
			menu.SetTitle("List of Companies (Maps)");
			menu.AddItem("1", "Campaigns");
			menu.AddItem("2", "DLC Campaigns");
			menu.ExitBackButton = true;
			menu.Display(client, 30);
		}
		else
		{
			ACampaign(client);
		}
	}
	return Plugin_Handled;
}

public Action CMD_AUpdate(int client, int args)
{
	HxDelMissionsList();
	HxUpdateMissionsList();
	return Plugin_Handled;
}

public Action CMD_VoteDlc(int client, int args)
{
	ConVar g_Mode = FindConVar("mp_gamemode");
	GetConVarString(g_Mode, sMode, sizeof(sMode));
	
	iList = 0;
	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/basic_dlc.txt");
	hGM.ImportFromFile(sg_file);
	if (hGM.JumpToKey("Total"))
	{
		iList = hGM.GetNum("List", 0);
		hGM.GoBack();
	}
	
	if (1 <= iList)
	{
		Menu menu = new Menu(MenuHandlerDlcCampaignVote);
		menu.SetTitle("List of DLC:Companies (Vote)");
		
		if (hGM.JumpToKey("DLC"))
		{
			int i = 1;
			while (i <= iList)
			{
				Format(sNum, sizeof(sNum), "%i", i);
				char sFileDlc[256];
				hGM.GetString(sNum, sFileDlc, sizeof(sFileDlc)-1, "");
				
				MissionsMenuDLC(menu, sFileDlc);
				i += 1;
			}
			hGM.GoBack();
		}
		
		menu.ExitButton = false;
		menu.Display(client, 30);
	}
	delete hGM;
	return Plugin_Handled;
}

public int AMapsHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			if (strcmp(info, "1") == 0)
			{
				ACampaign(param1);
			}
			if (strcmp(info, "2") == 0)
			{
				ADlcCampaign(param1);
			}		
		}
	}
	return 0;
}

public Action ACampaign(int client)
{
	Menu menu = new Menu(ACampaignHandler);
	menu.SetTitle("List of Companies (Maps)");
	
	MissionsMenu(menu, 1);
	MissionsMenu(menu, 6);
	MissionsMenu(menu, 2);
	MissionsMenu(menu, 3);
	MissionsMenu(menu, 4);
	MissionsMenu(menu, 5);
	MissionsMenu(menu, 7);
	MissionsMenu(menu, 8);
	MissionsMenu(menu, 9);
	MissionsMenu(menu, 10);
	MissionsMenu(menu, 11);
	MissionsMenu(menu, 12);
	MissionsMenu(menu, 13);
	MissionsMenu(menu, 14);
	
	if (1 <= iList)
	{
		menu.ExitBackButton = true;
	}
	menu.ExitButton = false;
	menu.Display(client, 30);
	return Plugin_Handled;
}

stock void MissionsMenu(Menu menu, int campaign)
{
	sName[0] = '\0';
	switch (campaign)
	{
		case 1: sName = "Dead Center";
		case 2: sName = "Dark Carnival";
		case 3: sName = "Swamp Fever";
		case 4: sName = "Hard Rain";
		case 5: sName = "The Parish";
		case 6: sName = "The Passing";
		case 7: sName = "The Sacrifice";
		case 8: sName = "No Mercy";
		case 9: sName = "Crash Course";
		case 10: sName = "Death Toll";
		case 11: sName = "Dead Airl";
		case 12: sName = "Blood Harvest";
		case 13: sName = "Cold Stream";
		case 14: sName = "The Last Stand";
	}
	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/campaign%i.txt", campaign);
	hGM.ImportFromFile(sg_file);
	if (hGM.JumpToKey("modes"))
	{
		if (hGM.JumpToKey(sMode))
		{
			Format(sNum, sizeof(sNum), "%i", campaign);
			menu.AddItem(sNum, sName);
			hGM.GoBack();
		}
		hGM.GoBack();
	}
	delete hGM;
}

public int ACampaignHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			int iNum = StringToInt(info);
			ACampaignNum(param1, iNum);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				CMD_AMaps(param1, 0);
			}
		}
	}
	return 0;
}

stock void ACampaignNum(int client, int campaigns)
{
	sName[0] = '\0';
	switch (campaigns)
	{
		case 1: sName = "Dead Center";
		case 2: sName = "Dark Carnival";
		case 3: sName = "Swamp Fever";
		case 4: sName = "Hard Rain";
		case 5: sName = "The Parish";
		case 6: sName = "The Passing";
		case 7: sName = "The Sacrifice";
		case 8: sName = "No Mercy";
		case 9: sName = "Crash Course";
		case 10: sName = "Death Toll";
		case 11: sName = "Dead Airl";
		case 12: sName = "Blood Harvest";
		case 13: sName = "Cold Stream";
		case 14: sName = "The Last Stand";
	}
	
	Format(sNumFileTxt, 40-1, "campaign%i.txt", campaigns);

	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/%s", sNumFileTxt);
	hGM.ImportFromFile(sg_file);
	
	Menu menu = new Menu(ACampaignNumHandler);
	menu.SetTitle("%s [Maps]", sName);
	
	if (hGM.JumpToKey("modes"))
	{
		if (hGM.JumpToKey(sMode))
		{
			int i = 1;
			int l = 1;
			while (i <= l)
			{
				Format(sNum, sizeof(sNum), "%i", i);
				if (hGM.JumpToKey(sNum))
				{
					l += 1;
					char sMapText[256];
					hGM.GetString("Map", sMapText, sizeof(sMapText)-1, "");
					
					Format(sBuffer, sizeof(sBuffer)-1, "Map #%i: %s", i, sMapText);
					menu.AddItem(sNum, sBuffer);
					hGM.GoBack();
				}
				i += 1;
			}
		}
	}
	delete hGM;
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 30);
}

public int ACampaignNumHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			int iNum = StringToInt(info);
			CampaignNumMap(param1, iNum, 0);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ACampaign(param1);
			}
		}
	}
	return 0;
}

stock void CampaignNumMap(int client, int iMaps, int iVote)
{	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/%s", sNumFileTxt);
	hGM.ImportFromFile(sg_file);
	if (hGM.JumpToKey("modes"))
	{
		if (hGM.JumpToKey(sMode))
		{
			Format(sNum, sizeof(sNum), "%i", iMaps);
			if (hGM.JumpToKey(sNum))
			{
				char sMapText[256];
				hGM.GetString("Map", sMapText, sizeof(sMapText)-1, "");
				
				if (iVote)
				{
					FakeClientCommand(client, "callvote changelevel %s", sMapText);
				}
				else
				{
				#if defined _l4d2_changelevel_included
					L4D2_ChangeLevel(sMapText);
				#else
					ServerCommand("changelevel %s", sMapText);
				#endif
				}
			}
		}
	}
	delete hGM;
}

public Action ADlcCampaign(int client)
{
	iList = 0;
	
	Menu menu = new Menu(ADlcCampaignHandler);
	menu.SetTitle("List of DLC:Companies (Maps)");
	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/basic_dlc.txt");
	hGM.ImportFromFile(sg_file);
	if (hGM.JumpToKey("Total"))
	{
		iList = hGM.GetNum("List", 0);
		hGM.GoBack();
	}
	if (hGM.JumpToKey("DLC"))
	{
		int i = 1;
		while (i <= iList)
		{
			Format(sNum, sizeof(sNum), "%i", i);
			char sFileDlc[256];
			hGM.GetString(sNum, sFileDlc, sizeof(sFileDlc)-1, "");
			
			MissionsMenuDLC(menu, sFileDlc);
			i += 1;
		}
		hGM.GoBack();
	}
	delete hGM;
	
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 30);
	return Plugin_Handled;
}

stock void MissionsMenuDLC(Menu menu, char[] campaign)
{	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/%s", campaign);
	hGM.ImportFromFile(sg_file);
	
	char sDisplayTitle[256];
	hGM.GetString("DisplayTitle", sDisplayTitle, sizeof(sDisplayTitle)-1, "");
	
	if (hGM.JumpToKey("modes"))
	{
		if (hGM.JumpToKey(sMode))
		{
			Format(sNum, sizeof(sNum), "%s", campaign);
			menu.AddItem(sNum, sDisplayTitle);
			hGM.GoBack();
		}
		hGM.GoBack();
	}
	delete hGM;
}

public int ADlcCampaignHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			ADlcCampaignNum(param1, info);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				CMD_AMaps(param1, 0);
			}
		}
	}
	return 0;
}

stock void ADlcCampaignNum(int client, char[] campaigns)
{
	Format(sNumFileTxt, 40-1, "%s", campaigns);
	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/%s", sNumFileTxt);
	hGM.ImportFromFile(sg_file);
	
	char sDisplayTitle[256];
	hGM.GetString("DisplayTitle", sDisplayTitle, sizeof(sDisplayTitle)-1, "");
	
	Menu menu = new Menu(ADlcCampaignNumHandler);
	menu.SetTitle("%s [Maps]", sDisplayTitle);
	
	if (hGM.JumpToKey("modes"))
	{
		if (hGM.JumpToKey(sMode))
		{
			int i = 1;
			int l = 1;
			while (i <= l)
			{
				Format(sNum, sizeof(sNum), "%i", i);
				if (hGM.JumpToKey(sNum))
				{
					l += 1;
					char sMapText[256];
					hGM.GetString("Map", sMapText, sizeof(sMapText)-1, "");
					char sDisplayNameText[256];
					hGM.GetString("DisplayName", sDisplayNameText, sizeof(sDisplayNameText)-1, "");
					
					Format(sBuffer, sizeof(sBuffer)-1, "Map #%i: %s [%s]", i, sDisplayNameText, sMapText);
					menu.AddItem(sNum, sBuffer);
					hGM.GoBack();
				}
				i += 1;
			}
		}
	}
	delete hGM;
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 30);
}

public int ADlcCampaignNumHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			int iNum = StringToInt(info);
			CampaignNumMap(param1, iNum, 0);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ADlcCampaign(param1);
			}
		}
	}
	return 0;
}

//==========================================
stock void HxDelMissionsList()
{
	DirectoryListing dirList = OpenDirectory("addons/sourcemod/data/missions", true, NULL_STRING);
	if (dirList != null)
	{
		FileType type;
		while (dirList.GetNext(sBuffer, sizeof(sBuffer), type))
		{
			if (type == FileType_File)
			{
				Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/%s", sBuffer);
				DeleteFile(sg_file, true, NULL_STRING);
			}
		}
	}
	delete dirList;
}

stock void HxUpdateMissionsList()
{
	char dirName[256];
	Format(dirName, sizeof(dirName), "addons/sourcemod/data/missions");
	CreateDirectory(dirName, 511);
	
	DirectoryListing dirList = OpenDirectory("missions", true, NULL_STRING);
	if (dirList != null)
	{
		BuildPath(Path_SM, sg_file, sizeof(sg_file)-1, "data/missions/basic_dlc.txt");
		
		int i = 0;
		FileType type;
		
		KeyValues hGM = new KeyValues("missions");
		hGM.ImportFromFile(sg_file);
		hGM.JumpToKey("DLC", true);
		char sPath[128];
		while (dirList.GetNext(sBuffer, sizeof(sBuffer), type))
		{
			if (type == FileType_File)
			{
				if (StrEqual(sBuffer, "campaign1.txt") || StrEqual(sBuffer, "campaign2.txt") || StrEqual(sBuffer, "campaign3.txt") || StrEqual(sBuffer, "campaign4.txt") || StrEqual(sBuffer, "campaign5.txt") || StrEqual(sBuffer, "campaign6.txt") || StrEqual(sBuffer, "campaign7.txt") || StrEqual(sBuffer, "campaign8.txt") || StrEqual(sBuffer, "campaign9.txt") || StrEqual(sBuffer, "campaign10.txt") || StrEqual(sBuffer, "campaign11.txt") || StrEqual(sBuffer, "campaign12.txt") || StrEqual(sBuffer, "campaign13.txt") || StrEqual(sBuffer, "campaign14.txt") || StrEqual(sBuffer, "credits.txt") || StrEqual(sBuffer, "holdoutchallenge.txt") || StrEqual(sBuffer, "holdouttraining.txt") || StrEqual(sBuffer, "parishdash.txt") || StrEqual(sBuffer, "shootzones.txt") || StrEqual(sBuffer, "jtsm.txt"))
				{
					//continue;
				}
				else
				{
					i += 1;
					Format(sPath, sizeof(sPath), "%i", i);
					hGM.SetString(sPath, sBuffer);
				}
				
				char sPath2[512];
				Format(sPath2, sizeof(sPath2), "missions/%s", sBuffer);
				File f = OpenFile(sPath2, "rt", true, NULL_STRING);
				if (f)
				{
					char sText[256];
					while (!f.EndOfFile() && f.ReadLine(sText, sizeof(sText)))
					{
						TrimString(sText);
						char sPath3[256];
						Format(sPath3, sizeof(sPath3), "addons/sourcemod/data/missions/%s", sBuffer);						
						File hFile = OpenFile(sPath3, "at");
						WriteFileLine(hFile, sText);
						delete hFile;
					}
					delete f;
				}
			}
		}
		hGM.GoBack();
		
		hGM.JumpToKey("Total", true);
		hGM.SetNum("List", i);
		
		hGM.Rewind();
		hGM.ExportToFile(sg_file);
		delete hGM;
	}
	delete dirList;
}

public int MenuHandlerDlcCampaignVote(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			CampaignNumDlcVote(param1, info);
		}
	}
	return 0;
}

stock void CampaignNumDlcVote(int client, char[] campaigns)
{
	Format(sNumFileTxt, 40-1, "%s", campaigns);
	
	KeyValues hGM = new KeyValues("missions");
	Format(sg_file, sizeof(sg_file), "addons/sourcemod/data/missions/%s", sNumFileTxt);
	hGM.ImportFromFile(sg_file);
	
	if (StrEqual(sMode, "coop") || StrEqual(sMode, "versus"))
	{
		sName[0] = '\0';
		hGM.GetString("Name", sName, sizeof(sName)-1, "");
		FakeClientCommand(client, "callvote ChangeMission %s", sName);
	}
	else
	{
		char sDisplayTitle[256];
		hGM.GetString("DisplayTitle", sDisplayTitle, sizeof(sDisplayTitle)-1, "");
	
		Menu menu = new Menu(MenuHandlerDlcVoteMode);
		menu.SetTitle("%s [Maps]", sDisplayTitle);
		
		if (hGM.JumpToKey("modes"))
		{
			if (hGM.JumpToKey(sMode))
			{
				int i = 1;
				int l = 1;
				while (i <= l)
				{
					Format(sNum, sizeof(sNum), "%i", i);
					if (hGM.JumpToKey(sNum))
					{
						l += 1;
						char sMapText[256];
						hGM.GetString("Map", sMapText, sizeof(sMapText)-1, "");
						char sDisplayNameText[256];
						hGM.GetString("DisplayName", sDisplayNameText, sizeof(sDisplayNameText)-1, "");
						
						Format(sBuffer, sizeof(sBuffer)-1, "Map #%i: %s [%s]", i, sDisplayNameText, sMapText);
						menu.AddItem(sNum, sBuffer);
						hGM.GoBack();
					}
					i += 1;
				}
			}
		}
		
		menu.ExitBackButton = true;
		menu.ExitButton = false;
		menu.Display(client, 30);
	}
	delete hGM;
}

stock int MenuHandlerDlcVoteMode(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			int iNum = StringToInt(info);
			CampaignNumMap(param1, iNum, 1);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				CMD_VoteDlc(param1, 0);
			}
		}
	}
	return 0;
}