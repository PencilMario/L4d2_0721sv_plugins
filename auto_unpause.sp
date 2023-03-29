#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <pause>
#include <l4d2util>

Handle g_hPauseTimer;
int g_iLastTime;
public Plugin myinfo =
{
    name        = "Auto Unpause",
    author      = "Sir.P",
    description = "自动取消暂停",
    version     = "0.0.1",
    url         = ""
}


public void OnPause(){
    g_iLastTime = 30;
    g_hPauseTimer = CreateTimer(1.0, Timer_AutoUnpause, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}
public void OnUnpause(){
    KillTimer(g_hPauseTimer);
    g_hPauseTimer = INVALID_HANDLE;
}

public Action Timer_AutoUnpause(Handle timer){
    char message[128];
    Format(message, sizeof(message), "如果无人准备，游戏将自动继续。\n将于%i秒后继续游戏", g_iLastTime);
    
    g_iLastTime--;
    if (g_iLastTime < 0){
        Unpause();
        g_iLastTime = 30;
    }
    else{
        PrintCenterTextAll(message);
    }
}
public void Unpause(){
    for (int i = 1; i< MaxClients + 1; i++){
        if (IsClientInGame(i)){
            int admindata = GetUserFlagBits(i);
            SetUserFlagBits(i, ADMFLAG_ROOT);
            int commandflags = GetCommandFlags("sm_rcon");
            SetCommandFlags("sm_rcon", commandflags & ~FCVAR_CHEAT);
            FakeClientCommand(i, "sm_rcon sm_forceunpause");
            SetCommandFlags("sm_rcon", commandflags);
            SetUserFlagBits(i, admindata);
            break;
        }
    }
}
