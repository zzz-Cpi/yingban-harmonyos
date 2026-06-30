# 影伴App - 海报下载指南

## 说明

代码已修改为支持本地海报图片。你需要下载真实海报图片，放到指定目录，App就能显示真实海报。

## 下载步骤

### 1. 打开豆瓣电影页面

用浏览器访问以下链接，找到对应影片的海报：

| 序号 | 影片名称 | 豆瓣链接 |
|------|----------|----------|
| 1 | 繁花 | https://movie.douban.com/subject/34874646/ |
| 2 | 庆余年 第二季 | https://movie.douban.com/subject/34937650/ |
| 3 | 我的阿勒泰 | https://movie.douban.com/subject/36522955/ |
| 4 | 飞驰人生2 | https://movie.douban.com/subject/36369452/ |
| 5 | 种地吧 第二季 | https://movie.douban.com/subject/36571420/ |
| 6 | 不够善良的我们 | https://movie.douban.com/subject/36589909/ |
| 7 | 琅琊榜 | https://movie.douban.com/subject/25750923/ |
| 8 | 狂飙 | https://movie.douban.com/subject/35474009/ |
| 9 | 漫长的季节 | https://movie.douban.com/subject/35588177/ |
| 10 | 外婆的新世界 | https://movie.douban.com/subject/35876302/ |
| 11 | 逃出白虎园 | https://movie.douban.com/subject/36389905/ |
| 12 | 玫瑰的故事 | https://movie.douban.com/subject/36522946/ |
| 13 | 金庸武侠世界 | https://movie.douban.com/subject/36279229/ |
| 14 | 墨雨云间 | https://movie.douban.com/subject/36522834/ |
| 15 | 度华年 | https://movie.douban.com/subject/36522833/ |
| 16 | 热辣滚烫 | https://movie.douban.com/subject/36091087/ |
| 17 | 第二十条 | https://movie.douban.com/subject/36222669/ |
| 18 | 我们一起摇太阳 | https://movie.douban.com/subject/36174309/ |
| 19 | 熊出没·逆转时空 | https://movie.douban.com/subject/36418564/ |
| 20 | 红毯先生 | https://movie.douban.com/subject/35392727/ |
| 21 | 大红包 | https://movie.douban.com/subject/35231450/ |
| 22 | 扫黑·决不放弃 | https://movie.douban.com/subject/36389904/ |

### 2. 保存海报图片

在豆瓣页面：
1. 找到左侧的海报图片
2. **右键点击海报**
3. 选择 **"图片另存为..."**
4. 按下面的文件名保存

### 3. 保存路径和文件名

将图片保存到以下目录：

```
entry/src/main/resources/base/media/
```

**文件名对应表：**

| 保存文件名 | 对应影片 |
|-----------|----------|
| poster_fanhua.jpg | 繁花 |
| poster_qingyunian.jpg | 庆余年 第二季 |
| poster_aletai.jpg | 我的阿勒泰 |
| poster_feichi.jpg | 飞驰人生2 |
| poster_zhongdiba.jpg | 种地吧 第二季 |
| poster_bushanliang.jpg | 不够善良的我们 |
| poster_langyabang.jpg | 琅琊榜 |
| poster_kuangbiao.jpg | 狂飙 |
| poster_manchangdeji.jpg | 漫长的季节 |
| poster_waipodexinshijie.jpg | 外婆的新世界 |
| poster_taochubaihuyuan.jpg | 逃出白虎园 |
| poster_meiguidagushi.jpg | 玫瑰的故事 |
| poster_jinyongwuxia.jpg | 金庸武侠世界 |
| poster_moyuyunjian.jpg | 墨雨云间 |
| poster_duhuanian.jpg | 度华年 |
| poster_relaguangtang.jpg | 热辣滚烫 |
| poster_diershitiao.jpg | 第二十条 |
| poster_womenyiqi.jpg | 我们一起摇太阳 |
| poster_xiongchumo.jpg | 熊出没·逆转时空 |
| poster_hongtanxiansheng.jpg | 红毯先生 |
| poster_dahongbao.jpg | 大红包 |
| poster_saohei.jpg | 扫黑·决不放弃 |

### 4. 重新编译运行

下载完海报后，在 DevEco Studio 中：
1. 点击 **Build → Rebuild Project**
2. 重新运行 App
3. 即可看到真实海报

## 注意事项

- 图片格式支持：jpg、png、webp
- 图片尺寸建议：300x450 像素（竖版海报）
- 如果找不到某部影片的海报，可以跳过，App会显示默认图标
