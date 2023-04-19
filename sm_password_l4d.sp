#include <sourcemod>

#define PWDTIME 45

ConVar pwd;
Handle tm;
bool ClientPassed[MAXPLAYERS];
int ClientLastTime[MAXPLAYERS] = {PWDTIME};
public Plugin myinfo = {
    name = "PWD",
    author = "sp",
    description = "为服务器设置密码，超时且未填入密码的人将会被踢出",
    version = "1.0.0",
    url = ""
};

public void OnPluginStart(){
    pwd = CreateConVar("sm_pwd_var", "0", "服务器密码");
    RegConsoleCmd("sm_pwd", Cmd_InputPwd, "输入密码");
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

}
public void OnPluginEnd()
{
    KillTimer(tm);
}
public void OnMapStart()
{  
    if (pwd.IntValue) tm = CreateTimer(1.0, Timer_Check, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}



public bool OnClientConnect(int client, char[] rejectmsg, int maxlen){
    ClientLastTime[client] = 999;
    return true;
}

public void OnClientPutInServer(int client)
{
    ClientLastTime[client] = PWDTIME;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!client)
        return;

    if (IsFakeClient(client))
        return;
    ClientPassed[client] = false;
}

public Action Cmd_InputPwd(int client, int args)
{
    if (args != 1) {
        ReplyToCommand(client, "格式不正确!");
        return Plugin_Handled;
    }
    int pwds = GetCmdArgInt(1);
    if (pwds == pwd.IntValue)
    {
        ClientPassed[client] = true;
        ClientLastTime[client] = 300;
        ReplyToCommand(client, "密码正确! 你可以放心进行游戏了!");
    }
    else
    {
        ReplyToCommand(client, "密码不正确!");
    }
    return Plugin_Handled;
}

public Action Timer_Check(Handle Timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!ClientPassed[i])
        {
            if (!IsFakeClient(i) && IsClientInGame(i))
            {
                ClientLastTime[i]--
                if (ClientLastTime[i] < 0)
                {
                    KickClient(i, "输入密码超时!");
                }
                else
                {
                    PrintHintText(i, "你需要使用指令!pwd输入对局密码！\n示例：!pwd 123\n剩余时间：%i", ClientLastTime[i]);
                    PrintCenterText(i, "你需要使用指令!pwd输入对局密码！\n示例：!pwd 123\n剩余时间：%i", ClientLastTime[i]);
                }
            }
        }
    }
    return Plugin_Continue;
}