// 我的个人中心页（粉蓝磨砂柔和风格优化版）
import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockUser, mockNotes, Note } from '../../model/MockData'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

@Component
struct MinePage {
  build() {
    Column() {
      Scroll() {
        Column() {
          this.UserInfo()
          this.MenuGrid()
          this.WatchHistory()
          this.RecentNotes()
          this.FeatureList()
          this.Footer()
        }
        .padding({ bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background) // 粉蓝柔和背景色
  }

  // UserInfo - 全屏粉蓝渐变磨砂毛玻璃容器优化
  @Builder
  UserInfo() {
    Column() {
      // 粉蓝梦幻渐变背景层
      Column()
        .width('100%')
        .height(280)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [0x30FFB6C1, 0],
            [0x25FFC0CB, 0.4],
            [0x20B0E0E6, 0.7],
            [0x15E0F0F5, 1]
          ]
        })
        .position({ x: 0, y: 0 })

      Column() {
        // 顶部图标栏 - 磨砂半透明
        Row() {
          Image($r('app.media.icon_manage'))
            .width(25)
            .height(25)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              promptAction.showToast({ message: '侧边菜单开发中' })
            })

          Blank()

          Row({ space: Spacing.lg }) {
            // 扫码图标 - 柔和灰色
            Image($r('app.media.icon_scan'))
              .width(25)
              .height(25)
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                router.pushUrl({ url: 'pages/theater/ScanQrCodePage' })
              })

            // 消息图标 - 柔和灰色 + 粉色红点
            Stack() {
              Image($r('app.media.icon_msg'))
                .width(25)
                .height(25)
                .objectFit(ImageFit.Contain)

              Row()
                .width(8)
                .height(8)
                .borderRadius(4)
                .backgroundColor('#FFB6C1') // 柔和粉色红点
                .position({ x: 18, y: -2 })
            }
            .onClick(() => {
              router.pushUrl({ url: 'pages/mine/MessagePage' })
            })

            // 设置图标 - 柔和灰色
            Image($r('app.media.icon_setting'))
              .width(25)
              .height(25)
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                router.pushUrl({ url: 'pages/mine/SettingPage' })
              })
          }
        }
        .width('100%')
        .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg })

        // 用户信息行 - 粉蓝渐变头像
        Row() {
          Stack({ alignContent: Alignment.Center }) {
            // 粉蓝渐变圆形头像底色
            Row()
              .width(64)
              .height(64)
              .borderRadius(32)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
              })
              .backdropBlur(15)

            Text(mockUser.nickname.substring(0, 1))
              .fontSize(24)
              .fontWeight(FontWeightValue.bold)
              .fontColor(Color.White)
          }

          Column() {
            Text(mockUser.nickname)
              .fontSize(FontSizes.pageTitle)
              .fontWeight(FontWeightValue.bold)
              .fontColor('#2D2D3A')

            Text('观影不孤单，追剧有人陪')
              .fontSize(FontSizes.caption)
              .fontColor('#9A9AA3')
              .margin({ top: 4 })
          }
          .margin({ left: Spacing.lg })
          .alignItems(HorizontalAlign.Start)

          Blank()
        }
        .width('100%')
        .padding(Spacing.lg)
        .onClick(() => {
          promptAction.showToast({ message: '个人资料开发中' })
        })

        // 统计数据区 - 磨砂半透明卡片
        Row() {
          Column() {
            Text(mockUser.totalWatchTime.toString())
              .fontSize(20)
              .fontWeight(FontWeightValue.bold)
              .fontColor('#FFB6C1') // 柔和粉色

            Text('累计观影(小时)')
              .fontSize(FontSizes.helper)
              .fontColor('#9A9AA3')
          }
          .layoutWeight(1)
          .padding(Spacing.md)
          .backgroundColor('rgba(255,255,255,0.6)') // 磨砂半透明
          .backdropBlur(10)
          .borderRadius(14)
          .border({ width: 1, color: 'rgba(255,182,193,0.2)' })
          .onClick(() => {
            promptAction.showToast({ message: '观影统计开发中' })
          })

          Column() {
            Text(mockUser.finishedCount.toString())
              .fontSize(20)
              .fontWeight(FontWeightValue.bold)
              .fontColor('#B0E0E6') // 柔和浅青蓝

            Text('已看完(部)')
              .fontSize(FontSizes.helper)
              .fontColor('#9A9AA3')
          }
          .layoutWeight(1)
          .padding(Spacing.md)
          .backgroundColor('rgba(255,255,255,0.6)')
          .backdropBlur(10)
          .borderRadius(14)
          .border({ width: 1, color: 'rgba(176,224,230,0.2)' })
          .margin({ left: Spacing.sm })
          .onClick(() => {
            promptAction.showToast({ message: '已看完片单开发中' })
          })

          Column() {
            Text(mockUser.achievementCount.toString())
              .fontSize(20)
              .fontWeight(FontWeightValue.bold)
              .fontColor('#E8E8F0') // 柔和灰紫

            Text('获得成就')
              .fontSize(FontSizes.helper)
              .fontColor('#9A9AA3')
          }
          .layoutWeight(1)
          .padding(Spacing.md)
          .backgroundColor('rgba(255,255,255,0.6)')
          .backdropBlur(10)
          .borderRadius(14)
          .border({ width: 1, color: 'rgba(224,224,240,0.2)' })
          .margin({ left: Spacing.sm })
          .onClick(() => {
            router.pushUrl({ url: 'pages/mine/AchievementPage' })
          })
        }
        .width('100%')
        .padding({ left: Spacing.xl, right: Spacing.xl, bottom: Spacing.lg })
      }
      .width('100%')
    }
    .width('100%')
    // 磨砂毛玻璃整体背景
    .backgroundColor('rgba(255,255,255,0.75)')
    .backdropBlur(25)
    .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 20, bottomRight: 20 }) // 粉蓝大圆角
    .border({ width: 1, color: 'rgba(255,182,193,0.15)' })
    .shadow({ radius: 12, color: 'rgba(255,182,193,0.1)', offsetX: 0, offsetY: 3 })
  }

  // MenuGrid - 四大功能入口独立磨砂半透明圆角卡片优化
  @Builder
  MenuGrid() {
    Row({ space: Spacing.md }) {
      Column() {
        Stack() {
          // 粉蓝渐变图标底色
          Row()
            .width(40)
            .height(40)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
            })
            .opacity(0.3)

          Image($r('app.media.menu_note'))
            .width(28)
            .height(28)
        }

        Text('观影笔记')
          .fontSize(FontSizes.helper)
          .fontColor('#2D2D3A')
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .padding(Spacing.lg)
      .backgroundColor('rgba(255,255,255,0.7)') // 磨砂半透明卡片
      .backdropBlur(15)
      .borderRadius(20) // 粉蓝大圆角
      .border({ width: 1, color: 'rgba(255,182,193,0.2)' })
      .shadow({ radius: 6, color: 'rgba(255,182,193,0.08)', offsetX: 0, offsetY: 2 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/mine/NotesPage' })
      })

      Column() {
        Stack() {
          Row()
            .width(40)
            .height(40)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
            })
            .opacity(0.3)

          Image($r('app.media.menu_stat'))
            .width(28)
            .height(28)
        }

        Text('观影统计')
          .fontSize(FontSizes.helper)
          .fontColor('#2D2D3A')
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .padding(Spacing.lg)
      .backgroundColor('rgba(255,255,255,0.7)')
      .backdropBlur(15)
      .borderRadius(20)
      .border({ width: 1, color: 'rgba(176,224,230,0.2)' })
      .shadow({ radius: 6, color: 'rgba(176,224,230,0.08)', offsetX: 0, offsetY: 2 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/mine/StatisticPage' })
      })

      Column() {
        Stack() {
          Row()
            .width(40)
            .height(40)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
            })
            .opacity(0.3)

          Image($r('app.media.menu_favorite'))
            .width(28)
            .height(28)
        }

        Text('我的收藏')
          .fontSize(FontSizes.helper)
          .fontColor('#2D2D3A')
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .padding(Spacing.lg)
      .backgroundColor('rgba(255,255,255,0.7)')
      .backdropBlur(15)
      .borderRadius(20)
      .border({ width: 1, color: 'rgba(255,182,193,0.2)' })
      .shadow({ radius: 6, color: 'rgba(255,182,193,0.08)', offsetX: 0, offsetY: 2 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/mine/FavoritePage' })
      })

      Column() {
        Stack() {
          Row()
            .width(40)
            .height(40)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
            })
            .opacity(0.3)

          Image($r('app.media.menu_local'))
            .width(28)
            .height(28)
        }

        Text('本地视频')
          .fontSize(FontSizes.helper)
          .fontColor('#2D2D3A')
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .padding(Spacing.lg)
      .backgroundColor('rgba(255,255,255,0.7)')
      .backdropBlur(15)
      .borderRadius(20)
      .border({ width: 1, color: 'rgba(176,224,230,0.2)' })
      .shadow({ radius: 6, color: 'rgba(176,224,230,0.08)', offsetX: 0, offsetY: 2 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/mine/DownloadPage' })
      })
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl, bottom: Spacing.xl })
  }

  // WatchHistory - 磨砂半透明圆角容器优化
  @Builder
  WatchHistory() {
    Column() {
      Row() {
        Image($r('app.media.icon_history'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)

        Text('观看历史')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor('#2D2D3A')
          .margin({ left: Spacing.sm })

        Blank()

        Image($r('app.media.icon_arrow_right'))
          .width(18)
          .height(18)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.pushUrl({ url: 'pages/mine/HistoryPage' })
          })
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      Scroll() {
        Row() {
          this.DramaCard('枭起青壤', $r('app.media.poster_xiaoqiqingrang'), 32, 27)
          this.DramaCard('繁花', $r('app.media.poster_fanhua'), 30, 18)
          this.DramaCard('庆余年 第二季', $r('app.media.poster_qingyunian'), 36, 15)
          this.DramaCard('狂飙', $r('app.media.poster_kuangbiao'), 39, 12)
          this.DramaCard('我的阿勒泰', $r('app.media.poster_aletai'), 8, 8)
          this.DramaCard('琅琊榜', $r('app.media.poster_langyabang'), 54, 0)
        }
      }
      .width('100%')
      .height(180)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
    .width('100%')
    .padding(Spacing.lg)
    .backgroundColor('rgba(255,255,255,0.7)')
    .backdropBlur(20)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(255,182,193,0.15)' })
    .shadow({ radius: 8, color: 'rgba(255,182,193,0.1)', offsetX: 0, offsetY: 3 })
    .margin({ left: Spacing.lg, right: Spacing.lg })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08FFB6C1, 0], [0x08B0E0E6, 1]]
    })
  }

  // DramaCard - 海报+进度+集数
  @Builder
  DramaCard(title: string, poster: Resource, total: number, current: number) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(poster)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E8E8F0')

        Text('全' + total + '集')
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor('rgba(0,0,0,0.6)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .position({ right: 6, bottom: 6 })

        Row()
          .width('100%')
          .height(3)
          .backgroundColor('rgba(255,255,255,0.3)')

        Row()
          .width((current / total * 100) + '%')
          .height(3)
          .backgroundColor('#00C8C8')
      }
      .width(100)
      .height(140)
      .borderRadius(BorderRadius.small)
      .clip(true)

      Text(title + ' 第' + current + '集')
        .fontSize(FontSizes.helper)
        .fontColor('#2D2D3A')
        .margin({ top: Spacing.sm })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(100)
    .margin({ right: Spacing.md })
  }

  // RecentNotes - 磨砂半透明圆角容器优化
  @Builder
  RecentNotes() {
    Column() {
      Row() {
        Text('最近笔记')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor('#2D2D3A')

        Blank()

        Row() {
          Text('查看全部')
            .fontSize(FontSizes.caption)
            .fontColor('#9A9AA3')
          Image($r('app.media.icon_arrow_right'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ left: 4 })
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/mine/NotesPage' })
        })
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      if (mockNotes.length === 0) {
        Column() {
          Text('暂无笔记')
            .fontSize(FontSizes.caption)
            .fontColor('#9A9AA3')

          Text('观看时记录精彩瞬间')
            .fontSize(FontSizes.helper)
            .fontColor('#9A9AA3')
            .margin({ top: 4 })
        }
        .width('100%')
        .height(80)
        .backgroundColor('rgba(255,255,255,0.6)') // 磨砂半透明
        .backdropBlur(15)
        .borderRadius(20) // 粉蓝大圆角
        .border({ width: 1, color: 'rgba(255,182,193,0.15)' })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(mockNotes, (note: Note) => {
          this.NoteItem(note)
        }, (note: Note) => note.id.toString())
      }
    }
    .width('100%')
    .padding(Spacing.lg)
    // 磨砂半透明圆角容器 + 粉蓝渐变底色
    .backgroundColor('rgba(255,255,255,0.7)')
    .backdropBlur(20)
    .borderRadius(20) // 粉蓝大圆角
    .border({ width: 1, color: 'rgba(176,224,230,0.15)' })
    .shadow({ radius: 8, color: 'rgba(176,224,230,0.1)', offsetX: 0, offsetY: 3 })
    .margin({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg })
    .linearGradient({ // 底层淡粉蓝渐变底色
      direction: GradientDirection.Bottom,
      colors: [[0x08FFB6C1, 0], [0x08B0E0E6, 1]]
    })
  }

  // NoteItem - 磨砂半透明柔和卡片优化
  @Builder
  NoteItem(note: Note) {
    Column() {
      Row() {
        Row()
          .width(10)
          .height(10)
          .borderRadius(5)
          .linearGradient({ // 粉蓝渐变圆点
            direction: GradientDirection.Right,
            colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
          })

        Column() {
          Row() {
            Text(note.movieTitle)
              .fontSize(FontSizes.caption)
              .fontWeight(FontWeightValue.medium)
              .fontColor('#2D2D3A')

            Text(' - 第' + note.episode + '集')
              .fontSize(FontSizes.caption)
              .fontColor('#9A9AA3')
          }

          Text(note.content)
            .fontSize(FontSizes.helper)
            .fontColor('#9A9AA3')
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 4 }) {
            ForEach(note.tags, (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#FFB6C1') // 柔和粉色
                .backgroundColor('rgba(255,182,193,0.15)') // 粉蓝磨砂标签
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(10) // 粉蓝圆角
            }, (tag: string) => tag)
          }
          .margin({ top: Spacing.sm })
        }
        .margin({ left: Spacing.sm })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(Spacing.md)
    .backgroundColor('rgba(255,255,255,0.65)') // 磨砂半透明卡片
    .backdropBlur(15)
    .borderRadius(16) // 粉蓝圆角
    .border({ width: 1, color: 'rgba(255,182,193,0.15)' })
    .margin({ bottom: Spacing.md })
    .shadow({ radius: 6, color: 'rgba(255,182,193,0.08)', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      promptAction.showToast({ message: '笔记详情开发中' })
    })
  }

  // FeatureList - 磨砂半透明圆角卡片优化
  @Builder
  FeatureList() {
    Column() {
      this.FeatureItem($r('app.media.feature_like'), '我的点赞')
      this.FeatureDivider()
      this.FeatureItem($r('app.media.feature_comment'), '我的评论')
      this.FeatureDivider()
      this.FeatureItem($r('app.media.feature_coin'), '我的金币')
      this.FeatureDivider()
      this.FeatureItem($r('app.media.feature_survey'), '问卷调查')
      this.FeatureDivider()
      this.FeatureItem($r('app.media.feature_more'), '更多功能')
      this.FeatureDivider()
      this.FeatureItem($r('app.media.feature_service'), '专属客服')
    }
    .width('90%')
    .backgroundColor('rgba(255,255,255,0.7)') // 磨砂半透明背景
    .backdropBlur(20)
    .borderRadius(20) // 粉蓝大圆角
    .border({ width: 1, color: 'rgba(255,182,193,0.15)' })
    .padding({ left: Spacing.lg, right: Spacing.lg })
    .margin({ top: Spacing.xl, left: '5%', right: '5%' })
    .shadow({ radius: 10, color: 'rgba(255,182,193,0.1)', offsetX: 0, offsetY: 3 })
    .linearGradient({ // 底层淡粉蓝渐变底色
      direction: GradientDirection.Bottom,
      colors: [[0x05FFB6C1, 0], [0x05B0E0E6, 1]]
    })
  }

  @Builder
  FeatureItem(icon: Resource, title: string) {
    Row() {
      Image(icon)
        .width(25)
        .height(25)
        .objectFit(ImageFit.Contain)

      Text(title)
        .fontSize(FontSizes.caption)
        .fontColor('#2D2D3A')
        .margin({ left: Spacing.md })

      Blank()

      Image($r('app.media.icon_arrow_right'))
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height(60)
    .onClick(() => {
      promptAction.showToast({ message: title + '开发中' })
    })
  }

  @Builder
  FeatureDivider() {
    Divider()
      .color('rgba(255,182,193,0.15)') // 柔和粉蓝分隔线
      .margin({ left: 32 })
  }

  @Builder
  Footer() {  
    Column() {
      Divider()
        .color('rgba(176,224,230,0.3)') // 柔和浅青蓝分隔线
        .margin({ left: Spacing.lg, right: Spacing.lg })

      Text('影伴 v1.0.0')
        .fontSize(FontSizes.helper)
        .fontColor('#9A9AA3')
        .margin({ top: Spacing.md })

      Text('数据来源 TMDB，仅用于学习非商用')
        .fontSize(10)
        .fontColor('#9A9AA3')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: Spacing.xl, bottom: Spacing.lg })
  }
}

export default MinePage


