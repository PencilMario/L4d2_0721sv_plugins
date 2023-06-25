#include <sourcemod>
#include <sdktools>

new String:giveorder[64];
new useridss;
new Handle:hRoundRespawn;

public Plugin:myinfo =
{
	name = "Give Item Menu",
	description = "Gives Item Menu by Ryanx",
	author = "Ryanx",
	version = "1.0.0",
	url = ""
};

public OnPluginStart()
{
	RegAdminCmd("rygive", RygiveMenu, 2, "rygive", "", 0);
	CreateConVar("rygive_version", "1.0.0", "rygive功能插件", 8512, false, 0.0, false, 0.0);
	new Handle:hRygiveCFG = LoadGameConfigFile("ry_give_fix");
	new Address:RFixAddr;
	if (hRygiveCFG)
	{
		RFixAddr = GameConfGetAddress(hRygiveCFG, "RYKnifeFix");
		StartPrepSDKCall(SDKCallType:2);
		PrepSDKCall_SetFromConf(hRygiveCFG, SDKFuncConfSource:1, "RoundRespawn");
		hRoundRespawn = EndPrepSDKCall();
		if (!hRoundRespawn)
		{
			SetFailState("复活指令无效");
		}
	}
	if (RFixAddr)
	{
		if (LoadFromAddress(RFixAddr, NumberType_Int8) == 107 && LoadFromAddress(RFixAddr + Address:4, NumberType_Int8) == 101)
		{
			StoreToAddress(RFixAddr, 75, NumberType_Int8);
			StoreToAddress(RFixAddr + Address:4, 97, NumberType_Int8);
		}
	}
	CloseHandle(hRygiveCFG);
}

public OnMapStart()
{
	SetConVarInt(FindConVar("z_spawn_flow_limit"), 999999, false, false);
	PrecacheModel("models/v_models/weapons/v_knife_t.mdl", true);
	PrecacheModel("models/w_models/weapons/w_knife_t.mdl", true);
	PrecacheGeneric("scripts/melee/knife.txt", true);
}

public Action:RygiveMenu(client, args)
{
	if (GetUserFlagBits(client))
	{
		Rygive(client);
		return Action:0;
	}
	ReplyToCommand(client, "[提示] 该功能只限管理员使用.");
	return Action:0;
}

public Action:Rygive(clientId)
{
	new Handle:menu = CreateMenu(RygiveMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "功能插件");
	AddMenuItem(menu, "option1", "手枪及近战", 0);
	AddMenuItem(menu, "option2", "微种及步枪", 0);
	AddMenuItem(menu, "option3", "散弹及狙击", 0);
	AddMenuItem(menu, "option4", "药品及投掷", 0);
	AddMenuItem(menu, "option5", "其它", 0);
	AddMenuItem(menu, "option6", "升级附件", 0);
	AddMenuItem(menu, "option7", "重复上次操作", 0);
	AddMenuItem(menu, "option8", "服务器人数设置", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, clientId, 0);
	return Action:3;
}

public RygiveMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		switch (itemNum)
		{
			case 0:
			{
				DisplaySMMenu(client);
			}
			case 1:
			{
				DisplaySRMenu(client);
			}
			case 2:
			{
				DisplaySSMenu(client);
			}
			case 3:
			{
				DisplayMTMenu(client);
			}
			case 4:
			{
				DisplayOTMenu(client);
			}
			case 5:
			{
				DisplayLUMenu(client);
			}
			case 6:
			{
				DisplayNLMenu(client);
			}
			case 7:
			{
				DisplaySLMenu(client);
			}
			default:
			{
			}
		}
	}
	return 0;
}

DisplaySMMenu(client)
{
	new Handle:menu = CreateMenu(SMMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "手枪及近战");
	AddMenuItem(menu, "pistol", "小手枪", 0);
	AddMenuItem(menu, "pistol_magnum", "马格南", 0);
	AddMenuItem(menu, "shovel", "铲子", 0);
	AddMenuItem(menu, "pitchfork", "干草叉", 0);
	AddMenuItem(menu, "knife", "小刀", 0);
	AddMenuItem(menu, "machete", "砍刀", 0);
	AddMenuItem(menu, "katana", "日本刀", 0);
	AddMenuItem(menu, "baseball_bat", "棒球棍", 0);
	AddMenuItem(menu, "cricket_bat", "板球棍", 0);
	AddMenuItem(menu, "fireaxe", "斧头", 0);
	AddMenuItem(menu, "frying_pan", "平底锅", 0);
	AddMenuItem(menu, "crowbar", "铁撬棍", 0);
	AddMenuItem(menu, "electric_guitar", "电吉他", 0);
	AddMenuItem(menu, "tonfa", "警棍", 0);
	AddMenuItem(menu, "weapon_chainsaw", "电锯", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public SMMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:getitemname[64];
		GetMenuItem(menu, itemNum, getitemname, 64);
		Format(giveorder, 64, "give %s", getitemname);
		DisplayNLMenu(client);
	}
	return 0;
}

DisplaySRMenu(client)
{
	new Handle:menu = CreateMenu(SRMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "微种及步枪");
	AddMenuItem(menu, "smg", "UZI", 0);
	AddMenuItem(menu, "smg_silenced", "MAC", 0);
	AddMenuItem(menu, "weapon_smg_mp5", "MP5", 0);
	AddMenuItem(menu, "rifle_ak47", "AK47", 0);
	AddMenuItem(menu, "rifle", "M16", 0);
	AddMenuItem(menu, "rifle_desert", "SCAR", 0);
	AddMenuItem(menu, "weapon_rifle_sg552", "SG552", 0);
	AddMenuItem(menu, "weapon_grenade_launcher", "榴弹枪", 0);
	AddMenuItem(menu, "rifle_m60", "M60", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public SRMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:getitemname[64];
		GetMenuItem(menu, itemNum, getitemname, 64);
		Format(giveorder, 64, "give %s", getitemname);
		DisplayNLMenu(client);
	}
	return 0;
}

DisplaySSMenu(client)
{
	new Handle:menu = CreateMenu(SSMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "散弹及狙击");
	AddMenuItem(menu, "pumpshotgun", "M870", 0);
	AddMenuItem(menu, "shotgun_chrome", "Chrome", 0);
	AddMenuItem(menu, "autoshotgun", "M1014", 0);
	AddMenuItem(menu, "shotgun_spas", "SPAS", 0);
	AddMenuItem(menu, "hunting_rifle", "M14", 0);
	AddMenuItem(menu, "sniper_military", "G3SG1", 0);
	AddMenuItem(menu, "weapon_sniper_scout", "Scout", 0);
	AddMenuItem(menu, "weapon_sniper_awp", "AWP", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public SSMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:getitemname[64];
		GetMenuItem(menu, itemNum, getitemname, 64);
		Format(giveorder, 64, "give %s", getitemname);
		DisplayNLMenu(client);
	}
	return 0;
}

DisplayMTMenu(client)
{
	new Handle:menu = CreateMenu(MTMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "药品及投掷");
	AddMenuItem(menu, "pain_pills", "药丸", 0);
	AddMenuItem(menu, "adrenaline", "肾上腺", 0);
	AddMenuItem(menu, "first_aid_kit", "医药包", 0);
	AddMenuItem(menu, "defibrillator", "电击器", 0);
	AddMenuItem(menu, "vomitjar", "胆汁", 0);
	AddMenuItem(menu, "pipe_bomb", "土制", 0);
	AddMenuItem(menu, "molotov", "燃烧瓶", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public MTMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:getitemname[64];
		GetMenuItem(menu, itemNum, getitemname, 64);
		Format(giveorder, 64, "give %s", getitemname);
		DisplayNLMenu(client);
	}
	return 0;
}

DisplayOTMenu(client)
{
	new Handle:menu = CreateMenu(OTMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "其它");
	AddMenuItem(menu, "health", "生命", 0);
	AddMenuItem(menu, "ammo", "子弹", 0);
	AddMenuItem(menu, "rmaddinf", "特感", 0);
	AddMenuItem(menu, "rffset", "友伤设置", 0);
	AddMenuItem(menu, "weapon_upgradepack_incendiary", "燃烧弹盒", 0);
	AddMenuItem(menu, "weapon_upgradepack_explosive", "高爆弹盒", 0);
	AddMenuItem(menu, "gascan", "汽油桶", 0);
	AddMenuItem(menu, "cola_bottles", "可乐瓶", 0);
	AddMenuItem(menu, "propanetank", "煤气罐", 0);
	AddMenuItem(menu, "oxygentank", "氧气瓶", 0);
	AddMenuItem(menu, "weapon_fireworkcrate", "烟花", 0);
	AddMenuItem(menu, "weapon_gnome", "圣诞老人", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public OTMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:getitemname[64];
		GetMenuItem(menu, itemNum, getitemname, 64);
		if (itemNum == 2)
		{
			DisplayRMIFMenu(client);
		}
		else if (itemNum == 3)
		{
			DisplayRFFMenu(client);
		}
		else
		{
			Format(giveorder, 64, "give %s", getitemname);
			DisplayNLMenu(client);
		}
	}
	return 0;
}

DisplayRFFMenu(client)
{
	new Handle:menu = CreateMenu(RFFMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "友伤设置");
	AddMenuItem(menu, "9.9", "恢复默认", 0);
	AddMenuItem(menu, "0.0", "0.0(简单)", 0);
	AddMenuItem(menu, "0.1", "0.1(普通)", 0);
	AddMenuItem(menu, "0.2", "0.2", 0);
	AddMenuItem(menu, "0.3", "0.3(困难)", 0);
	AddMenuItem(menu, "0.4", "0.4", 0);
	AddMenuItem(menu, "0.5", "0.5(专家)", 0);
	AddMenuItem(menu, "0.6", "0.6", 0);
	AddMenuItem(menu, "0.7", "0.7", 0);
	AddMenuItem(menu, "0.8", "0.8", 0);
	AddMenuItem(menu, "0.9", "0.9", 0);
	AddMenuItem(menu, "1.0", "1.0", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public RFFMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		if (itemNum)
		{
			new String:getFFnum[8];
			GetMenuItem(menu, itemNum, getFFnum, 6);
			new Float:RFFN = StringToFloat(getFFnum);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_easy"), RFFN, false, false);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_normal"), RFFN, false, false);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_hard"), RFFN, false, false);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_expert"), RFFN, false, false);
		}
		else
		{
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_easy"), 0.0, false, false);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_normal"), 0.1, false, false);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_hard"), 0.3, false, false);
			SetConVarFloat(FindConVar("survivor_friendly_fire_factor_expert"), 0.5, false, false);
		}
	}
	return 0;
}

DisplayRMIFMenu(client)
{
	new Handle:menu = CreateMenu(RMIFMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "特感");
	AddMenuItem(menu, "tank", "Tank坦克", 0);
	AddMenuItem(menu, "witch", "Witch女巫", 0);
	AddMenuItem(menu, "charger", "Charger牛哥", 0);
	AddMenuItem(menu, "hunter", "Hunter猎手", 0);
	AddMenuItem(menu, "jockey", "Jockey猴子", 0);
	AddMenuItem(menu, "smoker", "Smoker舌头", 0);
	AddMenuItem(menu, "spitter", "Spitter口水", 0);
	AddMenuItem(menu, "boomer", "Boomer胖子", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public RMIFMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:getitemname[64];
		GetMenuItem(menu, itemNum, getitemname, 64);
		Format(giveorder, 64, "z_spawn %s", getitemname);
		DisplayRafNLMenu(client);
	}
	return 0;
}

DisplayRafNLMenu(client)
{
	new String:namelist[64];
	new String:nameno[4];
	new Handle:menu = CreateMenu(RafNLMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "人物列表");
	new String:RIFMEID[8];
	Format(RIFMEID, 6, "%i", client);
	GetClientName(client, namelist, 64);
	Format(namelist, 64, "%s .(%d)", namelist, client);
	AddMenuItem(menu, RIFMEID, namelist, 0);
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && client != i)
		{
			GetClientName(i, namelist, 64);
			Format(namelist, 64, "%s .(%d)", namelist, i);
			Format(nameno, 3, "%i", i);
			AddMenuItem(menu, nameno, namelist, 0);
		}
		i++;
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public RafNLMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new flagsgv = GetCommandFlags("z_spawn");
		SetCommandFlags("z_spawn", flagsgv & -16385);
		new String:clientinfos[12];
		new userids;
		GetMenuItem(menu, itemNum, clientinfos, 10);
		userids = StringToInt(clientinfos, 10);
		FakeClientCommand(userids, giveorder);
		SetCommandFlags("z_spawn", flagsgv | 16384);
	}
	return 0;
}

DisplayLUMenu(client)
{
	new Handle:menu = CreateMenu(LUMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "升级附件&特殊");
	AddMenuItem(menu, "laser_sight", "红外线", 0);
	AddMenuItem(menu, "Incendiary_ammo", "燃烧子弹", 0);
	AddMenuItem(menu, "explosive_ammo", "高爆子弹", 0);
	AddMenuItem(menu, "respawns", "复活某人", 0);
	AddMenuItem(menu, "warp_all_survivors_heres", "传送", 0);
	AddMenuItem(menu, "slayinfected", "处死所有特感", 0);
	AddMenuItem(menu, "slayplayer", "处死所有玩家", 0);
	AddMenuItem(menu, "kickallbots", "踢除所有bot", 0);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public LUMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		if (itemNum <= 2)
		{
			new String:getitemname[64];
			GetMenuItem(menu, itemNum, getitemname, 64);
			Format(giveorder, 64, "upgrade_add %s", getitemname);
			DisplayNLMenu(client);
		}
		switch (itemNum)
		{
			case 3:
			{
				DisplayRPMenu(client);
			}
			case 4:
			{
				DisplayTEMenu(client);
			}
			case 5:
			{
				new ix = 1;
				while (ix <= MaxClients)
				{
					if (IsClientInGame(ix) && GetClientTeam(ix) != 2)
					{
						ForcePlayerSuicide(ix);
					}
					ix++;
				}
			}
			case 6:
			{
				new ix = 1;
				while (ix <= MaxClients)
				{
					if (IsClientInGame(ix) && GetClientTeam(ix) == 2 && IsPlayerAlive(ix))
					{
						ForcePlayerSuicide(ix);
					}
					ix++;
				}
			}
			case 7:
			{
				new ix = 1;
				while (ix <= MaxClients)
				{
					if (IsClientInGame(ix) && GetClientTeam(ix) == 2 && IsFakeClient(ix))
					{
						KickClient(ix, "");
					}
					ix++;
				}
				PrintToChatAll("\x05[提示]\x03 踢除所有bot.");
			}
			default:
			{
			}
		}
	}
	return 0;
}

DisplayNLMenu(client)
{
	new String:namelist[64];
	new String:nameno[4];
	new Handle:menu = CreateMenu(NLMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "人物列表");
	AddMenuItem(menu, "allplayer", "<所有人>", 0);
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			GetClientName(i, namelist, 64);
			Format(namelist, 64, "%s .(%d)", namelist, i);
			Format(nameno, 3, "%i", i);
			AddMenuItem(menu, nameno, namelist, 0);
		}
		i++;
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public NLMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new flagsgv = GetCommandFlags("give");
		SetCommandFlags("give", flagsgv & -16385);
		new flagsup = GetCommandFlags("upgrade_add");
		SetCommandFlags("upgrade_add", flagsup & -16385);
		new String:clientinfos[12];
		new userids;
		GetMenuItem(menu, itemNum, clientinfos, 10);
		userids = StringToInt(clientinfos, 10);
		if (StrEqual(clientinfos, "allplayer", true))
		{
			if (StrEqual(giveorder, "give health"))
			{
				CreateTimer(0.04, GiveHealthAll, 1);
			}
			else
			{
				new ix = 1;
				while (ix <= MaxClients)
				{
					if (IsClientInGame(ix) && GetClientTeam(ix) == 2 && IsPlayerAlive(ix))
					{
						FakeClientCommand(ix, giveorder);
						// PrintToChatAll("%N", ix);
					}
					ix++;
				}
			}
		}
		else
		{
			FakeClientCommand(userids, giveorder);
		}
		SetCommandFlags("give", flagsgv | 16384);
		SetCommandFlags("upgrade_add", flagsup | 16384);
	}
	return 0;
}

public Action GiveHealthAll(Handle timer, int client)
{
	if (client > MAXPLAYERS) return Plugin_Stop;
	while (client <= 32)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
		{
			if (!IsPlayerIncapped(client) && !IsPlayerGrapEdge(client))
			{
				GiveHealth(client);
				client += 1;
			}
			else
			{
				GiveHealth(client);
				client += 1;
				CreateTimer(0.04, GiveHealthAll, client);
				break;
			}
		}
		else
		{
			client += 1;
		}
	}
	return Plugin_Continue;
}

bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
 	return false;
}
bool:IsPlayerGrapEdge(client)
{
 	if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge", 1))return true;
	return false;
}

GiveHealth(client)
{
	// PrintToChatAll("%s: %d", giveorder, client)
	new flagsgv = GetCommandFlags("give");
	SetCommandFlags("give", flagsgv & -16385);
	FakeClientCommand(client, giveorder);
	SetCommandFlags("give", flagsgv | 16384);
}

DisplayRPMenu(client)
{
	new String:namelist[64];
	new String:nameno[4];
	new Handle:menu = CreateMenu(RPMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "复活列表");
	AddMenuItem(menu, "alldead", "所有<死人>", 0);
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && !IsPlayerAlive(i))
		{
			GetClientName(i, namelist, 64);
			Format(namelist, 64, "%s .(%d)", namelist, i);
			Format(nameno, 3, "%i", i);
			AddMenuItem(menu, nameno, namelist, 0);
		}
		i++;
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public RPMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:clientinfos[12];
		new userids;
		GetMenuItem(menu, itemNum, clientinfos, 10);
		userids = StringToInt(clientinfos, 10);
		decl Float:vAngles1[3];
		decl Float:vOrigin1[3];
		new i = 1;
		while (i <= MaxClients)
		{
			if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
			{
				GetClientAbsOrigin(i, vOrigin1);
				GetClientAbsAngles(i, vAngles1);
				if (StrEqual(clientinfos, "alldead", true))
				{
					new ix = 1;
					while (ix <= MaxClients)
					{
						if (IsClientInGame(ix) && GetClientTeam(ix) == 2 && !IsPlayerAlive(ix))
						{
							SDKCall(hRoundRespawn, ix);
							TeleportEntity(ix, vOrigin1, vAngles1, NULL_VECTOR);
							new flagsgv = GetCommandFlags("give");
							SetCommandFlags("give", flagsgv & -16385);
							FakeClientCommand(ix, "give smg_silenced");
							SetCommandFlags("give", flagsgv | 16384);
						}
						ix++;
					}
				}
				else
				{
					SDKCall(hRoundRespawn, userids);
					TeleportEntity(userids, vOrigin1, vAngles1, NULL_VECTOR);
					new flagsgv = GetCommandFlags("give");
					SetCommandFlags("give", flagsgv & -16385);
					FakeClientCommand(userids, "give smg_silenced");
					SetCommandFlags("give", flagsgv | 16384);
				}
			}
			i++;
		}
		if (StrEqual(clientinfos, "alldead", true))
		{
			new ix = 1;
			while (ix <= MaxClients)
			{
				if (IsClientInGame(ix) && GetClientTeam(ix) == 2 && !IsPlayerAlive(ix))
				{
					SDKCall(hRoundRespawn, ix);
					TeleportEntity(ix, vOrigin1, vAngles1, NULL_VECTOR);
				}
				ix++;
			}
		}
		else
		{
			SDKCall(hRoundRespawn, userids);
			TeleportEntity(userids, vOrigin1, vAngles1, NULL_VECTOR);
		}
	}
	return 0;
}

DisplayTEMenu(client)
{
	new String:namelist[64];
	new String:nameno[4];
	new Handle:menu = CreateMenu(TEMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "传送谁");
	AddMenuItem(menu, "6689", "所有<幸存者>", 0);
	AddMenuItem(menu, "6699", "所有<特感>", 0);
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			GetClientName(i, namelist, 64);
			Format(namelist, 64, "%s .(%d)", namelist, i);
			Format(nameno, 3, "%i", i);
			AddMenuItem(menu, nameno, namelist, 0);
		}
		i++;
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public TEMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:clientinfos[12];
		GetMenuItem(menu, itemNum, clientinfos, 10);
		useridss = StringToInt(clientinfos, 10);
		DisplayTELMenu(client);
	}
	return 0;
}

DisplayTELMenu(client)
{
	new String:namelist[64];
	new String:nameno[4];
	new Handle:menu = CreateMenu(TELMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "传送到谁那里");
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && i != useridss)
		{
			GetClientName(i, namelist, 64);
			Format(namelist, 64, "%s .(%d)", namelist, i);
			Format(nameno, 3, "%i", i);
			AddMenuItem(menu, nameno, namelist, 0);
		}
		i++;
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public TELMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:clientinfos[12];
		new userids;
		GetMenuItem(menu, itemNum, clientinfos, 10);
		userids = StringToInt(clientinfos, 10);
		decl Float:vAngles[3];
		decl Float:vOrigin[3];
		GetClientAbsOrigin(userids, vOrigin);
		GetClientAbsAngles(userids, vAngles);
		if (useridss == 6689)
		{
			new ix = 1;
			while (ix <= MaxClients)
			{
				if (IsClientInGame(ix) && GetClientTeam(ix) == 2 && IsPlayerAlive(ix) && ix != userids)
				{
					TeleportEntity(ix, vOrigin, vAngles, NULL_VECTOR);
				}
				ix++;
			}
		}
		else
		{
			if (useridss == 6699)
			{
				new ix = 1;
				while (ix <= MaxClients)
				{
					if (IsClientInGame(ix) && GetClientTeam(ix) == 3 && IsPlayerAlive(ix) && ix != userids)
					{
						TeleportEntity(ix, vOrigin, vAngles, NULL_VECTOR);
					}
					ix++;
				}
			}
			TeleportEntity(useridss, vOrigin, vAngles, NULL_VECTOR);
		}
	}
	return 0;
}

DisplaySLMenu(client)
{
	new String:namelist[64];
	new String:nameno[4];
	new Handle:menu = CreateMenu(SLMenuHandler, MenuAction:28);
	SetMenuTitle(menu, "服务器人数");
	new i = 1;
	while (i <= 16)
	{
		Format(nameno, 3, "%i", i);
		AddMenuItem(menu, nameno, namelist, 0);
		i++;
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	return 0;
}

public SLMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if (action == MenuAction:4)
	{
		new String:clientinfos[12];
		new userids;
		GetMenuItem(menu, itemNum, clientinfos, 10);
		userids = StringToInt(clientinfos, 10);
		FakeClientCommand(client, "sm_cvar sv_maxplayers %i", userids);
		FakeClientCommand(client, "sm_cvar sv_visiblemaxplayers %i", userids);
	}
	return 0;
}
