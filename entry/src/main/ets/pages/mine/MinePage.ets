// 我的页 - 个人数据中心
import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockUser, mockNotes, Note, mockHistoryDramas, HistoryDrama } from '../../model/MockData'

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

          // 观看历史
          this.WatchHistory()

          // 最近笔记预览
          this.RecentNotes()

          // 更多功能
          this.FeatureList()

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
      // 顶部导航栏：管理、扫码、消息、设置
      Row() {
        Image($r('app.media.icon_manage'))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Contain)

        Blank()

        Row({ space: Spacing.lg }) {
          Image($r('app.media.icon_scan'))
            .width(25)
            .height(25)
            .objectFit(ImageFit.Contain)

          Image($r('app.media.icon_msg'))
            .width(25)
            .height(25)
            .objectFit(ImageFit.Contain)

          Image($r('app.media.icon_setting'))
            .width(25)
            .height(25)
            .objectFit(ImageFit.Contain)
        }
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg })

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
    Row() {
      // 1. 观影笔记
      Column() {
        Image($r('app.media.menu_note'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)

        Text('观影笔记')
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textPrimary)
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 2. 观影统计
      Column() {
        Image($r('app.media.menu_stat'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)

        Text('观影统计')
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textPrimary)
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 3. 我的收藏
      Column() {
        Image($r('app.media.menu_favorite'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)

        Text('我的收藏')
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textPrimary)
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 4. 本地视频
      Column() {
        Image($r('app.media.menu_local'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)

        Text('本地视频')
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textPrimary)
          .margin({ top: Spacing.sm })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl, bottom: Spacing.xl })
  }

  @Builder
  WatchHistory() {
    Column() {
      // 标题行
      Row() {
        Image($r('app.media.icon_history'))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Contain)

        Text('观看历史')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)
          .margin({ left: Spacing.sm })

        Blank()

        Image($r('app.media.icon_arrow_right'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      // 横向滑动
      Scroll() {
        Row({ space: Spacing.md }) {
          ForEach(mockHistoryDramas, (item: HistoryDrama) => {
            this.DramaCard(item)
          }, (item: HistoryDrama) => item.id.toString())
        }
        .padding({ right: Spacing.lg })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  private getPosterResource(name: string): Resource {
    switch (name) {
      case 'poster_fanhua': return $r('app.media.poster_fanhua')
      case 'poster_qingyunian': return $r('app.media.poster_qingyunian')
      case 'poster_aletai': return $r('app.media.poster_aletai')
      case 'poster_feichi': return $r('app.media.poster_feichi')
      case 'poster_zhongdiba': return $r('app.media.poster_zhongdiba')
      case 'poster_bushanliang': return $r('app.media.poster_bushanliang')
      case 'poster_langyabang': return $r('app.media.poster_langyabang')
      case 'poster_kuangbiao': return $r('app.media.poster_kuangbiao')
      case 'poster_manchangdeji': return $r('app.media.poster_manchangdeji')
      case 'poster_waipodexinshijie': return $r('app.media.poster_waipodexinshijie')
      case 'poster_taochubaihuyuan': return $r('app.media.poster_taochubaihuyuan')
      case 'poster_meiguidagushi': return $r('app.media.poster_meiguidagushi')
      case 'poster_jinyongwuxia': return $r('app.media.poster_jinyongwuxia')
      case 'poster_moyuyunjian': return $r('app.media.poster_moyuyunjian')
      case 'poster_duhuanian': return $r('app.media.poster_duhuanian')
      case 'poster_aletai2': return $r('app.media.poster_aletai2')
      case 'poster_yanxinji': return $r('app.media.poster_yanxinji')
      case 'poster_relaguangtang': return $r('app.media.poster_relaguangtang')
      case 'poster_diershitiao': return $r('app.media.poster_diershitiao')
      case 'poster_womenyiqi': return $r('app.media.poster_womenyiqi')
      case 'poster_xiongchumo': return $r('app.media.poster_xiongchumo')
      case 'poster_hongtanxiansheng': return $r('app.media.poster_hongtanxiansheng')
      case 'poster_dahongbao': return $r('app.media.poster_dahongbao')
      case 'poster_saohei': return $r('app.media.poster_saohei')
      case 'poster_xiaoqiqingrang': return $r('app.media.poster_xiaoqiqingrang')
      default: return $r('app.media.startIcon')
    }
  }

  @Builder
  DramaCard(item: HistoryDrama) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.getPosterResource(item.posterName))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E0E0E0')

        // 右下角集数标签
        Text('全' + item.totalEpisodes + '集')
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor('rgba(0,0,0,0.6)')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .position({ right: 6, bottom: 6 })

        // 底部进度条背景
        Row()
          .width('100%')
          .height(3)
          .backgroundColor('rgba(255,255,255,0.3)')

        // 底部进度条前景
        Row()
          .width((item.currentEpisode / item.totalEpisodes * 100) + '%')
          .height(3)
          .backgroundColor(Colors.secondary)
      }
      .width(100)
      .height(140)
      .borderRadius(BorderRadius.small)
      .clip(true)

      // 剧名 + 集数
      Text(item.title + ' 第' + item.currentEpisode + '集')
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.sm })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(100)
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
        }, (note: Note) => note.id.toString())
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
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .margin({ bottom: Spacing.md })
    .shadow(Shadows.card)
  }

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
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .padding({ left: Spacing.lg, right: Spacing.lg })
    .margin({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
    .shadow(Shadows.card)
  }

  @Builder
  FeatureItem(icon: Resource, title: string) {
    Row() {
      // 左侧图标
      Image(icon)
        .width(25)
        .height(25)
        .objectFit(ImageFit.Contain)

      // 功能名称
      Text(title)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textPrimary)
        .margin({ left: Spacing.md })

      Blank()

      // 右侧箭头
      Image($r('app.media.icon_arrow_right'))
        .width(16)
        .height(16)
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height(56)
  }

  @Builder
  FeatureDivider() {
    Divider()
      .color('#F0F0F0')
      .margin({ left: 32 })
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
        .margin({ top: Spacing.md })

      Text('数据来源 TMDB，仅用于学习非商用')
        .fontSize(10)
        .fontColor(Colors.textTertiary)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: Spacing.xl, bottom: Spacing.lg })
  }
}

export default MinePage
