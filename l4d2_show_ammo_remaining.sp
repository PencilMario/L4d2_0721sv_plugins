#include <sourcemod>
#include <sdktools>
#include <multicolors>

public Plugin myinfo =
{
	name = "[L4D2] 显示弹药剩余",
	author = "SirP",
	description = "用于在修改备弹的服务器中提示超过1024的备弹",
	version = "0.1",
	url = ""
};

public void OnPluginStart()
{
    HookEvent("weapon_reload", EVENT_WEAPONRELOAD, EventHookMode_Post);
};

public Action EVENT_WEAPONRELOAD(Handle:event, const String:name[], bool:dontBroadcast){
    int client = event.GetInt("userid");
    int primary = GetPlayerWeaponSlot(client, 0);
    int bakammo = GetWeaponBackupAmmo(player, primary)
    if(primary < 0)
    {
        return Plugin_Continue;
    }
}

int GetWeaponBackupAmmo(int owner, int weapon){
    return GetEntProp(owner, Prop_Data, "m_iAmmo", _, get_weapon_ammo_type(weapon));
};