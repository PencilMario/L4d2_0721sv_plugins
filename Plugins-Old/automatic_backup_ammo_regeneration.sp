#pragma tabsize 0
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION	"1.10.10"

#define DATA_PATH   "data/automatic_backup_ammo_regeneration_weapons.cfg"
#define KV_ROOT     "automatic_backup_ammo_regeneration"
#define CONFIRM     "confirm"
#define CMD_FLUSH   "sm_abar_flush"
#define CMD_RELOAD  "sm_abar_reload"
#define CMD_LIST    "sm_abar_list"
#define CMD_QUERY   "sm_abar_query"
#define CMD_CHANGE  "sm_abar_change"
#define CMD_REMOVE  "sm_abar_remove"

static const char Original_configs[][PLATFORM_MAX_PATH] = 
{
    "\"automatic_backup_ammo_regeneration\"",
    "{",
    "\t\"weapon_rifle\"",
    "\t{",
    "\t\t\"max\"\t\t\"30\"",
    "\t}",
    "\t\"weapon_rifle_ak47\"",
    "\t{",
    "\t\t\"max\"\t\t\"24\"",
    "\t}",
    "\t\"weapon_rifle_desert\"",
    "\t{",
    "\t\t\"max\"\t\t\"36\"",
    "\t}",
    "\t\"weapon_rifle_sg552\"",
    "\t{",
    "\t\t\"max\"\t\t\"30\"",
    "\t}",
    "\t\"weapon_autoshotgun\"",
    "\t{",
    "\t\t\"max\"\t\t\"6\"",
    "\t}",
    "\t\"weapon_shotgun_spas\"",
    "\t{",
    "\t\t\"max\"\t\t\"6\"",
    "\t}",
    "\t\"weapon_pumpshotgun\"",
    "\t{",
    "\t\t\"max\"\t\t\"5\"",
    "\t}",
    "\t\"weapon_shotgun_chrome\"",
    "\t{",
    "\t\t\"max\"\t\t\"5\"",
    "\t}",
    "\t\"weapon_smg\"",
    "\t{",
    "\t\t\"max\"\t\t\"30\"",
    "\t}",
    "\t\"weapon_smg_silenced\"",
    "\t{",
    "\t\t\"max\"\t\t\"30\"",
    "\t}",
    "\t\"weapon_smg_mp5\"",
    "\t{",
    "\t\t\"max\"\t\t\"30\"",
    "\t}",
    "\t\"weapon_hunting_rifle\"",
    "\t{",
    "\t\t\"max\"\t\t\"9\"",
    "\t}",
    "\t\"weapon_sniper_awp\"",
    "\t{",
    "\t\t\"max\"\t\t\"12\"",
    "\t}",
    "\t\"weapon_sniper_military\"",
    "\t{",
    "\t\t\"max\"\t\t\"18\"",
    "\t}",
    "\t\"weapon_sniper_scout\"",
    "\t{",
    "\t\t\"max\"\t\t\"9\"",
    "\t}",
    "\t\"weapon_rifle_m60\"",
    "\t{",
    "\t\t\"max\"\t\t\"-1\"",
    "\t}",
    "\t\"weapon_grenade_launcher\"",
    "\t{",
    "\t\t\"max\"\t\t\"-1\"",
    "\t}",
    "}"
};

char Save_path[PLATFORM_MAX_PATH];
KeyValues G_kv;

ConVar C_debug;

bool O_debug;

bool is_valid_client_index(int client)
{
	return client >= 1 && client <= MaxClients;
}

bool is_valid_client_at_team(int client, int team)
{
	return is_valid_client_index(client) && IsClientInGame(client) && GetClientTeam(client) == team;
}

int get_current_use_action(int client)
{
    return GetEntProp(client, Prop_Send, "m_iCurrentUseAction");
}

int get_revive_target(int client)
{
    return GetEntPropEnt(client, Prop_Send, "m_reviveTarget");
}

int get_active_weapon(int client)
{
    return GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
}

int get_weapon_clip(int weapon)
{
    return GetEntProp(weapon, Prop_Data, "m_iClip1");
}

void set_weapon_clip(int weapon, int clip)
{
    SetEntProp(weapon, Prop_Data, "m_iClip1", clip);
}

int get_weapon_ammo_type(int weapon)
{
    return GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");
}

int get_weapon_backup_ammo(int owner, int weapon)
{
    return GetEntProp(owner, Prop_Data, "m_iAmmo", _, get_weapon_ammo_type(weapon));
}

void set_weapon_backup_ammo(int owner, int weapon, int ammo)
{
    SetEntProp(owner, Prop_Data, "m_iAmmo", ammo, _, get_weapon_ammo_type(weapon));
}

stock void DEBUG_clear_ammo_all()
{
    for(int client = 1; client <= MaxClients; client++)
    {
        if(is_valid_client_at_team(client, 2) && IsPlayerAlive(client))
        {
            int primary = GetPlayerWeaponSlot(client, 0);
            if(primary > 0)
            {
                set_weapon_clip(primary, 0);
                set_weapon_backup_ammo(client, primary, 0);
            } 
        }
    }
}

bool is_survivor_falling(int client)
{
	return GetEntProp(client, Prop_Send, "m_isHangingFromLedge") != 0;
}

bool is_survivor_flying_or_standing(int client)
{
	char model[PLATFORM_MAX_PATH];
	GetEntPropString(client, Prop_Data, "m_ModelName", model, PLATFORM_MAX_PATH);
    int sequence = GetEntProp(client, Prop_Send, "m_nSequence");
	switch(model[29])
	{
		case 'b'://nick
		{
			switch(sequence)
			{
				case 661, 667, 669, 671, 672, 627, 628, 629, 630, 620:
					return true;
			}
		}
		case 'd'://rochelle
		{
			switch(sequence)
			{
				case 668, 674, 676, 678, 679, 635, 636, 637, 638, 629:
					return true;
			}
		}
		case 'c'://coach
		{
			switch(sequence)
			{
				case 650, 656, 658, 660, 661, 627, 628, 629, 630, 621:
					return true;
			}
		}
		case 'h'://ellis
		{
			switch(sequence)
			{
				case 665, 671, 673, 675, 676, 632, 633, 634, 635, 625:
					return true;
			}
		}
		case 'v'://bill
		{
			switch(sequence)
			{
				case 753, 759, 761, 763, 764, 535, 536, 537, 538, 528:
					return true;
			}
		}
		case 'n'://zoey
		{
			switch(sequence)
			{
				case 813, 819, 821, 823, 824, 544, 545, 546, 547, 537:
					return true;
			}
		}
		case 'e'://francis
		{
			switch(sequence)
			{
				case 756, 762, 764, 766, 767, 538, 539, 540, 541, 531:
					return true;
			}
		}
		case 'a'://louis
		{
			switch(sequence)
			{
				case 753, 759, 761, 763, 764, 535, 536, 537, 538, 528:
					return true;
			}
		}
	}
	return false;
}

bool is_survivor_pinned_ex(int client)
{
    if(GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0)
    {
        char model[PLATFORM_MAX_PATH];
	    GetEntPropString(client, Prop_Data, "m_ModelName", model, PLATFORM_MAX_PATH);
        int sequence = GetEntProp(client, Prop_Send, "m_nSequence");
	    switch(model[29])
	    {
            case 'b'://nick
            {
                switch(sequence)
                {
                    case 607:
                        return false;
                }
            }
            case 'd'://rochelle
            {
                switch(sequence)
                {
                    case 616:
                        return false;
                }
            }
            case 'c'://coach
            {
                switch(sequence)
                {
                    case 608:
                        return false;
                }
            }
            case 'h'://ellis
            {
                switch(sequence)
                {
                    case 612:
                        return false;
                }
            }
            case 'v'://bill
            {
                switch(sequence)
                {
                    case 516:
                        return false;
                }
            }
            case 'n'://zoey
            {
                switch(sequence)
                {
                    case 520:
                        return false;
                }
            }
            case 'e'://francis
            {
                switch(sequence)
                {
                    case 519:
                        return false;
                }
            }
            case 'a'://louis
            {
                switch(sequence)
                {
                    case 516:
                        return false;
                }
            }
	    }
        return true;
    }
    else
    {
        return GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0;
    }
}

public Action OnPlayerRunCmd(int client, int& buttons)
{
    if(is_valid_client_at_team(client, 2) && IsPlayerAlive(client))
    {

        if(O_debug == true)
        {
            if(!IsFakeClient(client) && buttons & IN_SPEED)
            {
                DEBUG_clear_ammo_all();
            }
        }

        if(is_survivor_falling(client) || is_survivor_pinned_ex(client) || is_survivor_flying_or_standing(client) || get_current_use_action(client) != 0 || get_revive_target(client) != -1)
        {
            return Plugin_Continue;
        }
        int primary = GetPlayerWeaponSlot(client, 0);
        if(primary < 0)
        {
            return Plugin_Continue;
        }
        char class_name[PLATFORM_MAX_PATH];
        GetEntityClassname(primary, class_name, PLATFORM_MAX_PATH);
        G_kv.Rewind();
        if(!G_kv.JumpToKey(class_name, false))
        {
            return Plugin_Continue;
        }
        int max = G_kv.GetNum("max", -1);
        if(max <= 0)
        {
            return Plugin_Continue;
        }
        int clip = get_weapon_clip(primary);
        int ammo = get_weapon_backup_ammo(client, primary);
        if(clip + ammo < max)
        {
            bool regen = false;
            if(IsFakeClient(client))
            {
                regen = true;
            }
            else if(clip == 0)
            {
                regen = true;
            }
            else if(get_active_weapon(client) == primary && buttons & IN_RELOAD && !(buttons & IN_ATTACK) && !(buttons & IN_ATTACK2))
            {
                regen = true;
            }
            if(regen == true)
            {
                set_weapon_backup_ammo(client, primary, max - clip);
            }
        }
    }
    return Plugin_Continue;
}

bool data_configs_exists()
{
    BuildPath(Path_SM, Save_path, sizeof(Save_path), DATA_PATH);
    return FileExists(Save_path);
}

void create_configs()
{
    File fl = OpenFile(Save_path, "w");
    if(fl == null)
    {
        SetFailState("data config create fail at OpenFile()");
    }
    int size = sizeof(Original_configs);
    for(int i = 0; i < size; i++)
    {
        fl.WriteLine(Original_configs[i]);
    }
    delete fl;
}

public Action CB_flush(int client, int args)
{
    bool deny = false;
    if(args != 1)
    {
        deny = true;
    }
    else
    {
        char arg1[PLATFORM_MAX_PATH];
        GetCmdArg(1, arg1, PLATFORM_MAX_PATH);
        if(strcmp(arg1, CONFIRM) != 0)
        {
            deny = true;
        }
    }
    if(deny == true)
    {
        ReplyToCommand(client, "use \"%s %s\" to flush and load config data", CMD_FLUSH, CONFIRM);
        return Plugin_Continue;
    }
    if(data_configs_exists())
    {
        DeleteFile(Save_path);
        check_configs();
    }
    return Plugin_Continue;
}

public Action CB_reload(int client, int args)
{
    check_configs();
    return Plugin_Continue;
}

public Action CB_list(int client, int args)
{
    G_kv.Rewind();
    if(G_kv.GotoFirstSubKey(false))
    {
        do
        {
            char key[PLATFORM_MAX_PATH];
            G_kv.GetSectionName(key, PLATFORM_MAX_PATH);
            int value = G_kv.GetNum("max", -1);
            ReplyToCommand(client, "%s    :", key);
            ReplyToCommand(client, "max: %d", value);
            ReplyToCommand(client, "----------------");
        }
        while(G_kv.GotoNextKey(false));
    }
    return Plugin_Continue;
}

public Action CB_query(int client, int args)
{
    if(args != 1)
    {
        ReplyToCommand(client, "use \"%s <classname>\" to query single weapon config", CMD_QUERY);
        return Plugin_Continue;
    }
    char arg1[PLATFORM_MAX_PATH];
    GetCmdArg(1, arg1, PLATFORM_MAX_PATH);
    G_kv.Rewind();
    if(G_kv.JumpToKey(arg1, false))
    {
        int value = G_kv.GetNum("max", -1);
        ReplyToCommand(client, "%s    :", arg1);
        ReplyToCommand(client, "max: %d", value);
        ReplyToCommand(client, "----------------");
        return Plugin_Continue;
    }
    else
    {
        ReplyToCommand(client, "classname \"%s\" not found", arg1);
        return Plugin_Continue;
    }
}

public Action CB_change(int client, int args)
{
    if(args != 2)
    {
        ReplyToCommand(client, "use \"%s <classname> <ammo_regen_max>\" to change or add single weapon config", CMD_CHANGE);
        return Plugin_Continue;
    }
    char arg1[PLATFORM_MAX_PATH];
    char arg2[PLATFORM_MAX_PATH];
    GetCmdArg(1, arg1, PLATFORM_MAX_PATH);
    GetCmdArg(2, arg2, PLATFORM_MAX_PATH);
    G_kv.Rewind();
    if(G_kv.JumpToKey(arg1, true))
    {
        G_kv.SetNum("max", StringToInt(arg2));
        G_kv.Rewind();
        G_kv.ExportToFile(Save_path);
        return Plugin_Continue;  
    }
    else
    {
        ReplyToCommand(client, "change for classname \"%s\" failed", arg1);
        return Plugin_Continue;
    }
}

public Action CB_remove(int client, int args)
{
    if(args != 1)
    {
        ReplyToCommand(client, "use \"%s <classname>\" to remove single weapon config", CMD_REMOVE);
        return Plugin_Continue;
    }
    char arg1[PLATFORM_MAX_PATH];
    GetCmdArg(1, arg1, PLATFORM_MAX_PATH);
    G_kv.Rewind();
    if(G_kv.JumpToKey(arg1, false))
    {
        G_kv.DeleteThis();
        G_kv.Rewind();
        G_kv.ExportToFile(Save_path);
        return Plugin_Continue;
    }
    else
    {
        ReplyToCommand(client, "classname \"%s\" not found", arg1);
        return Plugin_Continue;
    }
}

void check_configs()
{
    if(!data_configs_exists())
    {
        create_configs();
    }
    delete G_kv;
    G_kv = CreateKeyValues(KV_ROOT);
    G_kv.Rewind();
    G_kv.ImportFromFile(Save_path);
}

void internal_changed()
{
    O_debug = C_debug.BoolValue;
}

public void convar_changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	internal_changed();
}

public void OnConfigsExecuted()
{
	internal_changed();
}

public void OnPluginStart()
{
    check_configs();

    RegAdminCmd(CMD_FLUSH, CB_flush, ADMFLAG_RESERVATION, "respawn original config data file and load\"automatic_backup_ammo_regeneration\"");
    RegAdminCmd(CMD_RELOAD, CB_reload, ADMFLAG_RESERVATION, "reload config data from file \"automatic_backup_ammo_regeneration\"");
    RegAdminCmd(CMD_LIST, CB_list, ADMFLAG_RESERVATION, "show list config data \"automatic_backup_ammo_regeneration\"");
    RegAdminCmd(CMD_QUERY, CB_query, ADMFLAG_RESERVATION, "query config data of single weapon \"automatic_backup_ammo_regeneration\"");
    RegAdminCmd(CMD_CHANGE, CB_change, ADMFLAG_RESERVATION, "change or add config data of single weapon and save to file \"automatic_backup_ammo_regeneration\"");
    RegAdminCmd(CMD_REMOVE, CB_remove, ADMFLAG_RESERVATION, "remove config data of single weapon and save to file \"automatic_backup_ammo_regeneration\"");

    C_debug = CreateConVar("automatic_backup_ammo_regeneration_debug", "0", "set none zero enable debug(press IN_SPEED to clear primary weapon clip and ammo of everyone)");

    C_debug.AddChangeHook(convar_changed);

    CreateConVar("automatic_backup_ammo_regeneration_version", PLUGIN_VERSION, "version of \"automatic_backup_ammo_regeneration\"", FCVAR_DONTRECORD);

    AutoExecConfig(true, KV_ROOT);
}