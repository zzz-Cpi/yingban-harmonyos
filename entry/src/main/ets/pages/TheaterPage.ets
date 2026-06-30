// 观影厅页 - 鸿蒙分布式核心亮点
import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../utils/Constants'
import { mockRooms, TheaterRoom } from '../model/MockData'

@Component
struct TheaterPage {
  @State private isScanning: boolean = false

  build() {
    Column() {
      // 顶部标题栏
      this.TopBar()

      Scroll() {
        Column() {
          // 核心操作区
          this.CoreActions()

          // 附近房间列表
          this.NearbyRooms()

          // 使用说明
          this.UsageTips()
        }
        .padding({ bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  TopBar() {
    Column() {
      Row() {
        Column() {
          Text('观影厅')
            .fontSize(FontSizes.pageTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)

          Text('近场零流量同步观影')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 历史记录
        Row() {
          Text('📜')
            .fontSize(18)

          Text('历史')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textSecondary)
            .margin({ left: 4 })
        }
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.md })
      .backgroundColor(Color.White)
    }
  }

  @Builder
  CoreActions() {
    Column() {
      // 创建观影房按钮
      Column() {
        Row() {
          Text('➕')
            .fontSize(24)
            .fontColor(Color.White)

          Column() {
            Text('创建观影房')
              .fontSize(FontSizes.body)
              .fontWeight(FontWeightValue.semibold)
              .fontColor(Color.White)

            Text('邀请好友一起同步观影')
              .fontSize(FontSizes.helper)
              .fontColor('rgba(255,255,255,0.8)')
          }
          .margin({ left: Spacing.md })
        }
        .width('100%')
      }
      .width('100%')
      .height(80)
      .backgroundColor(Colors.primary)
      .borderRadius(BorderRadius.large)
      .padding({ left: Spacing.xl, right: Spacing.xl })
      .shadow(Shadows.floating)
      .onClick(() => {
        // 创建房间
      })

      // 扫码加入按钮
      Column() {
        Row() {
          Text('📷')
            .fontSize(24)
            .fontColor(Colors.secondary)

          Column() {
            Text('扫码加入')
              .fontSize(FontSizes.body)
              .fontWeight(FontWeightValue.semibold)
              .fontColor(Colors.textPrimary)

            Text('扫描二维码加入房间')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .margin({ left: Spacing.md })
        }
        .width('100%')
      }
      .width('100%')
      .height(80)
      .backgroundColor(Color.White)
      .borderRadius(BorderRadius.large)
      .padding({ left: Spacing.xl, right: Spacing.xl })
      .margin({ top: Spacing.md })
      .shadow(Shadows.card)
      .onClick(() => {
        // 扫码加入
      })
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  NearbyRooms() {
    Column() {
      Row() {
        Row({ space: 4 }) {
          // 雷达扫描效果
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(20)
              .height(20)
              .borderRadius(10)
              .border({ width: 2, color: Colors.secondary })
              .backgroundColor(Color.White)

            Row()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(Colors.secondary)
          }

          Text('附近房间')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Colors.textPrimary)
        }

        Blank()

        Text('自动刷新')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      if (mockRooms.length === 0) {
        // 无房间时显示提示
        Column() {
          Text('📡')
            .fontSize(48)
            .opacity(0.5)

          Text('暂无附近房间')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textTertiary)
            .margin({ top: Spacing.md })

          Text('创建一个房间开始观影吧')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
        }
        .width('100%')
        .height(160)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(mockRooms, (room: TheaterRoom) => {
          this.RoomItem(room)
        })
      }
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  RoomItem(room: TheaterRoom) {
    Column() {
      Row() {
        Column() {
          Text(room.name)
            .fontSize(FontSizes.body)
            .fontWeight(FontWeightValue.medium)
            .fontColor(Colors.textPrimary)

          Row({ space: 8 }) {
            Text('房主: ' + room.hostName)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)

            Text('·')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textTertiary)

            Text(room.memberCount + '/' + room.maxMember + '人')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .margin({ top: 4 })
        }

        Blank()

        // 状态标签
        Row() {
          if (room.status === 'playing') {
            Text('播放中')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(Colors.primary)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(BorderRadius.small)
          } else if (room.status === 'waiting') {
            Text('等待中')
              .fontSize(10)
              .fontColor(Colors.secondary)
              .backgroundColor('#E0F7F5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(BorderRadius.small)
          }

          Text('>')
            .fontSize(14)
            .fontColor(Colors.textTertiary)
            .margin({ left: Spacing.sm })
        }
      }

      // 当前播放影片
      if (room.movieTitle) {
        Row() {
          Text('▶')
            .fontSize(12)
            .fontColor(Colors.textSecondary)

          Text('正在播放: ' + room.movieTitle)
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
            .margin({ left: 4 })
        }
        .margin({ top: Spacing.sm })
      }
    }
    .width('100%')
    .padding(Spacing.lg)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.large)
    .margin({ bottom: Spacing.md })
    .shadow(Shadows.card)
    .onClick(() => {
      // 加入房间
    })
  }

  @Builder
  UsageTips() {
    Column() {
      Row() {
        Text('观影厅使用说明')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      Row({ space: Spacing.md }) {
        this.TipItem('📡', '无需流量', '近场直连')
        this.TipItem('📱', '一碰建组', '鸿蒙设备')
        this.TipItem('🎬', '同步播放', '进度一致')
      }
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  TipItem(icon: string, title: string, subtitle: string) {
    Column() {
      Text(icon)
        .fontSize(24)

      Text(title)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.sm })

      Text(subtitle)
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textSecondary)
    }
    .layoutWeight(1)
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .justifyContent(FlexAlign.Center)
    .shadow(Shadows.card)
  }
}

export default TheaterPage
