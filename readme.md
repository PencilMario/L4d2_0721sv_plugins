# L4D2_0721SV_PLUGINS

装一些我自己找的用于自己服插件

> 目前我也不太深入求生的药抗圈子了，每天看心情和朋友上线混混野这样子，偶尔和朋友开开多特车    
> 代码里的bug应该不会管了，反正我也不开对抗服了    
> 不过我还是想找点东西打发一下时间，有什么想法可以丢个issue     
> 不过别太期待就是了，我插件这方面也是纯纯hello world级别的  

------

## 插件列表 Plugins List

**l4d_climb.smx** 生还爬墙(不开特感, 防止影响平衡)

**l4d_fyzb_en_v20.smx** 生还HT跳(不开特感, 同上)
>飞行无敌: *l4d_fyzb_god \<0 | 1\>* 防止出现bug开局后无敌

**l4d_laser_sp.smx** 开局显示弹道

**readyup.smx** 自改ready界面

**enhancedsprays.smx** 允许特感灵魂/旁观喷漆 喷漆距离和CD
>喷漆CD: *decalfrequency \<s\>*
>喷漆距离: *sm_enhancedsprays_distance \<def:115\>*

**l4d_bunnyhop.smx** 给你连跳插件你也跳不出220

**HitStatisticsLikeDianDian.smx**  类似于点点服的特感统计

**l4d_DynamicHostname.smx** 中文服务器名称插件
>修改服名在*addons/sourcemod/configs/hostname/server_hostname.txt*

**l4d_svname.smx** 服名显示配置和得分 只兼容本仓库spechud pause readyup, 不兼容zonemod对应插件, 会导致闪退, 名称也写死在代码里。
>spechud pause readyup 显示的服务器名称写死在readyup的cvar **sp_hostname** 不能直接修改 会导致服务器崩溃 需要代码里改之后手动编译。
>另外我稍微改了一点这三个插件的显示风格:)
>用着极度麻烦 🤡 shit code
>带vanlia前缀的为不适配**l4d_svname**的插件 其余与适配版本没有区别

**l4d2_airstrike.core.smx** 呼叫空袭 但是没有伤害 !strike 特感也能玩

**l4d2_server_ragdoll.sp** 死亡生还布娃娃
> 隐藏默认尸体 *sm_side_dolls_invisible_body 1*

**l4d2_show_ammo_remaining** 当备弹超过950时, 提示备弹量

**Plugins/MusicMapStart** 在对局开始时播放音乐
> 需要设置fastdl服务器，否则会导致**服务器无法进入**
> 具体的设置方法可以查看[原网站](https://forums.alliedmods.net/showthread.php?p=2645342)    


**Plugins/Ast_SiSpawnSystem** Ast药役的刷特相关插件 用于自己多特服 略微修改以方便直接在游戏内调节
> 设置特感数量 sm_setaispawns <生还玩家数量> <特感数量>
> 设置复活cd sm_setaitime <复活时间s>
> 默认只有mutation4（绝境）模式有效 如果想在coop和versus使用可以复制一份vscript改为对应的模式名字（AST要求两个都要）

**Plugins/fortnite_emotes_extended** 跳舞插件
> 跳舞指令 `sm_emote`/`sm_dance`  
> 需要设置fastdl服务器，否则会导致**服务器无法进入**  
> 客户端需要将“自定义服务器内容”改为“全部”才能看到跳舞  
> 插件来自评论区修改版，所以没源码

**Plugins/hitsound_download** 命中反馈，需要fastdl  
~~还是有点问题~~

**Plugins/l4d2_fuck_zuolao** 一个简单的坐牢给buff插件

**Plugins/l4d2_mix_team** mix插件, 支持随机mixmap

**l4d2_SpeakingList_SM1.11** 显示当前说话人【待测试】
> 因为混野时看到几个服用的这个插件是全局都能看到的, 拿来简单改了改，只显示对应的队伍
> 基于 https://forums.alliedmods.net/showthread.php?p=2790744

------    

### 设置fastdownload服务器 Set fastdl server

教程：<https://www.csgocn.net/2021/08/31/csgo-fastdl/>
虽然是csgo的, 但原理是一样的, 你可以在自己的求生Linux上搞
宝塔没有可以现装 装上之后关闭其防火墙即可

```cfg
//fastdl
sv_allowupload 1
sv_allowdownload 1
sv_downloadurl "http://你自己所创建的fastdl服务器(网站)"
```

### 如何编译 Complied

直接下载代码, 将.sp文件拖到complie.exe即可。

### 额外链接 Extra Link

[rl4d2l-plugins](https://github.com/devilesk/rl4d2l-plugins)

[L4D2-Plugins](https://github.com/fbef0102/L4D2-Plugins)

[MoYu_Server_Stupid_Plugins](https://github.com/Target5150/MoYu_Server_Stupid_Plugins)

[L4D2-HoongDou-Project](https://github.com/HoongDou/L4D2-HoongDou-Project)
