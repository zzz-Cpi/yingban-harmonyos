// 追剧页 - 多平台追剧管理
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockDramas, mockPlaylists, Drama, Playlist } from '../../model/MockData'

@Component
struct DramaPage {
  @State private currentTab: number = 1
  @State private currentPlaylist: number = 1

  private statusTabs: string[] = ['想看', '在看', '已看']

  build() {
    Column() {
      // 顶部状态切换栏
      this.StatusTabBar()

      // 片单筛选横栏
      this.PlaylistBar()

      // 追剧卡片网格
      this.DramaGrid()

      // 悬浮添加按钮
      this.AddButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  StatusTabBar() {
    Column() {
      Row() {
        Row() {
          ForEach(this.statusTabs, (tab: string, index: number) => {
            Column() {
              Text(tab)
                .fontSize(FontSizes.body)
                .fontColor(this.currentTab === index ? Colors.primary : Colors.textSecondary)
                .fontWeight(this.currentTab === index ? FontWeightValue.semibold : FontWeightValue.regular)

              // 选中指示器
              if (this.currentTab === index) {
                Row()
                  .width(24)
                  .height(3)
                  .backgroundColor(Colors.primary)
                  .borderRadius(2)
                  .margin({ top: 4 })
              }
            }
            .width(60)
            .onClick(() => {
              this.currentTab = index
            })
          })
        }
        .layoutWeight(1)

        Text('共' + mockDramas.length + '部')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.md })
      .backgroundColor(Color.White)
    }
  }

  @Builder
  PlaylistBar() {
    Column() {
      Scroll() {
        Row({ space: Spacing.md }) {
          ForEach(mockPlaylists, (playlist: Playlist) => {
            Row() {
              Text(playlist.name)
                .fontSize(FontSizes.caption)
                .fontColor(this.currentPlaylist === playlist.id ? Colors.primary : Colors.textSecondary)

              if (playlist.count > 0) {
                Text(playlist.count.toString())
                  .fontSize(10)
                  .fontColor(Color.White)
                  .backgroundColor(this.currentPlaylist === playlist.id ? Colors.primary : Colors.textTertiary)
                  .borderRadius(10)
                  .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                  .margin({ left: 4 })
              }
            }
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.currentPlaylist === playlist.id ? '#FFF0F0' : '#F5F5F5')
            .borderRadius(BorderRadius.small)
            .onClick(() => {
              this.currentPlaylist = playlist.id
            })
          })

          // 新建片单按钮
          Row() {
            Text('+')
              .fontSize(FontSizes.body)
              .fontColor(Colors.textSecondary)

            Text('新建')
              .fontSize(FontSizes.caption)
              .fontColor(Colors.textSecondary)
              .margin({ left: 2 })
          }
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .borderRadius(BorderRadius.small)
          .border({ width: 1, color: Colors.textTertiary, style: BorderStyle.Dashed })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
    .backgroundColor(Color.White)
  }

  @Builder
  DramaGrid() {
    Scroll() {
      Grid() {
        ForEach(this.getFilteredDramas(), (drama: Drama) => {
          GridItem() {
            this.DramaCard(drama)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Spacing.md)
      .rowsGap(Spacing.md)
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  // 获取海报资源（支持本地资源和网络URL）
  private getPosterResource(name: string): Resource | string {
    if (name.startsWith('http')) {
      return name
    }
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
      default: return $r('app.media.startIcon')
    }
  }

  @Builder
  DramaCard(drama: Drama) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        // 海报
        Image(this.getPosterResource(drama.movie.posterUrl))
          .width('100%')
          .height(160)
          .borderRadius(BorderRadius.large)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E0E0E0')

        // 状态标签
        Text(this.getStatusText(drama.status))
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.getStatusColor(drama.status))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius({ topRight: BorderRadius.large, bottomLeft: BorderRadius.small })
      }

      // 剧名
      Text(drama.movie.title)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.sm })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 平台
      Row({ space: 4 }) {
        ForEach(drama.movie.platform.slice(0, 2), (p: string) => {
          Text(p)
            .fontSize(10)
            .fontColor(Colors.textSecondary)
        })
      }
      .margin({ top: 2 })

      // 进度条
      if (drama.status === 'watching') {
        Column() {
          Row() {
            Text('更新至' + drama.currentEpisode + '/' + drama.totalEpisodes + '集')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .width('100%')
          .margin({ bottom: 4 })

          Stack() {
            // 背景
            Row()
              .width('100%')
              .height(4)
              .backgroundColor('#E0E0E0')
              .borderRadius(2)

            // 进度
            Row()
              .width(drama.watchProgress + '%')
              .height(4)
              .backgroundColor(Colors.primary)
              .borderRadius(2)
          }
        }
        .width('100%')
        .margin({ top: Spacing.sm })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.large)
    .padding(Spacing.sm)
  }

  @Builder
  AddButton() {
    Column() {
      Button('+')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontColor(Color.White)
        .backgroundColor(Colors.primary)
        .borderRadius(28)
        .onClick(() => {
          // 添加追剧
        })
    }
    .position({ x: '85%', y: '80%' })
  }

  private getFilteredDramas(): Drama[] {
    const statusMap: string[] = ['want', 'watching', 'finished']
    const status: string = statusMap[this.currentTab]
    const result: Drama[] = []
    for (let i: number = 0; i < mockDramas.length; i++) {
      if (mockDramas[i].status === status) {
        result.push(mockDramas[i])
      }
    }
    return result
  }

  private getStatusText(status: string): string {
    if (status === 'want') return '想看'
    if (status === 'watching') return '在看'
    if (status === 'finished') return '已看'
    return status
  }

  private getStatusColor(status: string): string {
    if (status === 'want') return Colors.warning
    if (status === 'watching') return Colors.primary
    if (status === 'finished') return Colors.success
    return Colors.textSecondary
  }
}

export default DramaPage
