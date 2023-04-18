# 胜率
winper = (0.51+0.61)/2
# 实际游戏时长，小时
time = 1078+1484
# 总计中饼次数
rockhit = 2894+1926
# 冲锋枪的数据
t1uzi = 55048+38249
t1smg = 75872+93961
# 喷子的数据
t1chro = 65852+40207
t1pump = 121294+107434

print(winper * (0.55*time + rockhit * (rockhit / time) + 
        (t1smg + t1uzi + t1chro + t1pump)*0.005*(1 + (t1chro + t1pump)/(t1smg + t1uzi + t1chro + t1pump))))

