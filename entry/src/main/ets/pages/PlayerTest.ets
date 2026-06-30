import http from '@ohos.net.http'

interface TestVideo {
  name: string
  url: string
}

interface PreparedEvent {
  duration: number
}

interface UpdateEvent {
  time: number
}

interface TMDBMovie {
  title: string
  vote_average: number
  poster_path: string
  id: number
}

interface TMDBResult {
  results: Array<TMDBMovie>
}

interface ErrorInfo {
  message?: string
}

@Entry
@Component
struct PlayerTest {
  @State videoUrl: string = ''
  @State videoTitle: string = '选择测试视频'
  @State isPlaying: boolean = false
  @State currentTime: number = 0
  @State duration: number = 0
  @State tmdbData: string = ''
  @State apiStatus: string = '未开始'
  @State errorMessage: string = ''

  private videoController: VideoController = new VideoController()

  private testVideos: TestVideo[] = [
    { name: 'Big Buck Bunny (公开测试片源)', url: 'https://www.w3schools.com/html/mov_bbb.mp4' },
    { name: 'Elephant Dream (开源动画)', url: 'https://media.w3.org/2010/05/sintel/trailer.mp4' },
    { name: '本地测试', url: '' }
  ]

  private async fetchTMDBData() {
    this.apiStatus = '正在请求...'
    this.errorMessage = ''
    this.tmdbData = ''

    try {
      const httpRequest = http.createHttp()

      const apiKey = 'f8b0582660e61ee94a0ba88e46bcae7a'
      const url = `https://api.themoviedb.org/3/movie/popular?api_key=${apiKey}&language=zh-CN&page=1`

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET
      })

      if (response.responseCode === 200) {
        this.apiStatus = '✅ API 连通成功'
        const resultStr = response.result as string
        const data: TMDBResult = JSON.parse(resultStr)
        this.tmdbData = JSON.stringify(data.results.slice(0, 3), null, 2)
      } else {
        this.apiStatus = `❌ 请求失败: ${response.responseCode}`
      }

      httpRequest.destroy()
    } catch (error) {
      const err = error as Error
      this.apiStatus = '❌ 网络请求异常'
      this.errorMessage = err.message || '未知错误'
    }
  }

  private playVideo(url: string, name: string) {
    this.videoTitle = name
    this.videoUrl = url
    this.errorMessage = ''

    if (url) {
      this.videoController.start()
      this.isPlaying = true
    }
  }

  private onPrepared(event: PreparedEvent) {
    this.duration = event.duration
    this.apiStatus = '✅ 视频加载成功'
  }

  private onError() {
    this.isPlaying = false
    this.errorMessage = '视频播放失败，请检查网络或片源'
    this.apiStatus = '❌ 视频播放异常'
  }

  private onUpdate(event: UpdateEvent) {
    this.currentTime = event.time
  }

  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  private onSliderChange(value: number) {
    this.videoController.setCurrentTime(value)
    this.currentTime = value
  }

  build() {
    Column() {
      Text('🎬 播放器测试页面')
        .fontSize(28)
        .fontWeight(700)
        .margin({ top: 20, bottom: 10 })

      Text('用于验证 TMDB API 连通性和视频播放功能')
        .fontSize(14)
        .fontColor(Color.Grey)
        .margin({ bottom: 20 })

      Column() {
        Text('📡 TMDB API 测试')
          .fontSize(18)
          .fontWeight(500)
          .margin({ top: 10, bottom: 10 })

        Button('调用 TMDB API')
          .width('100%')
          .height(48)
          .backgroundColor('#FF6B6B')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.fetchTMDBData()
          })

        Text(`状态: ${this.apiStatus}`)
          .fontSize(14)
          .margin({ top: 8 })
          .fontColor(this.apiStatus.includes('✅') ? '#00C853' : '#FF5252')

        if (this.errorMessage) {
          Text(`错误: ${this.errorMessage}`)
            .fontSize(12)
            .fontColor(Color.Red)
            .margin({ top: 4 })
            .maxLines(3)
        }

        if (this.tmdbData) {
          Text('返回数据 (前3条):')
            .fontSize(14)
            .fontWeight(500)
            .margin({ top: 12 })

          Scroll() {
            Text(this.tmdbData)
              .fontSize(12)
              .fontColor('#424242')
              .fontFamily('monospace')
              .padding(10)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
          }
          .height(150)
          .margin({ top: 4 })
        }
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(16)
      .shadow({ radius: 8, color: '#00000010', offsetY: 4 })

      Column() {
        Text('🎥 视频播放测试')
          .fontSize(18)
          .fontWeight(500)
          .margin({ top: 10, bottom: 10 })

        Column() {
          ForEach(this.testVideos, (video: TestVideo) => {
            Button(video.name)
              .width('100%')
              .height(44)
              .backgroundColor(video.url ? '#4ECDC4' : '#E0E0E0')
              .fontColor(video.url ? Color.White : Color.Grey)
              .borderRadius(8)
              .margin({ bottom: 8 })
              .onClick(() => {
                this.playVideo(video.url, video.name)
              })
          })
        }

        Text(`当前视频: ${this.videoTitle}`)
          .fontSize(14)
          .margin({ top: 12 })

        if (this.videoUrl) {
          Video({
            src: this.videoUrl,
            controller: this.videoController
          })
            .width('100%')
            .height(240)
            .backgroundColor(Color.Black)
            .autoPlay(false)
            .controls(true)
            .onPrepared((event: PreparedEvent) => {
              this.onPrepared(event)
            })
            .onError(() => {
              this.onError()
            })
            .onUpdate((event: UpdateEvent) => {
              this.onUpdate(event)
            })

          Row() {
            Text(this.formatTime(this.currentTime))
              .fontSize(12)
              .fontColor(Color.Grey)

            Slider({
              value: this.currentTime,
              min: 0,
              max: this.duration || 100,
              style: SliderStyle.OutSet
            })
              .width('100%')
              .height(20)
              .blockColor('#4ECDC4')
              .trackColor('#E0E0E0')
              .selectedColor('#4ECDC4')
              .onChange((value: number) => {
                this.onSliderChange(value)
              })

            Text(this.formatTime(this.duration))
              .fontSize(12)
              .fontColor(Color.Grey)
          }
          .width('100%')
          .margin({ top: 8 })

          if (this.errorMessage) {
            Text(`❌ ${this.errorMessage}`)
              .fontSize(12)
              .fontColor(Color.Red)
              .margin({ top: 8 })
          }
        }
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(16)
      .shadow({ radius: 8, color: '#00000010', offsetY: 4 })
      .margin({ top: 20 })

      Text('💡 说明: 测试片源来自公开CDN，仅供开发测试使用')
        .fontSize(12)
        .fontColor(Color.Grey)
        .margin({ top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5')
    .padding({ left: 16, right: 16 })
  }
}