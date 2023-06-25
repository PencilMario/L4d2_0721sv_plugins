#Ast_SiSpawnSystem

本来是Ast药役的刷特系统，修修改改后拿来单独给自己的多特服用，脚本刷特，插件主要负责调节（已经看不出原本ast的样子了

插件还是我非常早期的时候写的，一坨屎山，不过它能跑

| ConVar | 默认值 | 描述 |
|  --- | --- | --- |
| sss_1P | 3 | 特感数量 **不建议修改** |
| SS_Time | 35 | 刷新间隔 **不建议修改**|
| SS_Relax | 1 | 允许relax阶段 |
| SS_DPSSiLimit | 10 | DPS特感数量限制 |
| sm_ss_automode | 1 | 自动调整刷特模式（4+生还玩家） |
| sm_ss_autoperdetime | 1 | 每多一名生还，特感的复活时间减少多少s |
| sm_ss_autotime | 35 | 一只特感的基础复活时间 |
| sm_ss_autosilim | 3 | 在4名玩家时，基础特感数量 |
| sm_ss_autoperinsi | 1 | 每多一名生还，增加几只特感 |
| sm_ss_fixm4spawn | 0 | 是否启用绝境修复 |

* 绝境修复：
    请详看 https://github.com/PencilMario/L4D2-Not0721Here-CoopSvPlugins/tree/main/Docs#%E9%85%8D%E7%BD%AE%E7%BB%86%E8%8A%82

cmd:
    sm_SetAiSpawns 设置复活数量（非自动模式
    sm_SetAiTime 设置复活间隔（非自动模式
    sm_SetDpsLim 设置DPS限制

