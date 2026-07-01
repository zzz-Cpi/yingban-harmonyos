import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../utils/Constants'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'

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
  private videoController: VideoController = new VideoController()

  aboutToAppear(): void {
    this.initPage()
  }

  aboutToDisappear(): void {
    try {
      this.videoController.stop()
    } catch (e) {
      hilog.warn(0, TAG, 'Stop video failed')
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

  private onBack(): void {
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
      this.TopBar()

      // 视频播放区
      Stack({ alignContent: Alignment.Center }) {
        Video({
          src: this.videoUrl,
          controller: this.videoController
        })
          .width('100%')
          .height('100%')
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

        // 加载中
        if (this.isLoading) {
          Column() {
            Text('⏳')
              .fontSize(36)
            Text('加载中...')
              .fontSize(FontSizes.caption)
              .fontColor(Color.White)
              .margin({ top: Spacing.sm })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .justifyContent(FlexAlign.Center)
        }

        // 错误提示
        if (this.errorMessage && !this.isLoading) {
          Column() {
            Text('😢')
              .fontSize(36)
            Text(this.errorMessage)
              .fontSize(FontSizes.caption)
              .fontColor(Color.White)
              .margin({ top: Spacing.sm })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.7)')
          .justifyContent(FlexAlign.Center)
        }

        // 播放控制遮罩
        if (!this.isLoading && !this.errorMessage) {
          this.PlayControls()
        }
      }
      .width('100%')
      .height(240)
      .backgroundColor(Color.Black)

      // 影片信息区
      Scroll() {
        Column() {
          // 标题和评分
          this.VideoHeader()

          // 简介
          if (this.overview) {
            this.OverviewSection()
          }

          // 提示
          this.TipSection()
        }
        .padding(Spacing.lg)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  @Builder
  TopBar() {
    Row() {
      // 返回按钮
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor(Color.White)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.onBack()
      })

      Text(this.title)
        .fontSize(FontSizes.body)
        .fontWeight(FontWeightValue.medium)
        .fontColor(Color.White)
        .margin({ left: Spacing.sm })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      // 占位，保持标题居中
      Row()
        .width(40)
    }
    .width('100%')
    .height(48)
    .padding({ left: Spacing.sm, right: Spacing.sm })
    .backgroundColor('rgba(0,0,0,0.8)')
  }

  @Builder
  PlayControls() {
    Column() {
      Blank()

      // 底部控制栏
      Column() {
        // 进度条
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
            .height(20)
            .blockColor(Colors.primary)
            .trackColor('rgba(255,255,255,0.3)')
            .selectedColor(Colors.primary)
            .margin({ left: Spacing.sm, right: Spacing.sm })
            .onChange((value: number) => {
              this.onSliderChange(value)
            })

          Text(this.formatTime(this.duration))
            .fontSize(10)
            .fontColor(Color.White)
        }
        .width('100%')

        // 播放按钮行
        Row() {
          // 播放/暂停按钮
          Row() {
            Text(this.isPlaying ? '⏸' : '▶')
              .fontSize(28)
              .fontColor(Color.White)
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.onPlayPause()
          })

          Blank()

          // 全屏按钮
          Row() {
            Text('⛶')
              .fontSize(20)
              .fontColor(Color.White)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .margin({ top: Spacing.sm })
      }
      .width('100%')
      .padding({ left: Spacing.md, right: Spacing.md, bottom: Spacing.md })
      .backgroundColor('rgba(0,0,0,0.6)')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  VideoHeader() {
    Row() {
      // 海报缩略图
      Image(this.getPosterResource(this.posterUrl))
        .width(80)
        .height(110)
        .borderRadius(BorderRadius.small)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#E0E0E0')

      Column() {
        Text(this.title)
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: Spacing.sm }) {
          if (this.rating > 0) {
            Row() {
              Text('⭐ ')
                .fontSize(12)
              Text(this.rating.toFixed(1))
                .fontSize(FontSizes.caption)
                .fontColor('#FF9500')
                .fontWeight(FontWeightValue.bold)
            }
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#FFF5E6')
            .borderRadius(BorderRadius.small)
          }

          if (this.year) {
            Text(this.year)
              .fontSize(FontSizes.caption)
              .fontColor(Colors.textSecondary)
          }
        }
        .margin({ top: Spacing.sm })

        Text('预告片')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.primary)
          .margin({ top: Spacing.sm })
      }
      .margin({ left: Spacing.md })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .padding(Spacing.md)
  }

  @Builder
  OverviewSection() {
    Column() {
      Text('剧情简介')
        .fontSize(FontSizes.body)
        .fontWeight(FontWeightValue.semibold)
        .fontColor(Colors.textPrimary)
        .margin({ bottom: Spacing.sm })

      Text(this.overview)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textSecondary)
        .lineHeight(20)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .padding(Spacing.md)
    .margin({ top: Spacing.md })
  }

  @Builder
  TipSection() {
    Column() {
      Row() {
        Text('💡')
          .fontSize(16)

        Text('当前为测试片源，正式版将接入真实预告片')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
          .margin({ left: Spacing.sm })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(Spacing.md)
    .margin({ top: Spacing.xl })
  }
}

export default VideoPlayerPage
