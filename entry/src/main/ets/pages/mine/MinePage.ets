// 我的页 - 个人数据中心
import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockUser, mockNotes, Note } from '../../model/MockData'

@Component
struct MinePage {
  build() {
    Column() {
      Scroll() {
        Column() {
          // 个人信息区
          this.UserInfo()

          // 功能入口网格
          this.MenuGrid()

          // 最近笔记预览
          this.RecentNotes()

          // 底部声明
          this.Footer()
        }
        .padding({ bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  UserInfo() {
    Column() {
      Row() {
        // 头像
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(64)
            .height(64)
            .borderRadius(32)
            .backgroundColor(Colors.primary)

          Text(mockUser.nickname.substring(0, 1))
            .fontSize(24)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Color.White)
        }

        Column() {
          Text(mockUser.nickname)
            .fontSize(FontSizes.pageTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)

          Text('观影不孤单，追剧有人陪')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textSecondary)
            .margin({ top: 4 })
        }
        .margin({ left: Spacing.lg })
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('⚙️')
          .fontSize(22)
      }
      .width('100%')
      .padding(Spacing.lg)

      // 统计数据
      Row() {
        Column() {
          Text(mockUser.totalWatchTime.toString())
            .fontSize(20)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.primary)

          Text('累计观影(小时)')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)

        Divider()
          .height(32)
          .vertical(true)
          .color('#E0E0E0')

        Column() {
          Text(mockUser.finishedCount.toString())
            .fontSize(20)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.secondary)

          Text('已看完(部)')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)

        Divider()
          .height(32)
          .vertical(true)
          .color('#E0E0E0')

        Column() {
          Text(mockUser.achievementCount.toString())
            .fontSize(20)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.accent)

          Text('获得成就')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Spacing.xl, right: Spacing.xl, bottom: Spacing.lg })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow(Shadows.card)
  }

  @Builder
  MenuGrid() {
    Column() {
      Grid() {
        GridItem() {
          this.MenuItem('📝', '观影笔记', '#FF6B6B')
        }
        GridItem() {
          this.MenuItem('📊', '观影统计', '#4ECDC4')
        }
        GridItem() {
          this.MenuItem('📋', '我的片单', '#FF9500')
        }
        GridItem() {
          this.MenuItem('📁', '本地视频', '#8E8E93')
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(Spacing.md)
      .rowsGap(Spacing.md)
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
      .height(200)
    }
    .width('100%')
  }

  @Builder
  MenuItem(icon: string, title: string, color: string) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor(color)

        Text(icon)
          .fontSize(20)
      }

      Text(title)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.sm })
    }
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .justifyContent(FlexAlign.Center)
    .shadow(Shadows.card)
    .onClick(() => {
      // 跳转对应页面
    })
  }

  @Builder
  RecentNotes() {
    Column() {
      Row() {
        Text('最近笔记')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)

        Blank()

        Text('查看全部 >')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      if (mockNotes.length === 0) {
        Column() {
          Text('暂无笔记')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textTertiary)

          Text('观看时记录精彩瞬间')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
            .margin({ top: 4 })
        }
        .width('100%')
        .height(80)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(mockNotes, (note: Note) => {
          this.NoteItem(note)
        })
      }
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  NoteItem(note: Note) {
    Column() {
      Row() {
        // 时间轴圆点
        Row()
          .width(10)
          .height(10)
          .borderRadius(5)
          .backgroundColor(Colors.primary)

        Column() {
          Row() {
            Text(note.movieTitle)
              .fontSize(FontSizes.caption)
              .fontWeight(FontWeightValue.medium)
              .fontColor(Colors.textPrimary)

            Text(' - 第' + note.episode + '集')
              .fontSize(FontSizes.caption)
              .fontColor(Colors.textSecondary)
          }

          Text(note.content)
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 标签
          Row({ space: 4 }) {
            ForEach(note.tags, (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor(Colors.primary)
                .backgroundColor('#FFF0F0')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(BorderRadius.small)
            })
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
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .margin({ bottom: Spacing.md })
    .shadow(Shadows.card)
  }

  @Builder
  Footer() {
    Column() {
      Divider()
        .color('#E0E0E0')
        .margin({ left: Spacing.lg, right: Spacing.lg })



      Text('影伴 v1.0.0')
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textTertiary)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: Spacing.xl, bottom: Spacing.lg })
  }
}

export default MinePage
