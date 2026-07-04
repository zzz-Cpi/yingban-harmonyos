// 首页 - 内容发现入口（深度精细化高级静谧浪漫风格优化版）
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockCategories, Category, mockNowPlaying, mockTrending, mockPopularMovies, mockOnAirTv } from '../../model/MockData'
import { TMDBMedia, getImageUrl, getMediaTitle, getMediaYear, getTestVideoUrl } from '../../model/TMDBTypes'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'
import promptAction from '@ohos.promptAction'

const TAG = 'HomePage'

interface CategoryItemData {
  icon: Resource
  name: string
  id: number
}

@Component
struct HomePage {
  @State private searchText: string = ''
  @State private nowPlaying: TMDBMedia[] = []
  @State private trending: TMDBMedia[] = []
  @State private popularMovies: TMDBMedia[] = []
  @State private onAirTv: TMDBMedia[] = []
  @State private isLoading: boolean = false
  @State private hasError: boolean = false
  @State private errorMsg: string = ''
  @State private useMockData: boolean = true
  // 新增：按钮按压状态管理
  @State private categoryPressedStates: boolean[] = [false, false, false, false, false]
  @State private refreshPressed: boolean = false
  @State private searchPressed: boolean = false
  // 新增：自动轮播相关
  private currentCarouselIndex: number = 0
  private scrollController: Scroller = new Scroller()
  private isCarouselActive: boolean = false
  private cardWidth: number = 130
  private cardGap: number = 12

  aboutToAppear(): void {
    this.loadAllData()
  }

  aboutToDisappear(): void {
    this.stopCarousel()
  }

  private startCarousel(): void {
    this.isCarouselActive = true
    this.scheduleNextSlide()
  }

  private scheduleNextSlide(): void {
    if (!this.isCarouselActive) {
      return
    }
    setTimeout(() => {
      if (!this.isCarouselActive) {
        return
      }
      if (this.nowPlaying.length > 0) {
        this.currentCarouselIndex = (this.currentCarouselIndex + 1) % this.nowPlaying.length
        const cardSize: number = this.cardWidth + this.cardGap
        const offset: number = this.currentCarouselIndex * cardSize
        animateTo({
          duration: 600,
          curve: Curve.EaseOut,
          onFinish: () => {
            this.scheduleNextSlide()
          }
        }, () => {
          this.scrollController.scrollTo({ xOffset: offset, yOffset: 0 })
        })
      } else {
        this.scheduleNextSlide()
      }
    }, 2000)
  }

  private stopCarousel(): void {
    this.isCarouselActive = false
  }

  private async loadAllData(): Promise<void> {
    this.isLoading = false
    this.hasError = false
    this.errorMsg = ''
    this.useMockData = true
    this.nowPlaying = mockNowPlaying.results
    this.trending = mockTrending.results.slice(0, 8)
    this.popularMovies = mockPopularMovies.results.slice(0, 8)
    this.onAirTv = mockOnAirTv.results.slice(0, 8)
    this.startCarousel()
  }

  private refreshRecommendations(): void {
    this.loadAllData()
  }

  private async navigateToPlayer(media: TMDBMedia): Promise<void> {
    let videoUrl: string | Resource = ''

    if (media.trailer_url !== undefined && media.trailer_url !== null) {
      videoUrl = media.trailer_url
    } else {
      videoUrl = getTestVideoUrl(media.id)
    }

    router.pushUrl({
      url: 'pages/home/VideoPlayerPage',
      params: {
        videoUrl: videoUrl,
        title: getMediaTitle(media),
        posterUrl: media.poster_path,
        rating: media.vote_average,
        year: getMediaYear(media),
        overview: media.overview,
        mediaType: media.media_type,
        episodeCount: media.episode_count
      }
    })
    hilog.info(0, TAG, `Navigate to player: ${getMediaTitle(media)}`)
  }

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

  // 获取随机状态铭牌
  private getRandomBadge(): string {
    const badges: string[] = ['上新', 'VIP', '限免', '热播', '推荐']
    const index: number = Math.floor(Math.random() * badges.length)
    return badges[index]
  }

  build() {
    Stack() {
      // ========== 优化点1：全局底层背景改造 - 模糊渐变氛围背景 ==========
      if (this.nowPlaying.length > 0) {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              [0x40FFC0CB, 0],    // 顶部半透明粉色
              [0x30E0F0F5, 0.4],  // 中部浅青蓝
              [0x15FFFAF0, 0.7],  // 底部浅米白
              [0x00FFFFFF, 1]     // 完全透明过渡到底色
            ]
          })
          .backdropBlur(80) // 高斯模糊
      }

      Column() {
        this.TopNavBar()

        Scroll() {
          Column({ space: 24 }) {
            // ========== 优化点2：板块分层重构 - 独立磨砂容器+均匀留白 ==========
            this.TodayUpdates()
            this.AIRecommendation()
            this.CategoryIcons()
            this.MovieSection('热门电影', this.popularMovies.slice(0, 4))
            this.MovieSection('热播剧集', this.onAirTv.slice(0, 4))
          }
          .padding({ top: 24, bottom: 40 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFAF5') // 浅米白页面底色
  }

  // ========== 优化点4：顶部搜索栏优化 - 磨砂半透明+粉蓝渐变文字 ==========
  @Builder
  TopNavBar() {
    Row() {
      Text('影伴')
        .fontSize(28)
        .fontWeight(700)
        .letterSpacing(4)
        .fontColor('#C8B8C0')
        .textShadow([
          { radius: 0, color: 'rgba(120,110,120,0.25)', offsetX: 0.8, offsetY: 0 },
          { radius: 0, color: 'rgba(120,110,120,0.25)', offsetX: -0.8, offsetY: 0 },
          { radius: 0, color: 'rgba(120,110,120,0.25)', offsetX: 0, offsetY: 0.8 },
          { radius: 0, color: 'rgba(120,110,120,0.25)', offsetX: 0, offsetY: -0.8 }
        ])

      Blank()

      // 搜索框 - 磨砂半透明浅粉蓝圆角容器
      Row() {
        Image($r('app.media.sousuo'))
          .width(16)
          .height(16)
          .opacity(0.6) // 低饱和浅灰图标

        Text('搜索电影/剧集/演员')
          .fontSize(FontSizes.caption)
          .fontColor('#A0A0A8') // 低饱和浅灰文字
          .margin({ left: 10 })
      }
      .width(200)
      .height(40)
      .backgroundColor('rgba(255,240,245,0.65)') // 极淡粉蓝磨砂背景
      .backdropBlur(18)
      .borderRadius(20) // 大圆角
      .border({ width: 1, color: 'rgba(232,160,176,0.15)' }) // 弱化边框
      .padding({ left: 14, right: 14 })
      .scale({ x: this.searchPressed ? 0.96 : 1, y: this.searchPressed ? 0.96 : 1 }) // 按压缩放动效
      .animation({
        duration: 150,
        curve: Curve.EaseOut
      })
      .onClick(() => {
        this.searchPressed = true
        setTimeout(() => {
          this.searchPressed = false
        }, 150)
        try {
          router.pushUrl({ url: 'pages/home/SearchPage' })
        } catch (err) {
          hilog.error(0, TAG, 'Navigate to search failed')
        }
      })

      // 相机图标 - 磨砂圆形背景
      Stack() {
        Row()
          .width(40)
          .height(40)
          .backgroundColor('rgba(255,240,245,0.65)')
          .backdropBlur(18)
          .borderRadius(20)
          .border({ width: 1, color: 'rgba(160,200,216,0.15)' })

        Image($r('app.media.xiangji'))
          .width(22)
          .height(22)
          .opacity(0.7)
      }
      .margin({ left: Spacing.lg })
      .onClick(() => {
        promptAction.showToast({ message: '拍照搜片功能开发中', duration: 1500 })
      })
    }
    .width('100%')
    .height(64)
    .padding({ left: 20, right: 20 })
    .backgroundColor('rgba(255,250,245,0.8)') // 极淡米白磨砂背景
    .backdropBlur(25)
  }

  // ========== 优化点2+3：正在热映 - 独立磨砂容器+海报卡片精细化 ==========
  @Builder
  TodayUpdates() {
    Column() {
      Row() {
        Text('正在热映')
          .fontSize(24)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')

        Text(this.nowPlaying.length + '部')
          .fontSize(FontSizes.caption)
          .fontColor('#A0A0A8')
          .margin({ left: 10 })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Stack() {
        Scroll(this.scrollController) {
          Row({ space: this.cardGap }) {
            ForEach(this.nowPlaying, (item: TMDBMedia, index: number) => {
              this.CarouselCard(item, index)
            }, (item: TMDBMedia) => item.id.toString())
          }
          .padding({ left: '10%', right: '10%' })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .onScrollStop(() => {
          this.updateCarouselIndex()
        })

        Column()
          .width(50)
          .height(220)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['rgba(255,250,245,0.95)', 0], ['rgba(255,250,245,0)', 1]]
          })
          .position({ x: 0, y: 0 })

        Column()
          .width(50)
          .height(220)
          .linearGradient({
            direction: GradientDirection.Left,
            colors: [['rgba(255,250,245,0.95)', 0], ['rgba(255,250,245,0)', 1]]
          })
          .position({ x: '100%', y: 0 })
          .translate({ x: -50 })
      }
      .width('100%')
      .height(220)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(232,160,176,0.12)' })
    .shadow({ radius: 12, color: 'rgba(232,160,176,0.08)', offsetX: 0, offsetY: 4 })
    .margin({ left: 16, right: 16 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  private updateCarouselIndex(): void {
    const scrollOffset: number = this.scrollController.currentOffset().xOffset
    const cardSize: number = this.cardWidth + this.cardGap
    this.currentCarouselIndex = Math.round(scrollOffset / cardSize)
  }

  // ========== 轮播卡片 - 支持居中缩放效果 ==========
  @Builder
  CarouselCard(item: TMDBMedia, index: number) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(this.getPosterResource(item.poster_path))
          .width(this.cardWidth)
          .height(180)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E8E8F0')

        Column() {
          Text(getMediaTitle(item))
            .fontSize(FontSizes.caption)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text('⭐ ' + item.vote_average.toFixed(1))
            .fontSize(10)
            .fontColor(Color.White)
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ left: 10, right: 10, bottom: 12, top: 20 })
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['rgba(0,0,0,0.65)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .alignItems(HorizontalAlign.Start)

        Text(this.getRandomBadge())
          .fontSize(9)
          .fontColor(Color.White)
          .fontWeight(FontWeightValue.medium)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#D8B0C0', 0], ['#B0D0E0', 1]]
          })
          .borderRadius(10)
          .shadow({ radius: 4, color: 'rgba(216,176,192,0.35)', offsetX: 0, offsetY: 2 })
          .position({ x: '100%', y: 8 })
          .translate({ x: -45 })

        Text('⭐' + item.vote_average.toFixed(1))
          .fontSize(10)
          .fontColor(Color.White)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
          })
          .borderRadius(12)
          .position({ x: 8, y: '100%' })
          .translate({ y: -28 })
      }
      .width(this.cardWidth)
      .height(180)
    }
    .width(this.cardWidth)
    .onClick(() => {
      this.navigateToPlayer(item)
    })
  }

  // ========== 优化点3：影视海报卡片精细化升级 ==========
  @Builder
  MediaCard(item: TMDBMedia, isFirst: boolean, isLast: boolean) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        // 海报图片 - 16dp圆角
        Image(this.getPosterResource(item.poster_path))
          .width(130)
          .height(180)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E8E8F0')

        // ========== 优化点3①：底部半透明黑色渐变遮罩承载剧名评分 ==========
        Column() {
          Text(getMediaTitle(item))
            .fontSize(FontSizes.caption)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text('⭐ ' + item.vote_average.toFixed(1))
            .fontSize(10)
            .fontColor(Color.White)
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ left: 10, right: 10, bottom: 12, top: 20 })
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['rgba(0,0,0,0.65)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .alignItems(HorizontalAlign.Start)

        // ========== 优化点3②：右上角悬浮圆角渐变状态铭牌 + 微弱柔光阴影 ==========
        Text(this.getRandomBadge())
          .fontSize(9)
          .fontColor(Color.White)
          .fontWeight(FontWeightValue.medium)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#D8B0C0', 0], ['#B0D0E0', 1]] // 雾面粉蓝渐变
          })
          .borderRadius(10)
          .shadow({ radius: 4, color: 'rgba(216,176,192,0.35)', offsetX: 0, offsetY: 2 }) // 微弱柔光阴影
          .position({ x: '100%', y: 8 })
          .translate({ x: -45 })

        // ========== 优化点3③：左下角雾面粉蓝渐变圆角评分标签 ==========
        Text('⭐' + item.vote_average.toFixed(1))
          .fontSize(10)
          .fontColor(Color.White)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#E8A0B0', 0], ['#A0C8D8', 1]] // 雾面粉蓝渐变
          })
          .borderRadius(12)
          .position({ x: 8, y: '100%' })
          .translate({ y: -28 })
      }
      .width(130)
      .height(180)
      .margin({ left: isFirst ? 0 : 0, right: isLast ? 0 : 0 })
    }
    .width(130)
    .onClick(() => {
      this.navigateToPlayer(item)
    })
  }

  // ========== 优化点6：为你推荐 + 换一批按钮美化 ==========
  @Builder
  AIRecommendation() {
    Column() {
      Row() {
        Column() {
          Text('为你推荐')
            .fontSize(24) // 板块大标题24sp加粗
            .fontWeight(FontWeightValue.bold)
            .fontColor('#2D2D3A')

          Text('本周热门内容')
            .fontSize(FontSizes.helper)
            .fontColor('#A0A0A8') // 低饱和浅灰辅助小字
        }

        Blank()

        // ========== 优化点6：换一批按钮美化 - 磨砂粉蓝渐变细描边 ==========
        Row() {
          Image($r('app.media.shuaxin'))
            .width(14)
            .height(14)

          Text('换一批')
            .fontSize(FontSizes.caption)
            .fontColor('#C8A8B8') // 低饱和粉灰
            .margin({ left: 6 })
        }
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor('rgba(255,240,245,0.68)')
        .backdropBlur(12)
        .borderRadius(14)
        .border({ width: 1.5, color: 'rgba(232,160,176,0.25)' }) // 粉蓝渐变细描边
        .scale({ x: this.refreshPressed ? 0.96 : 1, y: this.refreshPressed ? 0.96 : 1 })
        .animation({
          duration: 150,
          curve: Curve.EaseOut
        })
        .onClick(() => {
          this.refreshPressed = true
          setTimeout(() => {
            this.refreshPressed = false
          }, 150)
          this.refreshRecommendations()
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.trending, (movie: TMDBMedia) => {
            Column() {
              Image(this.getPosterResource(movie.poster_path))
                .width(110)
                .height(160)
                .borderRadius(16)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#E8E8F0')

              Text(getMediaTitle(movie))
                .fontSize(FontSizes.helper)
                .fontColor('#2D2D3A')
                .margin({ top: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(110)
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
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(160,200,216,0.12)' })
    .shadow({ radius: 12, color: 'rgba(160,200,216,0.08)', offsetX: 0, offsetY: 4 })
    .margin({ left: 16, right: 16 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  // ========== 优化点5：分类快捷入口改造 - 磨砂淡粉蓝渐变+按压缩放动效 ==========
  @Builder
  CategoryIcons() {
    Column() {
      Scroll() {
        Row({ space: 20 }) {
          ForEach([
            { icon: $r('app.media.cat_movie'), name: '电影', id: 1 },
            { icon: $r('app.media.cat_tv'), name: '剧集', id: 2 },
            { icon: $r('app.media.cat_suspense'), name: '悬疑', id: 3 },
            { icon: $r('app.media.cat_comedy'), name: '喜剧', id: 4 },
            { icon: $r('app.media.cat_toprated'), name: '高分', id: 5 }
          ] as CategoryItemData[], (item: CategoryItemData, index: number) => {
            this.CategoryItem(item.icon, item.name, item.id, index)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(232,160,176,0.12)' })
    .shadow({ radius: 12, color: 'rgba(232,160,176,0.08)', offsetX: 0, offsetY: 4 })
    .margin({ left: 16, right: 16 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  @Builder
  CategoryItem(icon: Resource, name: string, id: number, index: number) {
    Column() {
      Stack() {
        // ========== 优化点5：20dp圆角磨砂淡粉蓝渐变底色 ==========
        Row()
          .width(56)
          .height(56)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#E8A0B0', 0], ['#A0C8D8', 1]] // 低饱和粉蓝渐变
          })
          .opacity(0.35)
          .borderRadius(20) // 20dp圆角

        // 简约线性矢量图标
        Image(icon)
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
      }
      .scale({ x: this.categoryPressedStates[index] ? 0.92 : 1, y: this.categoryPressedStates[index] ? 0.92 : 1 }) // 按压缩放动效
      .animation({
        duration: 150,
        curve: Curve.EaseOut
      })

      Text(name)
        .fontSize(FontSizes.helper)
        .fontColor('#2D2D3A')
        .margin({ top: 10 })
    }
    .padding(8)
    .onClick(() => {
      this.categoryPressedStates[index] = true
      setTimeout(() => {
        this.categoryPressedStates[index] = false
      }, 150)
      try {
        router.pushUrl({
          url: 'pages/home/LibraryPage',
          params: { categoryId: id }
        })
      } catch (err) {
        hilog.error(0, TAG, 'Navigate to library failed')
      }
    })
  }

  // 电影区块 - 磨砂半透明卡片优化
  @Builder
  MovieSection(title: string, movies: TMDBMedia[]) {
    Column() {
      Row() {
        Text(title)
          .fontSize(24) // 板块大标题24sp加粗
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')

        Blank()

        Row() {
          Text('更多')
            .fontSize(FontSizes.caption)
            .fontColor('#A0A0A8')

          Text('›')
            .fontSize(14)
            .fontColor('#A0A0A8')
            .margin({ left: 4 })
        }
        .onClick(() => {
          try {
            router.pushUrl({ url: 'pages/home/LibraryPage' })
          } catch (err) {
            hilog.error(0, TAG, 'Navigate to library failed')
          }
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Grid() {
        ForEach(movies, (movie: TMDBMedia) => {
          GridItem() {
            this.MovieCard(movie)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .height(260)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(160,200,216,0.12)' })
    .shadow({ radius: 12, color: 'rgba(160,200,216,0.08)', offsetX: 0, offsetY: 4 })
    .margin({ left: 16, right: 16 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  @Builder
  MovieCard(movie: TMDBMedia) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.getPosterResource(movie.poster_path))
          .width('100%')
          .height(160)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E8E8F0')

        // 评分标签 - 雾面粉蓝渐变
        Row() {
          Text('⭐ ' + movie.vote_average.toFixed(1))
            .fontSize(10)
            .fontColor(Color.White)
        }
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
        })
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .borderRadius(12)
        .margin(8)
      }

      Text(getMediaTitle(movie))
        .fontSize(FontSizes.caption)
        .fontColor('#2D2D3A')
        .margin({ top: 10 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(getMediaYear(movie))
        .fontSize(FontSizes.helper)
        .fontColor('#A0A0A8')
        .margin({ top: 4 })
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