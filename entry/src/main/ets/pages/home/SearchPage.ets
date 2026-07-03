import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockAllMedia } from '../../model/MockData'
import { TMDBMedia, getMediaTitle, getMediaYear, getTestVideoUrl } from '../../model/TMDBTypes'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'SearchPage'

@Entry
@Component
struct SearchPage {
  @State private searchText: string = ''
  @State private searchResults: TMDBMedia[] = []
  @State private hasSearched: boolean = false
  private allMedia: TMDBMedia[] = []
  private hotKeywords: string[] = ['繁花', '庆余年', '飞驰人生', '漫长的季节', '我的阿勒泰', '热辣滚烫', '墨雨云间', '度华年']

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
          overview: media.overview
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
        // 初始状态 - 热门搜索
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

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }
}


