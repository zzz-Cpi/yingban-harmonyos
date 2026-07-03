import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'

interface FavoriteItem {
  id: number
  title: string
  poster: Resource
  totalEpisodes: number
  currentEpisode: number
  addedDays: number
}

const favoriteList: FavoriteItem[] = [
  { id: 1, title: '枭起青壤', poster: $r('app.media.poster_xiaoqiqingrang'), totalEpisodes: 32, currentEpisode: 27, addedDays: 1 },
  { id: 2, title: '繁花', poster: $r('app.media.poster_fanhua'), totalEpisodes: 30, currentEpisode: 0, addedDays: 2 },
  { id: 3, title: '狂飙', poster: $r('app.media.poster_kuangbiao'), totalEpisodes: 39, currentEpisode: 0, addedDays: 3 }
]

@Entry
@Component
struct FavoritePage {
  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => router.back())

        Text('我的收藏')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .margin({ left: Spacing.md })

        Blank()

        Text('编辑')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .onClick(() => { /* 编辑功能暂不实现 */ })
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg, bottom: Spacing.md })
      .backgroundColor(Color.White)

      Column() {
        List() {
          ForEach(favoriteList, (item: FavoriteItem) => {
            ListItem() {
              this.FavoriteCard(item)
            }
          }, (item: FavoriteItem) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
        .backgroundColor(Colors.background)

        Text('已经全部展示完了~')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textTertiary)
          .padding({ top: Spacing.md, bottom: Spacing.lg })
          .width('100%')
          .textAlign(TextAlign.Center)
          .backgroundColor(Colors.background)
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  FavoriteCard(item: FavoriteItem) {
    Row() {
      Image(item.poster)
        .width(80)
        .height(110)
        .objectFit(ImageFit.Cover)
        .borderRadius(BorderRadius.small)

      Column() {
        Row() {
          Text(item.title)
            .fontSize(FontSizes.caption)
            .fontWeight(FontWeightValue.medium)
            .fontColor(Colors.textPrimary)
          Blank()
          Text(item.addedDays + '天前添加的')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }
        .width('100%')
        .margin({ bottom: Spacing.sm })

        Row() {
          Text('全' + item.totalEpisodes + '集')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#F0F0F0')
            .borderRadius(BorderRadius.small)
          Blank()
          if (item.currentEpisode > 0 && item.currentEpisode < item.totalEpisodes) {
            Text('观看至' + item.currentEpisode + '集·' +
              Math.round(item.currentEpisode / item.totalEpisodes * 100) + '%')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.primary)
          } else if (item.currentEpisode === item.totalEpisodes) {
            Text('已看完')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.secondary)
          } else {
            Text('独播')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .height('100%')
      .margin({ left: Spacing.md })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(Spacing.md)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .margin({ bottom: Spacing.md })
    .height(130)
  }
}