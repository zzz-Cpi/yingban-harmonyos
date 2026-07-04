import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { aiService, AIMessage } from '../../utils/AIService'
import { TMDBMedia, getMediaTitle, getMediaYear, getTestVideoUrl } from '../../model/TMDBTypes'

@Entry
@Component
struct AIChatPage {
  @State messages: AIMessage[] = []
  @State inputText: string = ''
  @State isTyping: boolean = false
  private scroller: Scroller = new Scroller()

  private quickQuestions: string[] = [
    '推荐点好看的剧',
    '古装权谋推荐',
    '有什么悬疑片',
    '高分经典有哪些'
  ]

  aboutToAppear(): void {
    this.messages.push(aiService.getWelcomeMessage())
  }

  private sendMessage(text: string): void {
    if (!text.trim()) return

    this.messages.push({
      id: Date.now(),
      role: 'user',
      content: text.trim(),
      timestamp: Date.now(),
      type: 'text'
    })

    this.inputText = ''
    this.isTyping = true
    this.scrollToBottom()

    // 异步调用AI服务（支持通义千问API + 本地降级）
    aiService.generateReply(text.trim()).then((reply: AIMessage) => {
      this.messages.push(reply)
      this.isTyping = false
      this.scrollToBottom()
    }).catch(() => {
      this.messages.push({
        id: Date.now(),
        role: 'ai',
        content: '小艺开小差了，请稍后再试～ 🤖',
        timestamp: Date.now(),
        type: 'text'
      })
      this.isTyping = false
      this.scrollToBottom()
    })
  }

  private scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 50)
  }

  private getPosterResource(name: string): Resource | string {
    if (name.startsWith('http')) return name
    const resMap: Record<string, Resource> = {
      'poster_fanhua': $r('app.media.poster_fanhua'),
      'poster_qingyunian': $r('app.media.poster_qingyunian'),
      'poster_aletai': $r('app.media.poster_aletai'),
      'poster_feichi': $r('app.media.poster_feichi'),
      'poster_bushanliang': $r('app.media.poster_bushanliang'),
      'poster_manchangdeji': $r('app.media.poster_manchangdeji'),
      'poster_waipodexinshijie': $r('app.media.poster_waipodexinshijie'),
      'poster_taochubaihuyuan': $r('app.media.poster_taochubaihuyuan'),
      'poster_moyuyunjian': $r('app.media.poster_moyuyunjian'),
      'poster_duhuanian': $r('app.media.poster_duhuanian'),
      'poster_relaguangtang': $r('app.media.poster_relaguangtang'),
      'poster_diershitiao': $r('app.media.poster_diershitiao'),
      'poster_dahongbao': $r('app.media.poster_dahongbao'),
      'poster_saohei': $r('app.media.poster_saohei'),
      'poster_kuangbiao': $r('app.media.poster_kuangbiao'),
      'poster_langyabang': $r('app.media.poster_langyabang'),
      'poster_yanxinji': $r('app.media.poster_yanxinji')
    }
    return resMap[name] || $r('app.media.poster_fanhua')
  }

  private navigateToPlayer(media: TMDBMedia): void {
    router.pushUrl({
      url: 'pages/home/VideoPlayerPage',
      params: {
        videoUrl: getTestVideoUrl(media.id),
        title: getMediaTitle(media),
        posterUrl: media.poster_path,
        rating: media.vote_average,
        year: getMediaYear(media),
        overview: media.overview,
        mediaType: media.media_type,
        episodeCount: media.episode_count
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor(Colors.textPrimary)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .onClick(() => router.back())

        Row({ space: 8 }) {
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(36)
              .height(36)
              .borderRadius(18)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [[Colors.primary, 0], [Colors.secondary, 1]]
              })
            Text('艺')
              .fontSize(16)
              .fontWeight(FontWeightValue.bold)
              .fontColor(Color.White)
          }
          Column() {
            Text('小艺AI')
              .fontSize(FontSizes.sectionTitle)
              .fontWeight(FontWeightValue.bold)
              .fontColor(Colors.textPrimary)
            Text('你的追剧小助手')
              .fontSize(10)
              .fontColor(Colors.textTertiary)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .margin({ left: Spacing.md })

        Blank()
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      Scroll(this.scroller) {
        Column({ space: Spacing.lg }) {
          ForEach(this.messages, (msg: AIMessage) => {
            if (msg.role === 'user') {
              this.UserBubble(msg)
            } else {
              this.AIBubble(msg)
            }
          }, (msg: AIMessage) => msg.id.toString())

          if (this.isTyping) {
            this.TypingIndicator()
          }

          if (this.messages.length <= 1) {
            this.QuickQuestions()
          }
        }
        .width('100%')
        .padding(Spacing.lg)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.background)

      Row() {
        TextInput({ placeholder: '和小艺聊聊追剧吧...', text: this.inputText })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FFF0F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .fontSize(FontSizes.body)
          .placeholderColor(Colors.textTertiary)
          .onChange((value: string) => {
            this.inputText = value
          })
          .onSubmit(() => {
            this.sendMessage(this.inputText)
          })

        Text('发送')
          .fontSize(FontSizes.body)
          .fontColor(Color.White)
          .backgroundColor(this.inputText.trim() ? Colors.primary : '#D9D9D9')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin({ left: Spacing.sm })
          .onClick(() => {
            if (this.inputText.trim()) {
              this.sendMessage(this.inputText)
            }
          })
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.sm, bottom: Spacing.lg })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  UserBubble(msg: AIMessage) {
    Row() {
      Blank()
      Column() {
        Text(msg.content)
          .fontSize(FontSizes.body)
          .fontColor(Color.White)
          .maxLines(10)
      }
      .backgroundColor(Colors.primary)
      .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 })
      .padding(12)
      .width('75%')
    }
    .width('100%')
  }

  @Builder
  AIBubble(msg: AIMessage) {
    Row({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(36)
          .height(36)
          .borderRadius(18)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[Colors.primary, 0], [Colors.secondary, 1]]
          })
        Text('艺')
          .fontSize(14)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Color.White)
      }

      Column({ space: Spacing.sm }) {
        Column() {
          Text(msg.content)
            .fontSize(FontSizes.body)
            .fontColor(Colors.textPrimary)
            .maxLines(20)
        }
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
        .padding(12)
        .width('80%')

        if (msg.type === 'recommend' && msg.recommendList && msg.recommendList.length > 0) {
          Column({ space: Spacing.sm }) {
            ForEach(msg.recommendList.slice(0, 3), (item: TMDBMedia) => {
              this.RecommendCard(item)
            }, (item: TMDBMedia) => item.id.toString())
          }
          .width('80%')
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  RecommendCard(item: TMDBMedia) {
    Row() {
      Image(this.getPosterResource(item.poster_path))
        .width(50)
        .height(70)
        .borderRadius(BorderRadius.small)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(getMediaTitle(item))
          .fontSize(FontSizes.caption)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(getMediaYear(item))
          .fontSize(10)
          .fontColor(Colors.textTertiary)
          .margin({ top: 2 })

        Row() {
          Text('⭐')
            .fontSize(10)
          Text(item.vote_average.toFixed(1))
            .fontSize(10)
            .fontColor(Colors.accent)
            .fontWeight(FontWeightValue.semibold)
        }
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Spacing.sm })

      Text('去看看')
        .fontSize(10)
        .fontColor(Colors.primary)
        .backgroundColor('#FFF0F0')
        .borderRadius(BorderRadius.small)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    }
    .width('100%')
    .padding(Spacing.sm)
    .backgroundColor('#FFF8FA')
    .borderRadius(BorderRadius.small)
    .onClick(() => this.navigateToPlayer(item))
  }

  @Builder
  TypingIndicator() {
    Row({ space: 8 }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(36)
          .height(36)
          .borderRadius(18)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[Colors.primary, 0], [Colors.secondary, 1]]
          })
        Text('艺')
          .fontSize(14)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Color.White)
      }

      Row({ space: 4 }) {
        Row().width(8).height(8).borderRadius(4).backgroundColor('#F992A5')
        Row().width(8).height(8).borderRadius(4).backgroundColor('#A0C8D8')
        Row().width(8).height(8).borderRadius(4).backgroundColor('#F992A5')
      }
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })

      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  QuickQuestions() {
    Column({ space: Spacing.sm }) {
      Text('💡 试试问我这些')
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textTertiary)
        .width('100%')
        .margin({ bottom: 4 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.quickQuestions, (q: string) => {
          Text(q)
            .fontSize(FontSizes.caption)
            .fontColor(Colors.primary)
            .backgroundColor('#FFF0F0')
            .borderRadius(BorderRadius.small)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .margin({ right: Spacing.sm, bottom: Spacing.sm })
            .onClick(() => {
              this.sendMessage(q)
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ top: Spacing.lg })
  }
}