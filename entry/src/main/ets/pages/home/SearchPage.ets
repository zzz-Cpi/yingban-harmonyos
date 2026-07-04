import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockAllMedia } from '../../model/MockData'
import { TMDBMedia, getMediaTitle, getMediaYear, getTestVideoUrl } from '../../model/TMDBTypes'
import { aiService, AIMessage } from '../../utils/AIService'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'SearchPage'

@Entry
@Component
struct SearchPage {
  @State private searchText: string = ''
  @State private searchResults: TMDBMedia[] = []
  @State private hasSearched: boolean = false
  @State private isAIExpanded: boolean = false
  @State private panelHeight: number = 0
  @State private aiMessages: AIMessage[] = []
  @State private aiInputText: string = ''
  @State private aiIsTyping: boolean = false
  private aiScroller: Scroller = new Scroller()
  private allMedia: TMDBMedia[] = []
  private hotKeywords: string[] = ['繁花', '庆余年', '飞驰人生', '漫长的季节', '我的阿勒泰', '热辣滚烫', '墨雨云间', '度华年']
  private quickQuestions: string[] = [
    '推荐点好看的剧',
    '古装权谋推荐',
    '有什么悬疑片',
    '高分经典有哪些'
  ]

  aboutToAppear(): void {
    this.loadAllMedia()
  }

  private loadAllMedia(): void {
    this.allMedia = mockAllMedia
  }

  private doSearch(): void {
    if (!this.searchText.trim()) {
      this.searchResults = []
      this.hasSearched = false
      return
    }

    const keyword = this.searchText.trim().toLowerCase()
    const results: TMDBMedia[] = []

    for (let i = 0; i < this.allMedia.length; i++) {
      const item = this.allMedia[i]
      const title = getMediaTitle(item).toLowerCase()
      if (title.includes(keyword)) {
        results.push(item)
      }
    }

    this.searchResults = results
    this.hasSearched = true
    hilog.info(0, TAG, `Search "${keyword}": ${results.length} results`)
  }

  private sendAIMessage(text: string): void {
    if (!text.trim()) return

    this.aiMessages.push({
      id: Date.now(),
      role: 'user',
      content: text.trim(),
      timestamp: Date.now(),
      type: 'text'
    })

    this.aiInputText = ''
    this.aiIsTyping = true
    this.scrollAIBottom()

    aiService.generateReply(text.trim()).then((reply: AIMessage) => {
      this.aiMessages.push(reply)
      this.aiIsTyping = false
      this.scrollAIBottom()
    }).catch(() => {
      this.aiMessages.push({
        id: Date.now(),
        role: 'ai',
        content: '小艺开小差了，请稍后再试～ 🤖',
        timestamp: Date.now(),
        type: 'text'
      })
      this.aiIsTyping = false
      this.scrollAIBottom()
    })
  }

  private scrollAIBottom(): void {
    setTimeout(() => {
      this.aiScroller.scrollEdge(Edge.Bottom)
    }, 50)
  }

  private getAIPosterResource(name: string): Resource | string {
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

  private navigateToAIPlayer(media: TMDBMedia): void {
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

  private onBack(): void {
    try {
      router.back()
    } catch (err) {
      hilog.error(0, TAG, 'Back failed')
    }
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
    } catch (err) {
      hilog.error(0, TAG, 'Navigate failed')
    }
  }

  private getPosterResource(name: string): Resource | string {
    if (name.startsWith('http')) {
      return name
    }
    const resMap: Record<string, Resource> = {
      'poster_fanhua': $r('app.media.poster_fanhua'),
      'poster_qingyunian': $r('app.media.poster_qingyunian'),
      'poster_aletai': $r('app.media.poster_aletai'),
      'poster_feichi': $r('app.media.poster_feichi'),
      'poster_zhongdiba': $r('app.media.poster_zhongdiba'),
      'poster_bushanliang': $r('app.media.poster_bushanliang'),
      'poster_manchangdeji': $r('app.media.poster_manchangdeji'),
      'poster_waipodexinshijie': $r('app.media.poster_waipodexinshijie'),
      'poster_taochubaihuyuan': $r('app.media.poster_taochubaihuyuan'),
      'poster_meiguidagushi': $r('app.media.poster_meiguidagushi'),
      'poster_jinyongwuxia': $r('app.media.poster_jinyongwuxia'),
      'poster_moyuyunjian': $r('app.media.poster_moyuyunjian'),
      'poster_duhuanian': $r('app.media.poster_duhuanian'),
      'poster_relaguangtang': $r('app.media.poster_relaguangtang'),
      'poster_diershitiao': $r('app.media.poster_diershitiao'),
      'poster_womenyiqi': $r('app.media.poster_womenyiqi'),
      'poster_xiongchumo': $r('app.media.poster_xiongchumo'),
      'poster_hongtanxiansheng': $r('app.media.poster_hongtanxiansheng'),
      'poster_dahongbao': $r('app.media.poster_dahongbao'),
      'poster_saohei': $r('app.media.poster_saohei'),
      'poster_kuangbiao': $r('app.media.poster_kuangbiao'),
      'poster_langyabang': $r('app.media.poster_langyabang'),
      'poster_yanxinji': $r('app.media.poster_yanxinji')
    }
    return resMap[name] || $r('app.media.poster_fanhua')
  }

  @Builder
  AIFloatingBall() {
    Stack() {
      if (this.isAIExpanded) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(() => {
            this.isAIExpanded = false
          })
      }

      if (!this.isAIExpanded) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(60)
            .height(60)
            .borderRadius(30)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [[Colors.primary, 0], [Colors.secondary, 1]]
            })
            .shadow({ radius: 12, color: 'rgba(249,146,165,0.4)', offsetX: 0, offsetY: 6 })
          Text('艺')
            .fontSize(24)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Color.White)
        }
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          this.isAIExpanded = true
        })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
      }

      if (this.isAIExpanded) {
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(40)
              .height(6)
              .backgroundColor('#E5E5EA')
              .borderRadius(3)
              .margin({ top: 8 })
          }

          Row() {
            Stack({ alignContent: Alignment.Center }) {
              Row()
                .width(44)
                .height(44)
                .borderRadius(22)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [[Colors.primary, 0], [Colors.secondary, 1]]
                })
                .shadow({ radius: 6, color: 'rgba(249,146,165,0.3)', offsetX: 0, offsetY: 2 })
              Text('艺')
                .fontSize(18)
                .fontWeight(FontWeightValue.bold)
                .fontColor(Color.White)
            }

            Column() {
              Row() {
                Text('小艺AI')
                  .fontSize(16)
                  .fontWeight(FontWeightValue.bold)
                  .fontColor(Colors.textPrimary)
                Text('你的追剧小助手')
                  .fontSize(10)
                  .fontColor(Colors.textTertiary)
                  .backgroundColor('#FFF0F0')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .margin({ left: 6 })
              }
              Text('随时为你推荐好剧～')
                .fontSize(12)
                .fontColor(Colors.textSecondary)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: Spacing.md })

            Text('×')
              .fontSize(22)
              .fontColor(Colors.textTertiary)
              .onClick(() => {
                this.isAIExpanded = false
              })
          }
          .width('100%')
          .padding({ left: Spacing.md, right: Spacing.md, top: 10, bottom: Spacing.sm })

          Divider().color('#F0F0F0')

          Scroll(this.aiScroller) {
            Column({ space: Spacing.md }) {
              if (this.aiMessages.length === 0) {
                Column() {
                  Text('👋 嗨，我是小艺')
                    .fontSize(14)
                    .fontColor(Colors.textPrimary)
                    .fontWeight(FontWeight.Medium)
                  Text('有什么想看的，直接问我吧～')
                    .fontSize(12)
                    .fontColor(Colors.textSecondary)
                    .margin({ top: 4 })

                  Text('💡 试试问我这些')
                    .fontSize(12)
                    .fontColor(Colors.textTertiary)
                    .width('100%')
                    .margin({ top: 16 })

                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                    ForEach(this.quickQuestions, (q: string) => {
                      Text(q)
                        .fontSize(12)
                        .fontColor(Colors.primary)
                        .backgroundColor('#FFF0F0')
                        .borderRadius(BorderRadius.small)
                        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                        .margin({ right: Spacing.sm, bottom: Spacing.sm })
                        .onClick(() => {
                          this.sendAIMessage(q)
                        })
                    })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .width('100%')
                .padding(Spacing.md)
                .alignItems(HorizontalAlign.Start)
              }

              ForEach(this.aiMessages, (msg: AIMessage) => {
                if (msg.role === 'user') {
                  Row() {
                    Blank()
                    Text(msg.content)
                      .fontSize(14)
                      .fontColor(Color.White)
                      .backgroundColor(Colors.primary)
                      .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 })
                      .padding(12)
                      .maxLines(10)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                } else {
                  Row() {
                    Stack({ alignContent: Alignment.Center }) {
                      Circle()
                        .width(32)
                        .height(32)
                        .linearGradient({
                          direction: GradientDirection.Right,
                          colors: [[Colors.primary, 0], [Colors.secondary, 1]]
                        })
                      Text('艺')
                        .fontSize(14)
                        .fontWeight(FontWeightValue.bold)
                        .fontColor(Color.White)
                    }

                    Column({ space: 8 }) {
                      if (msg.type === 'text') {
                        Text(msg.content)
                          .fontSize(14)
                          .fontColor(Colors.textPrimary)
                          .backgroundColor('#F5F5F5')
                          .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
                          .padding(12)
                      } else if (msg.type === 'recommend' && msg.recommendList) {
                        Column() {
                          Text(msg.content)
                            .fontSize(14)
                            .fontColor(Colors.textPrimary)
                            .width('100%')
                            .margin({ bottom: 8 })

                          ForEach(msg.recommendList, (item: TMDBMedia) => {
                            Stack() {
                              Row() {
                                Image(this.getAIPosterResource(item.poster_path))
                                  .width(70)
                                  .height(94)
                                  .borderRadius(8)
                                  .objectFit(ImageFit.Cover)
                                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })

                                Column() {
                                  Text(getMediaTitle(item))
                                    .fontSize(14)
                                    .fontColor(Colors.textPrimary)
                                    .fontWeight(FontWeight.Medium)
                                    .maxLines(1)
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                                  Row() {
                                    Text('⭐ ' + item.vote_average.toFixed(1))
                                      .fontSize(12)
                                      .fontColor('#FF9800')
                                    Text(' · ' + getMediaYear(item))
                                      .fontSize(12)
                                      .fontColor(Colors.textTertiary)
                                  }
                                  .margin({ top: 3 })

                                  Text(item.overview)
                                    .fontSize(11)
                                    .fontColor(Colors.textSecondary)
                                    .maxLines(2)
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    .margin({ top: 3 })
                                }
                                .layoutWeight(1)
                                .alignItems(HorizontalAlign.Start)
                                .margin({ left: 12 })
                              }
                              .width('100%')
                              .padding(10)

                              Row() {
                                Column()
                                  .width(36)
                                  .height(36)
                                  .borderRadius(18)
                                  .backgroundColor(Color.White)
                                  .shadow({ radius: 6, color: 'rgba(249,146,165,0.4)', offsetX: 0, offsetY: 2 })
                                Text('▶')
                                  .fontSize(16)
                                  .fontColor(Colors.primary)
                                  .fontWeight(FontWeightValue.bold)
                              }
                              .alignSelf(ItemAlign.End)
                              .margin({ right: 10 })
                            }
                            .width('100%')
                            .backgroundColor('#FAFAFA')
                            .borderRadius(12)
                            .margin({ bottom: 8 })
                            .onClick(() => {
                              this.navigateToAIPlayer(item)
                            })
                            .scale({ x: 1, y: 1 })
                            .animation({
                              duration: 150,
                              curve: Curve.EaseOut
                            })
                            .onTouch((event: TouchEvent) => {
                              if (event.type === TouchType.Down) {
                                (event as any).target.scale({ x: 0.98, y: 0.98 })
                              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                                (event as any).target.scale({ x: 1, y: 1 })
                              }
                            })
                          })

                          Text('点击卡片即可播放')
                            .fontSize(11)
                            .fontColor(Colors.textTertiary)
                            .width('100%')
                            .textAlign(TextAlign.Center)
                            .margin({ top: 4 })
                        }
                        .width('100%')
                        .backgroundColor('#F5F5F5')
                        .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
                        .padding(12)
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 8 })
                  }
                  .width('100%')
                }
              })

              if (this.aiIsTyping) {
                Row() {
                  Stack({ alignContent: Alignment.Center }) {
                    Circle()
                      .width(32)
                      .height(32)
                      .linearGradient({
                        direction: GradientDirection.Right,
                        colors: [[Colors.primary, 0], [Colors.secondary, 1]]
                      })
                    Text('艺')
                      .fontSize(14)
                      .fontWeight(FontWeightValue.bold)
                      .fontColor(Color.White)
                  }

                  Row() {
                    LoadingProgress()
                      .width(16)
                      .height(16)
                      .color(Colors.primary)
                    Text('正在思考中...')
                      .fontSize(12)
                      .fontColor(Colors.textTertiary)
                      .margin({ left: 8 })
                  }
                  .backgroundColor('#F5F5F5')
                  .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .margin({ left: 8 })
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.md })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)

          Divider().color('#F0F0F0')

          Row() {
            TextInput({ placeholder: '和小艺聊聊追剧吧...', text: this.aiInputText })
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(20)
              .padding({ left: 16, right: 16 })
              .fontSize(14)
              .placeholderColor(Colors.textTertiary)
              .onChange((value: string) => {
                this.aiInputText = value
              })
              .onSubmit(() => {
                this.sendAIMessage(this.aiInputText)
              })

            Text('发送')
              .fontSize(14)
              .fontColor(this.aiInputText.trim() ? Color.White : '#CCCCCC')
              .backgroundColor(this.aiInputText.trim() ? Colors.primary : '#E5E5E5')
              .borderRadius(20)
              .padding({ left: 18, right: 18, top: 9, bottom: 9 })
              .margin({ left: Spacing.sm })
              .onClick(() => {
                if (this.aiInputText.trim()) {
                  this.sendAIMessage(this.aiInputText)
                }
              })
          }
          .width('100%')
          .padding({ left: Spacing.md, right: Spacing.md, top: 10, bottom: 16 })
        }
        .width('100%')
        .height('75%')
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: BorderRadius.large, topRight: BorderRadius.large })
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: -8 })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
        .alignSelf(ItemAlign.End)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .alignContent(Alignment.Bottom)
    .padding({ bottom: 20, right: Spacing.lg })
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor(Colors.textPrimary)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onBack())

        // 搜索输入框
        Row() {
          Text('🔍')
            .fontSize(14)
            .margin({ right: 8 })

          TextInput({ placeholder: '搜索电影/剧集', text: this.searchText })
            .height(36)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .fontSize(FontSizes.body)
            .placeholderColor(Colors.textTertiary)
            .onChange((value: string) => {
              this.searchText = value
              this.doSearch()
            })
            .onSubmit(() => this.doSearch())
        }
        .layoutWeight(1)
        .height(40)
        .backgroundColor(Colors.cardBackground)
        .borderRadius(BorderRadius.medium)
        .padding({ left: 12, right: 12 })
        .margin({ left: Spacing.md })

        if (this.searchText) {
          Text('取消')
            .fontSize(FontSizes.body)
            .fontColor(Colors.primary)
            .margin({ left: Spacing.md })
            .onClick(() => {
              this.searchText = ''
              this.searchResults = []
              this.hasSearched = false
            })
        }
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: 12, bottom: 12 })
      .backgroundColor(Colors.background)

      // 搜索结果
      if (!this.hasSearched) {
        Column() {
          Text('🔥 热门搜索')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Colors.textPrimary)
            .width('100%')
            .margin({ bottom: Spacing.md })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.hotKeywords, (keyword: string) => {
              Text(keyword)
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
                .backgroundColor('#FFF0F0')
                .borderRadius(BorderRadius.small)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .margin({ right: Spacing.sm, bottom: Spacing.sm })
                .onClick(() => {
                  this.searchText = keyword
                  this.doSearch()
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(Spacing.lg)

        this.AIFloatingBall()
      } else if (this.searchResults.length === 0) {
        // 无结果
        Column() {
          Text('😢')
            .fontSize(48)
            .margin({ bottom: Spacing.md })

          Text('没有找到相关内容')
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)

          Text('换个关键词试试吧')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textTertiary)
            .margin({ top: Spacing.sm })
        }
        .width('100%')
        .margin({ top: 80 })
      } else {
        // 搜索结果列表
        Column() {
          Text(`找到 ${this.searchResults.length} 个结果`)
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textTertiary)
            .width('100%')
            .margin({ bottom: Spacing.md })

          Grid() {
            ForEach(this.searchResults, (item: TMDBMedia) => {
              GridItem() {
                Column() {
                  Stack({ alignContent: Alignment.BottomStart }) {
                    Image(this.getPosterResource(item.poster_path))
                      .width('100%')
                      .aspectRatio(2 / 3)
                      .borderRadius(BorderRadius.small)
                      .objectFit(ImageFit.Cover)

                    Row() {
                      Text('⭐')
                        .fontSize(10)
                      Text(item.vote_average.toFixed(1))
                        .fontSize(10)
                        .fontColor(Color.White)
                        .fontWeight(FontWeightValue.semibold)
                    }
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('rgba(0,0,0,0.6)')
                    .borderRadius({ bottomLeft: BorderRadius.small, topRight: BorderRadius.small })
                  }
                  .width('100%')
                  .aspectRatio(2 / 3)

                  Text(getMediaTitle(item))
                    .fontSize(FontSizes.caption)
                    .fontColor(Colors.textPrimary)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 6 })

                  Text(getMediaYear(item))
                    .fontSize(11)
                    .fontColor(Colors.textTertiary)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                    .margin({ top: 2 })
                }
                .width('100%')
                .onClick(() => this.navigateToPlayer(item))
              }
            }, (item: TMDBMedia) => item.id.toString())
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(Spacing.md)
          .rowsGap(Spacing.md)
          .width('100%')
        }
        .width('100%')
        .padding(Spacing.lg)
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }
}


