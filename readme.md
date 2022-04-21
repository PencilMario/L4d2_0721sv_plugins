# L4D2_0721SV_PLUGINS          

装一些我自己找的用于自己服插件:|
------    
### 插件列表 Plugins List
**l4d_climb.smx** 生还爬墙(不开特感, 防止影响平衡)    
**l4d_fyzb_en_v20.smx** 生还HT跳(不开特感, 同上)     
>飞行无敌: *l4d_fyzb_god \<0 | 1\>* 防止出现bug开局后无敌      

**l4d_laser_sp.smx** 开局显示弹道     
**readyup.smx** 自改ready界面     
**enhancedsprays.smx** 允许特感灵魂/旁观喷漆 喷漆距离和CD      
>喷漆CD: *decalfrequency \<s\>*       
>喷漆距离: *sm_enhancedsprays_distance \<def:115\>*    

**l4d_bunnyhop.smx** 连跳练习提示音 
**HitStatisticsLikeDianDian.smx**  类似于点点服的特感统计             
**l4d_DynamicHostname.smx** 中文服务器名称插件      
>修改服名在*addons/sourcemod/configs/hostname/server_hostname.txt*     

**l4d_svname.smx** 服名显示配置和得分 只兼容本仓库spechud pause readyup, 不兼容zonemod对应插件, 会导致闪退。    
>spechud pause readyup 显示的服务器名称写死在readyup的cvar **sp_hostname** 不能直接修改 会导致服务器崩溃 需要代码里改之后手动编译。       
>用着极度麻烦 🤡 shit code          

**Plugins/MusicMapStart** 在对局开始时播放音乐 回合开始时自动停止
>需要设置fastdl服务器 如果不设置 会导致无法进服     
>具体的设置方法可以查看[原网站](https://forums.alliedmods.net/showthread.php?p=2645342)


**l4d2_airstrike.core.smx** 呼叫空袭 但是没有伤害 Just fun

------  
### 设置fastdownload服务器 Set fastdl server
教程：https://www.csgocn.net/2021/08/31/csgo-fastdl/    
虽然是csgo的, 但原理是一样的, 你可以在自己的求生Linux上搞
宝塔没有可以现装 装上之后关闭其防火墙即可
```
//fastdl
sv_allowupload 1
sv_allowdownload 1
sv_downloadurl "http://你自己所创建的fastdl服务器(网站)"
```

### 如何编译 Complied     
直接下载代码, 将.sp文件拖到complie.exe即可。

### 额外链接 Extra Link
[MoYu_Server_Stupid_Plugins](https://github.com/Target5150/MoYu_Server_Stupid_Plugins)   
[L4D2-HoongDou-Project](https://github.com/HoongDou/L4D2-HoongDou-Project)
