import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct AchievementPage {
  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_arrow_left'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back()
          })

        Blank()

        Text('已获得7个勋章')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)

        Blank()

        Image($r('app.media.icon_screenshot'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            promptAction.showToast({ message: '已保存到相册' })
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Color.White)

      Divider().color('#EEEEEE')

      Scroll() {
        Column({ space: Spacing.xl }) {
          Row({ space: Spacing.md }) {
            this.AchievementItem($r('app.media.badge_day1'), '连续观看1天')
            this.AchievementItem($r('app.media.badge_day3'), '连续观看3天')
            this.AchievementItem($r('app.media.badge_day7'), '连续观看7天')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)

          Row({ space: Spacing.md }) {
            this.AchievementItem($r('app.media.badge_day15'), '连续观看15天')
            this.AchievementItem($r('app.media.badge_day30'), '连续观看30天')
            this.AchievementItem($r('app.media.badge_day60'), '连续观看60天')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)

          Row({ space: Spacing.md }) {
            this.AchievementItem($r('app.media.badge_crown'), '追剧达人')
          }
          .width('100%')
          .padding({ left: Spacing.md })
        }
        .width('100%')
        .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl, bottom: Spacing.xl })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  AchievementItem(icon: Resource, name: string) {
    Column({ space: Spacing.sm }) {
      Image(icon)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)

      Text(name)
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(90)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      promptAction.showToast({ message: name })
    })
  }
}

export default AchievementPage
