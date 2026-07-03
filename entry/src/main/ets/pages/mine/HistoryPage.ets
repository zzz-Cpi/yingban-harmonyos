// 观看历史页
import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'

@Entry
@Component
struct HistoryPage {
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.icon_arrow_left'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back()
          })

        Blank()

        Text('观看历史')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)

        Blank()

        Text('编辑')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.background)

      Divider().color('#EEEEEE')

      // 可滑动列表区
      Scroll() {
        Column() {
          Column() {
            this.HistoryItem(
              $r('app.media.horizontal_xiaoqiqingrang'),
              '枭起青壤',
              27,
              32,
              85,
              '2026-06-02 19:04'
            )
            this.ItemDivider()

            this.HistoryItem(
              $r('app.media.horizontal_fanhua'),
              '繁花',
              18,
              30,
              60,
              '2026-06-01 20:30'
            )
            this.ItemDivider()

            this.HistoryItem(
              $r('app.media.horizontal_qingyunian'),
              '庆余年 第二季',
              15,
              36,
              42,
              '2026-05-30 18:15'
            )
            this.ItemDivider()

            this.HistoryItem(
              $r('app.media.horizontal_kuangbiao'),
              '狂飙',
              12,
              39,
              31,
              '2026-05-28 21:50'
            )
            this.ItemDivider()

            this.HistoryItem(
              $r('app.media.horizontal_aletai'),
              '我的阿勒泰',
              8,
              8,
              100,
              '2026-05-25 22:00'
            )
            this.ItemDivider()

            this.HistoryItem(
              $r('app.media.horizontal_langyabang'),
              '琅琊榜',
              0,
              54,
              0,
              '2026-05-20 17:30'
            )
          }
          .width('100%')
          .backgroundColor(Colors.cardBackground)
          .borderRadius(BorderRadius.medium)
          .padding({ left: Spacing.lg, right: Spacing.lg })

          Text('已经全部展示完了~')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
            .margin({ top: Spacing.xl, bottom: Spacing.lg })
        }
        .width('100%')
        .padding(Spacing.lg)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  // 单条观看历史：封面 + 剧名 + 集数 + 进度 + 日期
  @Builder
  HistoryItem(
    poster: Resource,
    title: string,
    currentEpisode: number,
    totalEpisodes: number,
    progressPercent: number,
    dateText: string
  ) {
    Row() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(poster)
          .width(140)
          .height(80)
          .borderRadius(BorderRadius.small)
          .objectFit(ImageFit.Cover)
          .clip(true)

        // 底部进度条背景
        Row()
          .width('100%')
          .height(3)
          .borderRadius(1.5)
          .backgroundColor('rgba(255,255,255,0.3)')

        // 进度条前景
        Row()
          .width(progressPercent + '%')
          .height(3)
          .borderRadius(1.5)
          .backgroundColor('#00C8C8')
      }
      .width(140)
      .height(80)
      .borderRadius(BorderRadius.small)
      .clip(true)

      Column() {
        Text(title)
          .fontSize(FontSizes.caption)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)

        Row() {
          Text('第' + currentEpisode + '集 / 共' + totalEpisodes + '集')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)

          Blank()

          Text(progressPercent + '%')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
        }
        .margin({ top: 4 })

        Row() {
          Text('📱')
            .fontSize(14)

          Text('手机观看')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
            .margin({ left: 4 })

          Blank()

          Text(dateText)
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
        }
        .margin({ top: 6 })
      }
      .margin({ left: Spacing.md })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: Spacing.md, bottom: Spacing.md })
  }

  // 条目分割线
  @Builder
  ItemDivider() {
    Divider()
      .color('#F0F0F0')
      .margin({ left: 154 })
  }
}
