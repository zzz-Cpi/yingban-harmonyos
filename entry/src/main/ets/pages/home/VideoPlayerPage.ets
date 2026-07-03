// 视频播放详情页（粉蓝磨砂浪漫高级风格优化版）
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockTrending } from '../../model/MockData'
import { TMDBMedia, getMediaTitle, getMediaYear } from '../../model/TMDBTypes'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'
import promptAction from '@ohos.promptAction'
import window from '@ohos.window'
import { SakuraLoading } from '../../components/SakuraLoading'

const TAG = 'VideoPlayerPage'

interface RouteParams {
  videoUrl?: string | Resource
  title?: string
  posterUrl?: string
  rating?: number
  year?: string
  overview?: string
}

interface PreparedEvent {
  duration: number
}

interface UpdateEvent {
  time: number
}

interface EpisodeInfo {
  index: number
  title: string
  isWatched: boolean
  isPlaying: boolean
}

@Entry
@Component
struct VideoPlayerPage {
  @State private videoUrl: string | Resource = ''
  @State private title: string = ''
  @State private posterUrl: string = ''
  @State private rating: number = 0
  @State private year: string = ''
  @State private overview: string = ''
  @State private isPlaying: boolean = false
  @State private currentTime: number = 0
  @State private duration: number = 0
  @State private errorMessage: string = ''
  @State private isLoading: boolean = true
  // 新增：控制栏显示状态
  @State private showControls: boolean = true
  @State private isFullscreen: boolean = false
  // 新增：折叠状态
  @State private isOverviewExpanded: boolean = false
  // 新增：按钮按压状态
  @State private playBtnPressed: boolean = false
  @State private fullscreenBtnPressed: boolean = false
  @State private syncBtnPressed: boolean = false
  @State private noteBtnPressed: boolean = false
  @State private shareBtnPressed: boolean = false
  @State private favBtnPressed: boolean = false
  @State private addDramaPressed: boolean = false
  @State private openWebPressed: boolean = false
  // 新增：分集数据
  @State private episodes: EpisodeInfo[] = []
  @State private currentEpisode: number = 1
  // 新增：推荐数据
  @State private similarMovies: TMDBMedia[] = []
  @State private actorMovies: TMDBMedia[] = []
  private videoController: VideoController = new VideoController()
  private windowClass: window.Window | null = null

  aboutToAppear(): void {
    this.initPage()
    this.initMockData()
    this.initWindow()
  }

  aboutToDisappear(): void {
    // 退出全屏，恢复状态栏
    this.exitFullscreenRestore()
    try {
      this.videoController.stop()
    } catch (e) {
      hilog.warn(0, TAG, 'Stop video failed')
    }
  }

  private initWindow(): void {
    try {
      window.getLastWindow(getContext(this)).then((win: window.Window) => {
        this.windowClass = win
      }).catch((err: Error) => {
        hilog.warn(0, TAG, `Get window failed: ${err.message}`)
      })
    } catch (e) {
      hilog.warn(0, TAG, 'Init window failed')
    }
  }

  // 退出全屏时恢复状态栏
  private exitFullscreenRestore(): void {
    if (this.windowClass && this.isFullscreen) {
      try {
        this.windowClass.setWindowSystemBarProperties({
          statusBarColor: '#00000000',
          statusBarContentColor: 'dark',
          navigationBarColor: '#FFFFFF',
          navigationBarContentColor: 'dark'
        })
      } catch (e) {
        hilog.warn(0, TAG, 'Restore system bar failed')
      }
    }
  }

  private initPage(): void {
    const params = router.getParams() as RouteParams
    let hasVideo: boolean = false
    if (params) {
      if (params.videoUrl !== undefined && params.videoUrl !== null) {
        this.videoUrl = params.videoUrl
        hasVideo = true
      }
      this.title = params.title || '预告片'
      this.posterUrl = params.posterUrl || ''
      this.rating = params.rating || 0
      this.year = params.year || ''
      this.overview = params.overview || ''
    }

    if (!hasVideo) {
      this.errorMessage = '视频地址无效'
      this.isLoading = false
    }
  }

  private initMockData(): void {
    // 初始化分集数据
    this.episodes = []
    for (let i = 1; i <= 15; i++) {
      this.episodes.push({
        index: i,
        title: `第${i}集`,
        isWatched: i < 5,
        isPlaying: i === 1
      })
    }

    // 初始化推荐数据
    this.similarMovies = mockTrending.results.slice(0, 6)
    this.actorMovies = mockTrending.results.slice(6, 12)
  }

  private onBack(): void {
    // 全屏模式下先退出全屏，不返回上一页
    if (this.isFullscreen) {
      this.toggleFullscreen()
      return
    }
    try {
      this.videoController.stop()
    } catch (e) {
      hilog.warn(0, TAG, 'Stop video failed')
    }
    router.back()
  }

  private onPrepared(event: PreparedEvent): void {
    this.duration = event.duration
    this.isLoading = false
    this.isPlaying = true  // autoPlay已开启，视频准备就绪后自动播放，同步状态
    hilog.info(0, TAG, `Video prepared, duration: ${event.duration}`)
  }

  private onError(): void {
    this.isPlaying = false
    this.isLoading = false
    this.errorMessage = '视频加载失败，请检查网络连接'
    hilog.error(0, TAG, 'Video play error')
  }

  private onUpdate(event: UpdateEvent): void {
    this.currentTime = event.time
  }

  private onPlayPause(): void {
    this.playBtnPressed = true
    setTimeout(() => { this.playBtnPressed = false }, 150)
    
    if (this.isPlaying) {
      this.videoController.pause()
    } else {
      this.videoController.start()
    }
    this.isPlaying = !this.isPlaying
  }

  private formatTime(seconds: number): string {
    const mins: number = Math.floor(seconds / 60)
    const secs: number = Math.floor(seconds % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  private onSliderChange(value: number): void {
    this.videoController.setCurrentTime(value)
    this.currentTime = value
  }

  private toggleControls(): void {
    this.showControls = !this.showControls
  }

  private toggleFullscreen(): void {
    this.fullscreenBtnPressed = true
    setTimeout(() => { this.fullscreenBtnPressed = false }, 150)
    this.isFullscreen = !this.isFullscreen
    this.showControls = true

    // 真正的全屏控制：隐藏/显示状态栏和导航栏
    if (this.windowClass) {
      try {
        if (this.isFullscreen) {
          // 进入全屏：隐藏状态栏和导航栏
          this.windowClass.setWindowSystemBarProperties({
            statusBarColor: '#00000000',
            statusBarContentColor: 'light',
            navigationBarColor: '#000000',
            navigationBarContentColor: 'light'
          })
          this.windowClass.setWindowLayoutFullScreen(true)
        } else {
          // 退出全屏：恢复状态栏和导航栏
          this.windowClass.setWindowLayoutFullScreen(false)
          this.windowClass.setWindowSystemBarProperties({
            statusBarColor: '#00000000',
            statusBarContentColor: 'dark',
            navigationBarColor: '#FFFFFF',
            navigationBarContentColor: 'dark'
          })
        }
      } catch (e) {
        hilog.warn(0, TAG, 'Toggle fullscreen system bar failed')
      }
    }
  }

  private onSyncWatch(): void {
    this.syncBtnPressed = true
    setTimeout(() => { this.syncBtnPressed = false }, 150)
    router.pushUrl({ url: 'pages/theater/TheaterPage' })
  }

  private onNote(): void {
    this.noteBtnPressed = true
    setTimeout(() => { this.noteBtnPressed = false }, 150)
    promptAction.showToast({ message: '观影笔记开发中' })
  }

  private onShare(): void {
    this.shareBtnPressed = true
    setTimeout(() => { this.shareBtnPressed = false }, 150)
    promptAction.showToast({ message: '分享功能开发中' })
  }

  private onFavorite(): void {
    this.favBtnPressed = !this.favBtnPressed
    setTimeout(() => { this.favBtnPressed = false }, 150)
    promptAction.showToast({ message: this.favBtnPressed ? '已收藏' : '已取消收藏' })
  }

  private onAddDrama(): void {
    this.addDramaPressed = true
    setTimeout(() => { this.addDramaPressed = false }, 150)
    promptAction.showToast({ message: '已加入追剧列表' })
  }

  private onOpenWeb(): void {
    this.openWebPressed = true
    setTimeout(() => { this.openWebPressed = false }, 150)
    promptAction.showToast({ message: '跳转腾讯视频' })
  }

  private onEpisodeClick(index: number): void {
    this.currentEpisode = index
    const newEpisodes: EpisodeInfo[] = []
    for (let i = 0; i < this.episodes.length; i++) {
      newEpisodes.push({
        index: this.episodes[i].index,
        title: this.episodes[i].title,
        isWatched: this.episodes[i].isWatched,
        isPlaying: this.episodes[i].index === index
      })
    }
    this.episodes = newEpisodes
    promptAction.showToast({ message: `播放第${index}集` })
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

  build() {
    Column() {
      // ========== 优化点1：顶部播放器沉浸式区域 ==========
      Stack({ alignContent: Alignment.TopStart }) {
        // 视频播放器
        Video({
          src: this.videoUrl,
          controller: this.videoController
        })
          .width('100%')
          .height(this.isFullscreen ? '100%' : 280)
          .backgroundColor(Color.Black)
          .autoPlay(true)
          .controls(false)
          .onPrepared((event: PreparedEvent) => {
            this.onPrepared(event)
          })
          .onError(() => {
            this.onError()
          })
          .onUpdate((event: UpdateEvent) => {
            this.onUpdate(event)
          })
          .onFinish(() => {
            this.isPlaying = false
          })
          .onClick(() => {
            this.toggleControls()
          })

        // 加载中
        if (this.isLoading) {
          Column() {
            SakuraLoading()
            Text('加载中...')
              .fontSize(FontSizes.caption)
              .fontColor(Color.White)
              .margin({ top: Spacing.md })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)')
          .justifyContent(FlexAlign.Center)
        }

        // 错误提示
        if (this.errorMessage && !this.isLoading) {
          Column() {
            Image($r('app.media.icon_mute'))
              .width(40)
              .height(40)
              .objectFit(ImageFit.Contain)
            Text(this.errorMessage)
              .fontSize(FontSizes.caption)
              .fontColor(Color.White)
              .margin({ top: Spacing.md })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.7)')
          .justifyContent(FlexAlign.Center)
        }

        // ========== 优化点1①：顶部半透明渐变磨砂导航栏 ==========
        if (this.showControls) {
          Row() {
            // 返回按钮 - 磨砂圆形
            Row() {
              Image($r('app.media.icon_arrow_left'))
                .width(20)
                .height(20)
                .fillColor(Color.White)
                .onClick(() => {
                  this.onBack()
                })
            }
            .width(36)
            .height(36)
            .backgroundColor('rgba(255,255,255,0.15)')
            .backdropBlur(10)
            .borderRadius(18)
            .justifyContent(FlexAlign.Center)

            Text(this.title)
              .fontSize(FontSizes.body)
              .fontWeight(FontWeightValue.medium)
              .fontColor(Color.White)
              .margin({ left: Spacing.sm })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            // 分享按钮
            Stack() {
              Row()
                .width(36)
                .height(36)
                .backgroundColor('rgba(255,255,255,0.15)')
                .backdropBlur(10)
                .borderRadius(18)
                .scale({ x: this.shareBtnPressed ? 0.9 : 1, y: this.shareBtnPressed ? 0.9 : 1 })

              Image($r('app.media.icon_share'))
                .width(18)
                .height(18)
                .objectFit(ImageFit.Contain)
            }
            .margin({ left: Spacing.sm })
            .onClick(() => {
              this.onShare()
            })

            // 收藏按钮
            Stack() {
              Row()
                .width(36)
                .height(36)
                .backgroundColor('rgba(255,255,255,0.15)')
                .backdropBlur(10)
                .borderRadius(18)
                .scale({ x: this.favBtnPressed ? 0.9 : 1, y: this.favBtnPressed ? 0.9 : 1 })

              Image($r('app.media.icon_mute'))
                .width(18)
                .height(18)
                .objectFit(ImageFit.Contain)
            }
            .margin({ left: Spacing.sm })
            .onClick(() => {
              this.onFavorite()
            })
          }
          .width('100%')
          .height(56)
          .padding({ left: Spacing.md, right: Spacing.md })
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
          })
          .backdropBlur(15)
        }

        // ========== 优化点1②③④：底部播放控制栏 + 快捷按钮 ==========
        if (this.showControls && !this.isLoading && !this.errorMessage) {
          Column() {
            Blank()

            Column() {
              // 进度条 - 粉蓝渐变
              Row() {
                Text(this.formatTime(this.currentTime))
                  .fontSize(10)
                  .fontColor(Color.White)

                Slider({
                  value: this.currentTime,
                  min: 0,
                  max: this.duration || 100,
                  style: SliderStyle.OutSet
                })
                  .layoutWeight(1)
                  .height(24)
                  .blockColor(Color.White)
                  .trackColor('rgba(255,255,255,0.2)')
                  .selectedColor('#E8A0B0')
                  .margin({ left: Spacing.sm, right: Spacing.sm })
                  .onChange((value: number) => {
                    this.onSliderChange(value)
                  })

                Text(this.formatTime(this.duration))
                  .fontSize(10)
                  .fontColor(Color.White)
              }
              .width('100%')

              // 播放控制按钮行
              Row() {
                // 播放/暂停按钮 - 磨砂圆形，使用111.png图标
                Stack() {
                  Row()
                    .width(44)
                    .height(44)
                    .backgroundColor('rgba(255,255,255,0.2)')
                    .backdropBlur(12)
                    .borderRadius(22)
                    .scale({ x: this.playBtnPressed ? 0.92 : 1, y: this.playBtnPressed ? 0.92 : 1 })

                  // isPlaying=true 表示正在播放，此时应显示暂停图标（点击后暂停）
                  // isPlaying=false 表示已暂停，此时应显示播放图标（点击后播放）
                  Image(this.isPlaying ? $r('app.media.icon_pause') : $r('app.media.icon_play'))
                    .width(22)
                    .height(22)
                    .objectFit(ImageFit.Contain)
                }
                .onClick(() => {
                  this.onPlayPause()
                })

                Blank()

                // 快捷按钮区域 - 渐变磨砂
                Row({ space: Spacing.sm }) {
                  // 一起同步观影按钮
                  Stack() {
                    Row()
                      .width(44)
                      .height(44)
                      .linearGradient({
                        direction: GradientDirection.Right,
                        colors: [['rgba(232,160,176,0.8)', 0], ['rgba(160,200,216,0.8)', 1]]
                      })
                      .backdropBlur(12)
                      .borderRadius(22)
                      .scale({ x: this.syncBtnPressed ? 0.92 : 1, y: this.syncBtnPressed ? 0.92 : 1 })

                    Image($r('app.media.icon_people'))
                      .width(20)
                      .height(20)
                      .objectFit(ImageFit.Contain)
                  }
                  .onClick(() => {
                    this.onSyncWatch()
                  })

                  // 记观影笔记按钮
                  Stack() {
                    Row()
                      .width(44)
                      .height(44)
                      .linearGradient({
                        direction: GradientDirection.Right,
                        colors: [['rgba(160,200,216,0.8)', 0], ['rgba(232,160,176,0.8)', 1]]
                      })
                      .backdropBlur(12)
                      .borderRadius(22)
                      .scale({ x: this.noteBtnPressed ? 0.92 : 1, y: this.noteBtnPressed ? 0.92 : 1 })

                    Image($r('app.media.icon_danmu'))
                      .width(20)
                      .height(20)
                      .objectFit(ImageFit.Contain)
                  }
                  .onClick(() => {
                    this.onNote()
                  })

                  // 全屏按钮
                  Stack() {
                    Row()
                      .width(40)
                      .height(40)
                      .backgroundColor('rgba(255,255,255,0.15)')
                      .backdropBlur(10)
                      .borderRadius(20)
                      .scale({ x: this.fullscreenBtnPressed ? 0.92 : 1, y: this.fullscreenBtnPressed ? 0.92 : 1 })

                    Image($r('app.media.icon_fullscreen'))
                      .width(18)
                      .height(18)
                      .objectFit(ImageFit.Contain)
                  }
                  .onClick(() => {
                    this.toggleFullscreen()
                  })
                }
              }
              .width('100%')
              .margin({ top: Spacing.sm })
            }
            .width('100%')
            .padding({ left: Spacing.md, right: Spacing.md, bottom: Spacing.md })
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
            })
            .backdropBlur(15)
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height(this.isFullscreen ? '100%' : 280)
      .backgroundColor(Color.Black)

      // ========== 横屏全屏时隐藏下方内容 ==========
      if (!this.isFullscreen) {
        Scroll() {
          Column({ space: 24 }) {
            // ========== 优化点2：新增【分集选集】横向滚动模块 ==========
            this.EpisodeSection()

            // ========== 优化点3：影片基础信息卡片重构 ==========
            this.VideoInfoCard()

            // ========== 优化点4：剧情简介模块优化 ==========
            this.OverviewSection()

            // ========== 优化点5：横向推荐卡片区 ==========
            this.RecommendSection('相似推荐', this.similarMovies)
            this.RecommendSection('演员作品', this.actorMovies)

            // 提示
            this.TipSection()

            // 底部留白
            Blank().height(80)
          }
          .padding({ top: 24, left: 16, right: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#FFFAF5')
      }

      // ========== 优化点6：底部固定双功能悬浮栏 ==========
      if (!this.isFullscreen) {
        Row() {
          Button() {
            Row({ space: 8 }) {
              Image($r('app.media.icon_people'))
                  .width(18)
                  .height(18)
                  .objectFit(ImageFit.Contain)
                Text('同步观影')
                .fontSize(FontSizes.caption)
                .fontColor(Color.White)
            }
          }
          .layoutWeight(1)
          .height(50)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
          })
          .borderRadius(25)
          .backdropBlur(15)
          .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
          .scale({ x: this.syncBtnPressed ? 0.98 : 1, y: this.syncBtnPressed ? 0.98 : 1 })
          .animation({ duration: 150, curve: Curve.EaseOut })
          .onClick(() => {
            this.onSyncWatch()
          })

          Button() {
            Row({ space: 8 }) {
              Image($r('app.media.icon_danmu'))
                  .width(18)
                  .height(18)
                  .objectFit(ImageFit.Contain)
                Text('观影笔记')
                .fontSize(FontSizes.caption)
                .fontColor(Color.White)
            }
          }
          .layoutWeight(1)
          .height(50)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#A0C8D8', 0], ['#E8A0B0', 1]]
          })
          .borderRadius(25)
          .backdropBlur(15)
          .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
          .scale({ x: this.noteBtnPressed ? 0.98 : 1, y: this.noteBtnPressed ? 0.98 : 1 })
          .animation({ duration: 150, curve: Curve.EaseOut })
          .onClick(() => {
            this.onNote()
          })
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16, bottom: 20 })
        .backgroundColor('rgba(255,250,245,0.95)')
        .backdropBlur(20)
        .border({ width: { top: 1 }, color: 'rgba(232,160,176,0.15)' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isFullscreen ? Color.Black : '#FFFAF5')
  }

  // 物理返回键拦截（组件生命周期方法）
  onBackPress(): boolean {
    if (this.isFullscreen) {
      this.toggleFullscreen()
      return true
    }
    return false
  }

  // ========== 优化点2：分集选集横向滚动模块 ==========
  @Builder
  EpisodeSection() {
    Column() {
      Row() {
        Text('分集选集')
          .fontSize(20)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')

        Text(`${this.currentEpisode}/${this.episodes.length}`)
          .fontSize(FontSizes.caption)
          .fontColor('#A0A0A8')
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Stack() {
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.episodes, (ep: EpisodeInfo) => {
              Column() {
                Text(ep.index.toString())
                  .fontSize(FontSizes.caption)
                  .fontColor(ep.isPlaying ? Color.White : '#2D2D3A')
                  .fontWeight(ep.isPlaying ? FontWeightValue.bold : FontWeightValue.regular)

                // 已看进度条
                if (ep.isWatched) {
                  Row()
                    .width('100%')
                    .height(3)
                    .linearGradient({
                      direction: GradientDirection.Right,
                      colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
                    })
                    .borderRadius(2)
                    .margin({ top: 6 })
                }
              }
              .width(48)
              .height(52)
              .padding(12)
              .backgroundColor(ep.isPlaying ? 'rgba(0,0,0,0.01)' : 'rgba(255,255,255,0.7)')
              .backdropBlur(10)
              .borderRadius(12)
              .border({
                width: 1,
                color: ep.isPlaying ? 'rgba(232,160,176,0.5)' : 'rgba(160,200,216,0.2)'
              })
              .linearGradient(ep.isPlaying ? {
                direction: GradientDirection.Right,
                colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
              } : {
                direction: GradientDirection.Right,
                colors: [[0x10E8A0B0, 0], [0x10A0C8D8, 1]]
              })
              .onClick(() => {
                this.onEpisodeClick(ep.index)
              })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        // 左右渐变遮罩
        Column()
          .width(20)
          .height(60)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['rgba(255,250,245,0.9)', 0], ['rgba(255,250,245,0)', 1]]
          })
          .position({ x: 0, y: 0 })

        Column()
          .width(20)
          .height(60)
          .linearGradient({
            direction: GradientDirection.Left,
            colors: [['rgba(255,250,245,0.9)', 0], ['rgba(255,250,245,0)', 1]]
          })
          .position({ x: '100%', y: 0 })
          .translate({ x: -20 })
      }
      .width('100%')
      .height(60)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(232,160,176,0.12)' })
    .shadow({ radius: 10, color: 'rgba(232,160,176,0.08)', offsetX: 0, offsetY: 3 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  // ========== 优化点3：影片基础信息卡片 ==========
  @Builder
  VideoInfoCard() {
    Row() {
      // 左侧竖版海报
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.getPosterResource(this.posterUrl))
          .width(90)
          .height(130)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .backgroundColor('#E8E8F0')

        // 平台铭牌 - 粉蓝渐变
        Text('预告片')
          .fontSize(9)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
          })
          .borderRadius(8)
          .position({ x: 8, y: 8 })
      }

      // 右侧信息
      Column() {
        // 标题
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 评分和年份
        Row({ space: 10 }) {
          if (this.rating > 0) {
            Row() {
              Image($r('app.media.icon_danmu'))
                .width(12)
                .height(12)
                .objectFit(ImageFit.Contain)
              Text(this.rating.toFixed(1))
                .fontSize(FontSizes.caption)
                .fontColor(Color.White)
                .fontWeight(FontWeightValue.bold)
            }
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
            })
            .borderRadius(12)
          }

          if (this.year) {
            Text(this.year)
              .fontSize(FontSizes.caption)
              .fontColor('#A0A0A8')
          }
        }
        .margin({ top: 8 })

        // 类型标签
        Row({ space: 6 }) {
          Text('剧情')
            .fontSize(10)
            .fontColor('#E8A0B0')
            .backgroundColor('rgba(232,160,176,0.15)')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)

          Text('情感')
            .fontSize(10)
            .fontColor('#A0C8D8')
            .backgroundColor('rgba(160,200,216,0.15)')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)
        }
        .margin({ top: 8 })

        // 按钮行
        Row({ space: 12 }) {
          Button('加入追剧')
            .layoutWeight(1)
            .height(36)
            .fontSize(FontSizes.caption)
            .fontColor(Color.White)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#E8A0B0', 0], ['#A0C8D8', 1]]
            })
            .borderRadius(18)
            .backdropBlur(10)
            .scale({ x: this.addDramaPressed ? 0.96 : 1, y: this.addDramaPressed ? 0.96 : 1 })
            .animation({ duration: 150, curve: Curve.EaseOut })
            .onClick(() => {
              this.onAddDrama()
            })

          Button('跳转官网')
            .layoutWeight(1)
            .height(36)
            .fontSize(FontSizes.caption)
            .fontColor('#E8A0B0')
            .backgroundColor('rgba(255,255,255,0.6)')
            .backdropBlur(10)
            .borderRadius(18)
            .border({ width: 1, color: 'rgba(232,160,176,0.3)' })
            .scale({ x: this.openWebPressed ? 0.96 : 1, y: this.openWebPressed ? 0.96 : 1 })
            .animation({ duration: 150, curve: Curve.EaseOut })
            .onClick(() => {
              this.onOpenWeb()
            })
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .margin({ left: 16 })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(160,200,216,0.12)' })
    .shadow({ radius: 10, color: 'rgba(160,200,216,0.08)', offsetX: 0, offsetY: 3 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  // ========== 优化点4：剧情简介模块 - 折叠/展开 ==========
  @Builder
  OverviewSection() {
    Column() {
      Row() {
        Text('剧情简介')
          .fontSize(20)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')

        Blank()

        Text(this.isOverviewExpanded ? '收起' : '展开全部')
          .fontSize(FontSizes.caption)
          .fontColor('#A0A0A8')
      }
      .width('100%')
      .margin({ bottom: 12 })
      .onClick(() => {
        this.isOverviewExpanded = !this.isOverviewExpanded
      })

      Text(this.overview || '这是一部精彩的影视作品，讲述了一段感人至深的故事。')
        .fontSize(FontSizes.caption)
        .fontColor('#6B6B78')
        .lineHeight(22)
        .maxLines(this.isOverviewExpanded ? 100 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(255,240,245,0.72)')
    .backdropBlur(25)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(232,160,176,0.12)' })
    .shadow({ radius: 10, color: 'rgba(232,160,176,0.08)', offsetX: 0, offsetY: 3 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  // ========== 优化点5：横向推荐卡片区 ==========
  @Builder
  RecommendSection(title: string, movies: TMDBMedia[]) {
    Column() {
      Row() {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(movies, (movie: TMDBMedia) => {
            Column() {
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(this.getPosterResource(movie.poster_path))
                  .width(100)
                  .height(140)
                  .borderRadius(14)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor('#E8E8F0')

                // 状态铭牌
                Text(this.getRandomBadge())
                  .fontSize(9)
                  .fontColor(Color.White)
                  .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                  .linearGradient({
                    direction: GradientDirection.Right,
                    colors: [['#D8B0C0', 0], ['#B0D0E0', 1]]
                  })
                  .borderRadius(8)
                  .margin(6)
              }

              Text(getMediaTitle(movie))
                .fontSize(FontSizes.helper)
                .fontColor('#2D2D3A')
                .margin({ top: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(100)
            .onClick(() => {
              router.pushUrl({ url: 'pages/home/VideoPlayerPage', params: {
                id: movie.id,
                title: getMediaTitle(movie),
                posterPath: movie.poster_path,
                overview: movie.overview,
                rating: movie.vote_average,
                year: getMediaYear(movie),
                mediaType: movie.media_type,
                trailerUrl: movie.trailer_url
              } })
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
    .shadow({ radius: 10, color: 'rgba(160,200,216,0.08)', offsetX: 0, offsetY: 3 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x08E8A0B0, 0], [0x08A0C8D8, 1]]
    })
  }

  private getRandomBadge(): string {
    const badges: string[] = ['推荐', '热播', '上新', '高分']
    return badges[Math.floor(Math.random() * badges.length)]
  }

  // ========== 优化点7：测试片源提示弱化 ==========
  @Builder
  TipSection() {
    Column() {
      Row() {
        Image($r('app.media.icon_danmu'))
          .width(12)
          .height(12)
          .opacity(0.6)

        Text('当前为测试片源，正式版将接入真实预告片')
          .fontSize(12)
          .fontColor('#C0C0C8')
          .opacity(0.6)
          .margin({ left: 6 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8 })
  }
}

export default VideoPlayerPage