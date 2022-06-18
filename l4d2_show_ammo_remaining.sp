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
    if (1100 > bakammo && bakammo > 1000){
    CPrintToChat(cilent, "{green}[{lightgreen}!{green}] {default}当剩余子弹低于950后将不再提示此信息");
    }
    if (bakammo > 950){
    CPrintToChat(cilent, "{green}[{lightgreen}!{green}] {default}剩余备弹 \x0B> {blue}%d", bakammo);
    }
}

int GetWeaponBackupAmmo(int owner, int weapon){
    return GetEntProp(owner, Prop_Data, "m_iAmmo", _, get_weapon_ammo_type(weapon));
};
