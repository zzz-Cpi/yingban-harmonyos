// 首页 - 内容发现入口（对接TMDB真实API，失败时降级到Mock数据）
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../utils/Constants'
import { mockCategories, Category, mockNowPlaying, mockTrending, mockPopularMovies, mockOnAirTv } from '../model/MockData'
import { getTMDBService, TMDBService } from '../model/TMDBService'
import { TMDBMedia, getImageUrl, getMediaTitle, getMediaYear, getTestVideoUrl } from '../model/TMDBTypes'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'HomePage'

@Component
struct HomePage {
  @State private searchText: string = ''
  @State private nowPlaying: TMDBMedia[] = []
  @State private trending: TMDBMedia[] = []
  @State private popularMovies: TMDBMedia[] = []
  @State private onAirTv: TMDBMedia[] = []
  @State private isLoading: boolean = true
  @State private hasError: boolean = false
  @State private errorMsg: string = ''
  @State private useMockData: boolean = false
  private tmdbService: TMDBService | null = null

  aboutToAppear(): void {
    this.tmdbService = getTMDBService()
    this.loadAllData()
  }

  aboutToDisappear(): void {
    if (this.tmdbService) {
      this.tmdbService.destroy()
      this.tmdbService = null
    }
  }

  private async loadAllData(): Promise<void> {
    this.isLoading = true
    this.hasError = false
    this.errorMsg = ''

    try {
      if (!this.tmdbService) {
        throw new Error('服务未初始化')
      }

      // 顺序加载所有数据
      const nowPlayingRes = await this.tmdbService.getNowPlayingMovies(1)
      const trendingRes = await this.tmdbService.getTrending(1)
      const popularRes = await this.tmdbService.getPopularMovies(1)
      const tvRes = await this.tmdbService.getOnTheAirTv(1)

      this.nowPlaying = nowPlayingRes.results.slice(0, 6)
      this.trending = trendingRes.results.slice(0, 8)
      this.popularMovies = popularRes.results.slice(0, 8)
      this.onAirTv = tvRes.results.slice(0, 8)
      this.useMockData = false

      this.isLoading = false
    } catch (e) {
      const err = e as Error
      console.error('TMDB API 加载失败，自动使用 Mock 数据: ' + err.message)
      // API 加载失败，自动降级到 Mock 数据，确保页面有内容展示
      this.useMockData = true
      this.hasError = false
      this.nowPlaying = mockNowPlaying.results.slice(0, 6)
      this.trending = mockTrending.results.slice(0, 8)
      this.popularMovies = mockPopularMovies.results.slice(0, 8)
      this.onAirTv = mockOnAirTv.results.slice(0, 8)
      this.isLoading = false
    }
  }

  private refreshRecommendations(): void {
    this.loadAllData()
  }

  private navigateToPlayer(media: TMDBMedia): void {
    try {
      let videoUrl: string | Resource = ''
      if (media.trailer_url !== undefined && media.trailer_url !== null) {
        videoUrl = media.trailer_url
      } else {
        videoUrl = getTestVideoUrl(media.id)
      }
      router.pushUrl({
        url: 'pages/VideoPlayerPage',
        params: {
          videoUrl: videoUrl,
          title: getMediaTitle(media),
          posterUrl: media.poster_path,
          rating: media.vote_average,
          year: getMediaYear(media),
          overview: media.overview
        }
      })
      hilog.info(0, TAG, `Navigate to player: ${getMediaTitle(media)}`)
    } catch (err) {
      hilog.error(0, TAG, 'Failed to navigate to player')
    }
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

  build() {
    Column() {
      // 顶部导航栏
      this.TopNavBar()

      if (this.isLoading) {
        // 加载中状态
        this.LoadingView()
      } else if (this.hasError) {
        // 错误状态
        this.ErrorView()
      } else {
        // 内容区
        Scroll() {
          Column() {
            // 今日更新（正在上映）
            this.TodayUpdates()

            // 为你推荐（本周热门）
            this.AIRecommendation()

            // 分类快捷入口
            this.CategoryIcons()

            // 热门电影
            this.MovieSection('热门电影', this.popularMovies.slice(0, 4))

            // 热播剧集
            this.MovieSection('热播剧集', this.onAirTv.slice(0, 4))
          }
          .padding({ bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  LoadingView() {
    Column() {
      // 简单加载动画
      Text('⏳')
        .fontSize(40)

      Text('正在加载...')
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textSecondary)
        .margin({ top: Spacing.md })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorView() {
    Column() {
      Text('😢')
        .fontSize(48)

      Text('加载失败')
        .fontSize(FontSizes.body)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.md })

      Text('错误: ' + this.errorMsg)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.error)
        .margin({ top: Spacing.sm })
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Button('重新加载')
          .fontSize(FontSizes.caption)
          .fontColor(Color.White)
          .backgroundColor(Colors.primary)
          .borderRadius(BorderRadius.button)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => {
            this.loadAllData()
          })

        Button('使用Mock数据')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.primary)
          .backgroundColor('#FFF0F0')
          .borderRadius(BorderRadius.button)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .margin({ left: Spacing.md })
          .onClick(() => {
            this.useMockData = true
            this.hasError = false
            this.nowPlaying = mockNowPlaying.results.slice(0, 6)
            this.trending = mockTrending.results.slice(0, 8)
            this.popularMovies = mockPopularMovies.results.slice(0, 8)
            this.onAirTv = mockOnAirTv.results.slice(0, 8)
          })
      }
      .margin({ top: Spacing.lg })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ left: Spacing.lg, right: Spacing.lg })
  }

  @Builder
  TopNavBar() {
    Row() {
      // Logo
      Text('影伴')
        .fontSize(FontSizes.pageTitle)
        .fontWeight(FontWeightValue.bold)
        .fontColor(Colors.primary)

      Blank()

      // 搜索框
      Row() {
        Text('🔍')
          .fontSize(14)

        Text('搜索电影/剧集/演员')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textTertiary)
          .margin({ left: 8 })
      }
      .width(200)
      .height(36)
      .backgroundColor('#F5F5F5')
      .borderRadius(BorderRadius.medium)
      .padding({ left: 12, right: 12 })
      .onClick(() => {
        try {
          router.pushUrl({ url: 'pages/SearchPage' })
        } catch (err) {
          hilog.error(0, TAG, 'Navigate to search failed')
        }
      })

      // 扫码图标
      Text('📷')
        .fontSize(20)
        .margin({ left: Spacing.lg })
    }
    .width('100%')
    .height(56)
    .padding({ left: Spacing.lg, right: Spacing.lg })
    .backgroundColor(Color.White)
  }

  @Builder
  TodayUpdates() {
    Column() {
      Row() {
        Text('正在热映')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)

        Text(this.nowPlaying.length + '部')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      Scroll() {
        Row({ space: Spacing.md }) {
          ForEach(this.nowPlaying, (item: TMDBMedia) => {
            Column() {
              Stack({ alignContent: Alignment.BottomStart }) {
                // 海报
                Image(this.getPosterResource(item.poster_path))
                  .width(120)
                  .height(160)
                  .borderRadius(BorderRadius.medium)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor('#E0E0E0')

                // 评分标签
                Text('⭐' + item.vote_average.toFixed(1))
                  .fontSize(10)
                  .fontColor(Color.White)
                  .backgroundColor('rgba(0,0,0,0.7)')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius({ topLeft: BorderRadius.medium, bottomRight: BorderRadius.medium })
              }

              // 剧名
              Text(getMediaTitle(item))
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textPrimary)
                .margin({ top: Spacing.sm })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(120)
            .onClick(() => {
              this.navigateToPlayer(item)
            })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg })
  }

  @Builder
  AIRecommendation() {
    Column() {
      Row() {
        Column() {
          Text('为你推荐')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Colors.textPrimary)

          Text('本周热门内容')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }

        Blank()

        // 换一批按钮
        Row() {
          Text('换一批')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.primary)

          Text('🔄')
            .fontSize(12)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#FFF0F0')
        .borderRadius(BorderRadius.small)
        .onClick(() => {
          this.refreshRecommendations()
        })
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      Scroll() {
        Row({ space: Spacing.md }) {
          ForEach(this.trending, (movie: TMDBMedia) => {
            Column() {
              Stack() {
                Image(this.getPosterResource(movie.poster_path))
                  .width(100)
                  .height(140)
                  .borderRadius(BorderRadius.medium)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor('#E0E0E0')
              }

              Text(getMediaTitle(movie))
                .fontSize(FontSizes.helper)
                .fontColor(Colors.textPrimary)
                .margin({ top: Spacing.sm })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(100)
            .onClick(() => {
              this.navigateToPlayer(movie)
            })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  CategoryIcons() {
    Column() {
      Scroll() {
        Row({ space: Spacing.xl }) {
          ForEach(mockCategories, (cat: Category) => {
            Column() {
              Stack() {
                Row()
                  .width(48)
                  .height(48)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(24)

                Text(cat.icon)
                  .fontSize(20)
              }

              Text(cat.name)
                .fontSize(FontSizes.helper)
                .fontColor(Colors.textPrimary)
                .margin({ top: Spacing.sm })
            }
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  MovieSection(title: string, movies: TMDBMedia[]) {
    Column() {
      Row() {
        Text(title)
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)

        Blank()

        Row() {
          Text('更多')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textSecondary)

          Text('>')
            .fontSize(12)
            .fontColor(Colors.textSecondary)
            .margin({ left: 2 })
        }
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      Grid() {
        ForEach(movies, (movie: TMDBMedia) => {
          GridItem() {
            this.MovieCard(movie)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Spacing.md)
      .rowsGap(Spacing.md)
      .height(240)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  MovieCard(movie: TMDBMedia) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.getPosterResource(movie.poster_path))
          .width('100%')
          .height(140)
          .borderRadius(BorderRadius.medium)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E0E0E0')

        // 评分标签
        Row() {
          Text('⭐ ' + movie.vote_average.toFixed(1))
            .fontSize(10)
            .fontColor(Color.White)
        }
        .backgroundColor('rgba(0,0,0,0.6)')
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius({ topRight: BorderRadius.medium, bottomLeft: BorderRadius.small })
      }

      Text(getMediaTitle(movie))
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.sm })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(getMediaYear(movie))
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textSecondary)
        .margin({ top: 2 })
        .maxLines(1)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.navigateToPlayer(movie)
    })
  }
}

export default HomePage
