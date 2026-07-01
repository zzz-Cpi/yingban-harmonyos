import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockAllMedia, mockCategories, Category } from '../../model/MockData'
import { TMDBMedia, getMediaTitle, getMediaYear } from '../../model/TMDBTypes'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'LibraryPage'

interface RouteParams {
  categoryId?: number
}

@Entry
@Component
struct LibraryPage {
  @State private currentCategoryId: number = 0
  @State private filteredList: TMDBMedia[] = []

  aboutToAppear(): void {
    const params = router.getParams() as RouteParams
    if (params && params.categoryId !== undefined) {
      this.currentCategoryId = params.categoryId
    }
    this.filterByCategory(this.currentCategoryId)
  }

  private filterByCategory(categoryId: number): void {
    this.currentCategoryId = categoryId
    if (categoryId === 0) {
      this.filteredList = mockAllMedia
      return
    }
    const result: TMDBMedia[] = []
    for (let i = 0; i < mockAllMedia.length; i++) {
      const item = mockAllMedia[i]
      if (item.genre_ids.indexOf(categoryId) >= 0) {
        result.push(item)
      }
    }
    this.filteredList = result
  }

  private onBack(): void {
    try {
      router.back()
    } catch (err) {
      hilog.error(0, TAG, 'Back failed')
    }
  }

  private onSearch(): void {
    try {
      router.pushUrl({ url: 'pages/home/SearchPage' })
    } catch (err) {
      hilog.error(0, TAG, 'Navigate to search failed')
    }
  }

  private navigateToPlayer(media: TMDBMedia): void {
    try {
      let videoUrl: string | Resource = ''
      if (media.trailer_url !== undefined && media.trailer_url !== null) {
        videoUrl = media.trailer_url
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
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor(Colors.textPrimary)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onBack())

        Text('影片库')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .margin({ left: Spacing.md })

        Blank()

        Text('🔍')
          .fontSize(20)
          .onClick(() => this.onSearch())
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      // 分类Tab
      Scroll() {
        Row({ space: Spacing.md }) {
          Column() {
            Text('全部')
              .fontSize(FontSizes.body)
              .fontColor(this.currentCategoryId === 0 ? Colors.primary : Colors.textSecondary)
              .fontWeight(this.currentCategoryId === 0 ? FontWeightValue.semibold : FontWeightValue.medium)
            if (this.currentCategoryId === 0) {
              Divider()
                .color(Colors.primary)
                .height(2)
                .width(20)
                .margin({ top: 4 })
                .borderRadius(1)
            }
          }
          .height(36)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.filterByCategory(0))

          ForEach(mockCategories, (cat: Category) => {
            Column() {
              Row() {
                Text(cat.icon)
                  .fontSize(14)
                  .margin({ right: 4 })
                Text(cat.name)
                  .fontSize(FontSizes.body)
                  .fontColor(this.currentCategoryId === cat.id ? Colors.primary : Colors.textSecondary)
                  .fontWeight(this.currentCategoryId === cat.id ? FontWeightValue.semibold : FontWeightValue.medium)
              }
              if (this.currentCategoryId === cat.id) {
                Divider()
                  .color(Colors.primary)
                  .height(2)
                  .width(20)
                  .margin({ top: 4 })
                  .borderRadius(1)
              }
            }
            .height(36)
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.filterByCategory(cat.id))
          }, (cat: Category) => cat.id.toString())
        }
        .padding({ left: Spacing.lg, right: Spacing.lg })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .backgroundColor(Color.White)
      .padding({ bottom: Spacing.sm })

      // 结果数量
      Text(`共 ${this.filteredList.length} 部`)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textTertiary)
        .width('100%')
        .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.sm })

      // 影片网格
      Scroll() {
        Grid() {
          ForEach(this.filteredList, (item: TMDBMedia) => {
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
      .layoutWeight(1)
      .padding({ left: Spacing.lg, right: Spacing.lg, bottom: Spacing.lg })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
