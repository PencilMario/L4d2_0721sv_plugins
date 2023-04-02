#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <l4d2util>
enum struct Player{
    int id;
    int rankpoint;  // 综合评分
    int gametime;	// 真实游戏时长
    int tankrocks;	// 坦克饼命中数
    float winrounds;	//胜场百分比（0-1）, <500置默认
    int versustotal;
    int versuswin;
    int versuslose;
}
Player tempPlayer;
ArrayList team1, team2, a_players;
int prps[MAXPLAYERS] = -1;
int diffs;
public Plugin myinfo =
{
	name = "Test team balance",
	author = "p",
	description = "",
	version = "0.0",
	url = ""
}

public void OnPluginStart(){
    a_players = new ArrayList();
    for (int i = 0; i < 8; i++){
        Player P1;
        P1.id = i;
        prps[i] = GetRandomInt(100, 10000);
        a_players.PushArray(P1);
        PrintToServer("Set: %i - %i", P1.id, prps[i]);
    }
    min_diff();
    print_result();
}
int abs(int value){
    if (value < 0) return -value;
    return value;   
}
// 定义一个函数，用来计算两个数组的和的差值
int diff_sum(ArrayList array1, ArrayList array2)
{
    // 初始化两个数组的和
    int sum1 = 0;
    int sum2 = 0;
    // 遍历第一个数组，累加元素
    for (int i = 0; i < array1.Length; i++)
    {
        array1.GetArray(i, tempPlayer);
        sum1 += prps[tempPlayer.id];
    }
    // 遍历第二个数组，累加元素
    for (int i = 0; i < array2.Length; i++)
    {
        array2.GetArray(i, tempPlayer);
        sum2 += prps[tempPlayer.id];
    }
    // 返回两个数组的和的绝对值差
    PrintToServer("%i  = |%i-%i|", abs(sum1 - sum2), sum1, sum2);
    return abs(sum1 - sum2);
}


// 定义一个函数，用来找出所有可能的分组方式，并返回最小的差值和对应的分组
void min_diff()
{
    // 对数组进行排序
    a_players.SortCustom(SortByRank);
    // 初始化最小差值和分组
    diffs = 2147483647; // 最大的整数值
    //min_group = null;
    // 遍历所有可能的分组方式
    for (int i = 0; i < a_players.Length - 3; i++)
    {
        for (int j = i + 1; j < a_players.Length - 2; j++)
        {
            for (int k = j + 1; k < a_players.Length - 1; k++)
            {
                for (int l = k + 1; l < a_players.Length; l++)
                {
                    // 将数组分成两个子数组
                    ArrayList group1 = new ArrayList();// = {array[i], array[j], array[k], array[l]};
                    group1.Resize(4);
                    a_players.GetArray(i, tempPlayer);  
                    group1.SetArray(0,tempPlayer);
                    a_players.GetArray(j, tempPlayer);  
                    group1.SetArray(1,tempPlayer);
                    a_players.GetArray(k, tempPlayer);  
                    group1.SetArray(2,tempPlayer);
                    a_players.GetArray(l, tempPlayer);  
                    group1.SetArray(3,tempPlayer);

                    int m, n, o, p;
                    for (m=0; m<a_players.Length; m++){
                        if (m != i && m != j && m != k && m != l) break;
                    }
                    for (n=0; n<a_players.Length; n++){
                        if (n != i && n != j && n != k && n != l && n != m) break;
                    }
                    for (o=0; o<a_players.Length; o++){
                        if (o != i && o != j && o != k && o != l && o != m && o != n) break;
                    }
                    for (p=0; p<a_players.Length; p++){
                        if (p != i && p != j && p != k && p != l && p != m && p != n && p != o) break;
                    }                    
                    
                    ArrayList group2 = new ArrayList();
                    group2.Resize(4);
                    a_players.GetArray(m, tempPlayer);  
                    group2.SetArray(0,tempPlayer);
                    a_players.GetArray(n, tempPlayer);  
                    group2.SetArray(1,tempPlayer);
                    a_players.GetArray(o, tempPlayer);  
                    group2.SetArray(2,tempPlayer);
                    a_players.GetArray(p, tempPlayer);  
                    group2.SetArray(3,tempPlayer);

                    // 计算两个子数组的和的差值
                    PrintToServer("i%i,j%i,k%i,l%i",i,j,k,l);
                    PrintToServer("m%i,n%i,o%i,p%i",m,n,o,p);
                    int diff = diff_sum(group1, group2);
                    // 如果差值小于当前最小差值，更新最小差值和分组
                    if (diff < diffs)
                    {
                        diffs = diff;
                        if (team1 != INVALID_HANDLE){
                            team1.Resize(0);
                        }
                        if (team2 != INVALID_HANDLE){
                            team1.Resize(0);
                        }
                        team1 = group1.Clone();
                        team2 = group2.Clone();
                    }
                    delete group1;
                    delete group2;

                }
            }
        }
    }
}

// 定义一个函数，用来打印结果
void print_result()
{
    // 打印最小差值
    PrintToServer("The minimum difference is %d.", diffs);
    // 打印第一个分组
    PrintToServer("The first group is:");
    for (int i = 0; i < team1.Length; i++)
    {
        team1.GetArray(i, tempPlayer);
        PrintToServer("%i - %i", tempPlayer.id, prps[tempPlayer.id]);
    }
    // 打印第二个分组
    PrintToServer("The second group is:");
    for (int i = 0; i < team2.Length; i++)
    {
        team2.GetArray(i, tempPlayer);
        PrintToServer("%i - %i", tempPlayer.id, prps[tempPlayer.id]);
    }
}

int SortByRank(int indexFirst, int indexSecond, Handle hArrayList, Handle hndl)
{
    Player tPlayerFirst, tPlayerSecond;

    GetArrayArray(hArrayList, indexFirst, tPlayerFirst);
    GetArrayArray(hArrayList, indexSecond, tPlayerSecond);

    if (prps[tPlayerFirst.id] < prps[tPlayerSecond.id]) {
        return -1;
    }

    if (prps[tPlayerFirst.id] > prps[tPlayerSecond.id]) {
        return 1;
    }

    return 0;
}