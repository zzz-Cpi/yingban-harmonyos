# 影伴 App 开发手册

> 一站式追剧管理与近场协同观影工具

---

## 一、项目概述

### 1.1 产品定位

**影伴**是一款面向年轻用户（大学生群体为主）的影视追剧管理工具，主打「追剧管理 + 观影笔记 + 近场协同观影」三位一体功能。

**差异化定位**：
- 不做视频播放平台，专注追剧管理
- 基于鸿蒙分布式能力，实现无网协同观影
- 结构化观影笔记，记录观影痕迹

### 1.2 目标用户

| 用户画像 | 特征 |
|----------|------|
| 核心用户 | 20-25岁大学生，追剧爱好者 |
| 使用场景 | 宿舍/聚会场景的离线协同观影 |
| 核心需求 | 多平台追剧统一管理、追剧笔记记录 |

### 1.3 设计理念

**Slogan**: 「影伴 - 追剧不孤单，观影有人陪」

**设计关键词**：
- **沉浸**：减少视觉干扰，专注内容
- **陪伴**：拟人化情感设计，有温度
- **轻量**：信息层级清晰，操作路径短

---

## 二、技术架构

### 2.1 开发环境

| 项目 | 版本 |
|------|------|
| 开发工具 | DevEco Studio 4.0+ |
| 目标系统 | HarmonyOS NEXT / API 14 |
| 开发语言 | ArkTS (Stage 模型) |
| UI框架 | ArkUI |

### 2.2 项目结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets          # 应用入口
├── pages/
│   ├── Index.ets                 # 首页（四Tab容器）
│   ├── HomePage.ets              # Tab1: 首页
│   ├── DramaPage.ets             # Tab2: 追剧
│   ├── TheaterPage.ets           # Tab3: 观影厅
│   ├── MinePage.ets              # Tab4: 我的
│   └── common/
│       ├── MovieCard.ets         # 影视卡片组件
│       ├── DramaCard.ets         # 追剧卡片组件
│       └── TheaterRoom.ets       # 观影房间组件
├── model/
│   └── MockData.ets              # Mock数据结构
└── utils/
    └── Constants.ets             # 常量定义

entry/src/main/resources/
├── base/
│   ├── element/                  # 颜色、字体、间距
│   ├── media/                    # 图片资源
│   └── profile/                  # 路由配置
└── dark/                         # 深色主题资源
```

### 2.3 核心依赖

| 依赖 | 用途 |
|------|------|
| @ohos.net.http | TMDB API 请求 |
| @ohos.data.relationalStore | 本地数据存储 |
| @ohos.distributedHardware.deviceManager | 设备发现 |
| @ohos.data.distributedData | 分布式数据同步 |
| @ohos.multimedia.media | 视频播放控制 |

---

## 三、UI设计规范

### 3.1 主题色

| 用途 | 色值 | 说明 |
|------|------|------|
| 主色 | #FF6B6B | 珊瑚红，活力感 |
| 辅助色 | #4ECDC4 | 青绿色，清新感 |
| 强调色 | #FFE66D | 柠檬黄，高亮提示 |
| 背景色 | #F0F2F5 | 浅灰白，主背景 |
| 卡片背景 | #FFFFFF | 纯白，卡片背景 |
| 深色背景 | #1A1A1A | 深黑，深色模式 |
| 文字主色 | #1D1D1F | 近黑，主文字 |
| 文字辅色 | #8E8E93 | 灰色，次要文字 |

### 3.2 字体规范

| 用途 | 字号 | 字重 | 行高 |
|------|------|------|------|
| 大标题 | 24fp | Bold(700) | 32fp |
| 页面标题 | 20fp | SemiBold(600) | 28fp |
| 区块标题 | 18fp | SemiBold(600) | 24fp |
| 正文 | 16fp | Regular(400) | 24fp |
| 副文本 | 14fp | Regular(400) | 20fp |
| 辅助文本 | 12fp | Regular(400) | 16fp |

### 3.3 间距规范

| 用途 | 间距值 |
|------|--------|
| 页面边距 | 16vp |
| 卡片内边距 | 12vp |
| 区块间距 | 24vp |
| 元素间距 | 8vp / 12vp / 16vp |
| 底部Tab高度 | 56vp |

### 3.4 圆角规范

| 组件 | 圆角值 |
|------|--------|
| 小按钮/标签 | 8vp |
| 卡片 | 16vp |
| 大按钮 | 28vp (全圆角) |
| 底部Tab | 24vp (顶部圆角) |

### 3.5 阴影规范

```typescript
// 卡片阴影
shadow({
  radius: 8,
  color: '#00000010',
  offsetX: 0,
  offsetY: 4
})

// 悬浮按钮阴影
shadow({
  radius: 12,
  color: '#FF6B6B30',
  offsetX: 0,
  offsetY: 6
})
```

---

## 四、页面结构

### 4.1 底部Tab导航

| Tab | 图标 | 标题 | 颜色 |
|-----|------|------|------|
| 首页 | home | 首页 | #FF6B6B (选中) / #8E8E93 (未选中) |
| 追剧 | film | 追剧 | 同上 |
| 观影厅 | tv | 观影厅 | 同上 |
| 我的 | user | 我的 | 同上 |

### 4.2 首页 (HomePage)

**布局结构**：
```
┌─────────────────────────────────┐
│  Logo    [搜索框]      [扫码]   │  ← 顶部导航栏 (44vp)
├─────────────────────────────────┤
│  [今日更新卡片 - 横向滚动]       │  ← 高度 200vp
├─────────────────────────────────┤
│  为你推荐          [换一批]     │  ← 区块标题
│  [推荐海报 - 横向滚动]           │  ← 高度 180vp
├─────────────────────────────────┤
│  分类快捷入口                   │
│  [电影][剧集][悬疑][喜剧][高分] │  ← 圆形图标 48vp
├─────────────────────────────────┤
│  热门电影              [更多]   │
│  ┌────┬────┬────┬────┐         │
│  │海报│海报│海报│海报│         │  ← 双列瀑布流
│  └────┴────┴────┴────┘         │
├─────────────────────────────────┤
│  热播剧集              [更多]   │
│  ┌────┬────┬────┬────┐         │
│  │海报│海报│海报│海报│         │
│  └────┴────┴────┴────┘         │
└─────────────────────────────────┘
```

### 4.3 追剧页 (DramaPage)

**布局结构**：
```
┌─────────────────────────────────┐
│  [想看] [在看] [已看]   共42部  │  ← 状态切换栏
├─────────────────────────────────┤
│  [全部] [寒假补番] [悬疑] [+]   │  ← 片单横滚
├─────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐       │
│  │ 海报    │  │ 海报    │       │  ← 瀑布流卡片
│  │ ████░░ │  │ ██████ │       │     进度条
│  │ 庆余年  │  │ 繁花    │       │
│  └─────────┘  └─────────┘       │
│  ┌─────────┐  ┌─────────┐       │
│  │ 海报    │  │ 海报    │       │
│  │ 逃出    │  │ 三体    │       │
│  └─────────┘  └─────────┘       │
│                           [+]   │  ← 悬浮添加按钮
└─────────────────────────────────┘
```

### 4.4 观影厅页 (TheaterPage)

**布局结构**：
```
┌─────────────────────────────────┐
│  观影厅            [历史记录]   │
│  近场零流量同步观影            │
├─────────────────────────────────┤
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │    [创建观影房]       │     │  ← 渐变按钮
│   │                       │     │
│   └───────────────────────┘     │
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │    [扫码加入]         │     │
│   │                       │     │
│   └───────────────────────┘     │
│                                 │
├─────────────────────────────────┤
│  附近房间                       │
│  ┌─────────────────────────┐   │
│  │ 房间名    房主    3人   >│   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ 房间名    房主    5人   >│   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

### 4.5 我的页 (MinePage)

**布局结构**：
```
┌─────────────────────────────────┐
│  ┌────┐                         │
│  │头像│  累计观影 128小时       │  ← 个人信息区
│  │    │  已看完 23 部           │
│  └────┘                         │
├─────────────────────────────────┤
│  ┌────────┐  ┌────────┐        │
│  │ 📝     │  │ 📊     │        │  ← 功能网格
│  │观影笔记│  │观影统计│        │
│  ├────────┤  ├────────┤        │
│  │ 📋     │  │ ⚙️     │        │
│  │我的片单│  │ 设置   │        │
│  ├────────┤  ├────────┤        │
│  │ 📁     │  │ ℹ️     │        │
│  │本地视频│  │ 关于   │        │
│  └────────┘  └────────┘        │
├─────────────────────────────────┤
│  最近笔记                       │
│  ┌─────────────────────────┐   │
│  │ ● 庆余年 - 第32集        │   │
│  │   范闲下朝后...         │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ ● 繁花 - 电影          │   │
│  │   宝总大战强总...       │   │
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  数据来源 TMDB | 仅供学习非商用 │  ← 底部声明
└─────────────────────────────────┘
```

---

## 五、组件规范

### 5.1 影视卡片 (MovieCard)

**使用场景**：首页推荐、热门榜单

**规格**：
- 宽度：(屏幕宽 - 48) / 2 vp
- 海报比例：2:3
- 圆角：12vp

**内容**：
- 海报图片（必填）
- 影片标题（最多2行）
- 评分（绿色数字）
- 平台图标（可选）

### 5.2 追剧卡片 (DramaCard)

**使用场景**：追剧页片单

**规格**：
- 宽度：(屏幕宽 - 48) / 2 vp
- 海报比例：2:3
- 圆角：16vp

**内容**：
- 海报图片（必填）
- 影片标题（最多2行）
- 平台图标组
- 进度条（当前集/总集数）
- 状态标签（想看/在看/已看）

### 5.3 分类图标 (CategoryIcon)

**规格**：
- 直径：48vp
- 圆角：全圆

**内容**：
- 图标/emoji
- 分类名称

### 5.4 观影厅按钮 (TheaterButton)

**规格**：
- 宽度：屏幕宽 - 64 vp
- 高度：56vp
- 圆角：28vp

**样式**：
- 渐变背景（主色到辅助色）
- 带图标 + 文字
- 悬浮阴影

### 5.5 功能入口 (MenuItem)

**规格**：
- 宽度：(屏幕宽 - 48) / 2 vp
- 高度：80vp
- 圆角：16vp

**内容**：
- 图标（32vp）
- 标题文字
- 背景白色

---

## 六、Mock数据结构

### 6.1 影视数据 (Movie)

```typescript
interface Movie {
  id: number           // 唯一标识
  title: string        // 影片名称
  posterUrl: string    // 海报URL
  rating: number        // 评分 0-10
  year: number         // 上映年份
  category: string      // 分类：电影/剧集
  genre: string[]      // 类型标签
  platform: string[]   // 播放平台
  description: string  // 简介
  episodeCount?: number // 剧集数（仅剧集）
}
```

### 6.2 追剧数据 (Drama)

```typescript
interface Drama {
  id: number
  movieId: number      // 关联影视
  status: 'want' | 'watching' | 'finished'  // 状态
  currentEpisode: number // 当前观看集数
  totalEpisodes: number // 总集数
  watchProgress: number // 观看进度百分比
  addedTime: number    // 添加时间戳
  lastWatchTime: number // 最后观看时间
}
```

### 6.3 观影房间 (TheaterRoom)

```typescript
interface TheaterRoom {
  id: string
  name: string         // 房间名称
  hostName: string     // 房主昵称
  memberCount: number  // 当前人数
  maxMember: number    // 最大人数
  status: 'waiting' | 'playing' | 'paused'  // 房间状态
  movieTitle?: string  // 当前播放影片
  createdTime: number  // 创建时间
}
```

### 6.4 观影笔记 (Note)

```typescript
interface Note {
  id: number
  movieId: number      // 关联影视
  episode: number       // 集数
  timestamp: number     // 视频时间戳（秒）
  content: string       // 笔记内容
  tags: string[]       // 标签
  screenshot?: string  // 截图URL
  createdTime: number  // 创建时间
}
```

### 6.5 用户数据 (User)

```typescript
interface User {
  id: number
  nickname: string     // 昵称
  avatar: string       // 头像URL
  totalWatchTime: number // 累计观影时长（小时）
  finishedCount: number // 已看完影片数
  achievementCount: number // 成就数
}
```

---

## 七、开发规范

### 7.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面文件 | PascalCase + Page.ets | HomePage.ets |
| 组件文件 | PascalCase.ets | MovieCard.ets |
| 数据模型 | PascalCase.ets | MockData.ets |
| 常量文件 | PascalCase.ets | Constants.ets |
| 状态变量 | camelCase | videoUrl, currentTab |
| 常量 | UPPER_SNAKE_CASE | API_BASE_URL |

### 7.2 代码风格

**组件定义**：
```typescript
@Component
struct MovieCard {
  @Prop movie: Movie    // 外部传入用 @Prop
  @State isLiked: boolean = false  // 内部状态用 @State

  build() {
    Column() {
      // ...
    }
  }
}
```

**页面结构**：
```typescript
@Entry
@Component
struct HomePage {
  @State private movies: Movie[] = []

  aboutToAppear() {
    // 生命周期初始化
    this.loadData()
  }

  build() {
    Column() {
      // 1. 顶部导航栏
      // 2. 内容区域（滚动）
      // 3. 底部Tab
    }
  }
}
```

### 7.3 路由规范

| 页面 | 路由路径 | 说明 |
|------|----------|------|
| 首页 | pages/Index | 入口+Tab容器 |
| 首页内容 | pages/HomePage | Tab1 |
| 追剧页 | pages/DramaPage | Tab2 |
| 观影厅 | pages/TheaterPage | Tab3 |
| 我的 | pages/MinePage | Tab4 |

### 7.4 资源规范

| 资源类型 | 路径 | 格式 |
|----------|------|------|
| 主色 | $r('app.color.primary') | 颜色资源 |
| 主图标 | $r('app.media.icon_home') | SVG/PNG |
| 海报图 | 使用URL | 网络图片 |

---

## 八、页面跳转关系

```
首页 (Index)
├── 首页 (HomePage)
│   ├── 搜索页 (SearchPage)
│   ├── 分类页 (CategoryPage)
│   └── 影视详情页 (MovieDetailPage)
│       └── 全屏播放页 (PlayerPage)
├── 追剧页 (DramaPage)
│   ├── 新增追剧页 (AddDramaPage)
│   └── 影视详情页 (MovieDetailPage)
├── 观影厅页 (TheaterPage)
│   └── 房间页 (RoomPage)
│       └── 全屏播放页 (PlayerPage)
└── 我的页 (MinePage)
    ├── 观影笔记页 (NoteListPage)
    │   └── 笔记详情页 (NoteDetailPage)
    ├── 观影统计页 (StatisticsPage)
    ├── 我的片单页 (PlaylistPage)
    ├── 本地视频页 (LocalVideoPage)
    └── 设置页 (SettingsPage)
```

---

## 九、验收标准

### 9.1 UI验收

- [ ] 四个Tab切换流畅，无视觉卡顿
- [ ] 所有卡片、按钮符合设计规范
- [ ] Mock数据显示正常，布局不错乱
- [ ] 深色模式切换正常（预留）

### 9.2 交互验收

- [ ] Tab点击切换正常
- [ ] 卡片点击响应正常
- [ ] 页面滚动无异常
- [ ] 悬浮按钮位置正确

### 9.3 性能验收

- [ ] 页面首次加载 < 1秒
- [ ] Tab切换无白屏
- [ ] 滚动流畅无卡顿

---

## 十、开发进度

| 阶段 | 内容 | 状态 |
|------|------|------|
| Phase 1 | 项目骨架 + 四个Tab基础UI | 🔄 进行中 |
| Phase 2 | 首页完整UI + Mock数据 | ⏳ 待开始 |
| Phase 3 | 追剧页完整UI | ⏳ 待开始 |
| Phase 4 | 观影厅页完整UI | ⏳ 待开始 |
| Phase 5 | 我的页完整UI | ⏳ 待开始 |
| Phase 6 | 详情页/播放器页面 | ⏳ 待开始 |

---

*本手册版本: v1.0.0*
*最后更新: 2026-06-30*
