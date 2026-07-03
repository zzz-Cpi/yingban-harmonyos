import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct DownloadPage {
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

        Text('下载')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)
          .margin({ left: Spacing.md })

        Blank()

        Text('设置')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)
          .onClick(() => {
            router.pushUrl({ url: 'pages/mine/SettingPage' })
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Color.White)

      Scroll() {
        Column() {

          Row() {
            Row() {
              Image($r('app.media.icon_plus'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
            }
            .width(80)
            .height(56)
            .backgroundColor('#F7F8FA')
            .borderRadius(BorderRadius.medium)
            .justifyContent(FlexAlign.Center)

            Text('缓存更多集数')
              .fontSize(FontSizes.sectionTitle)
              .fontColor(Colors.textPrimary)
              .margin({ left: Spacing.lg })

            Blank()
          }
          .width('100%')
          .padding(Spacing.lg)
          .backgroundColor(Color.White)
          .borderRadius(BorderRadius.medium)
          .margin({ bottom: Spacing.lg })
          .onClick(() => {
            promptAction.showToast({ message: '选择剧集缓存' })
          })

          Column() {
            this.DownloadItem($r('app.media.download_taipingnian'), '太平年', 42, 12)
            this.ItemDivider()
            this.DownloadItem($r('app.media.download_nanbudangan'), '南部档案', 36, 8)
            this.ItemDivider()
            this.DownloadItem($r('app.media.download_zhuyu'), '逐玉', 40, 15)
            this.ItemDivider()
            this.DownloadItem($r('app.media.download_dashengyiren'), '大生意人', 38, 6)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(BorderRadius.medium)
          .padding({ left: Spacing.lg, right: Spacing.lg })
          .margin({ bottom: Spacing.xl })

          Text('更多精彩内容')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Colors.textPrimary)
            .width('100%')
            .margin({ bottom: Spacing.md })

          Scroll() {
            Row({ space: Spacing.md }) {
              this.RecommendCard($r('app.media.recommend_shiri'), '十日终焉', '高能脑洞悬疑反转不断')
              this.RecommendCard($r('app.media.recommend_santi'), '三体·黑暗森林', '硬核科幻宇宙人性博弈')
              this.RecommendCard($r('app.media.recommend_zhujue'), '主角', '时代奋斗群像口碑佳作')
              this.RecommendCard($r('app.media.recommend_dizhi'), '低智商犯罪', '幽默探案轻松解压')
              this.RecommendCard($r('app.media.recommend_xiaocheng'), '小城大事', '市井人生温暖治愈')
              this.RecommendCard($r('app.media.recommend_guohuo'), '这一秒过火', '宿命拉扯情感爆款')
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .margin({ bottom: Spacing.xl })

          Text('已下载7.8G / 剩余168.4G空间')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
            .margin({ bottom: Spacing.lg })
        }
        .width('100%')
        .padding(Spacing.lg)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  DownloadItem(poster: Resource, title: string, total: number, watched: number) {
    Row() {
      Image(poster)
        .width(120)
        .height(68)
        .borderRadius(BorderRadius.small)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(title)
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textPrimary)
          .fontWeight(FontWeightValue.medium)

        Text(total + '个视频-' + watched + '个已下载')
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textSecondary)
          .margin({ top: 4 })
      }
      .margin({ left: Spacing.md })
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .height(88)
    .onClick(() => {
      promptAction.showToast({ message: '播放下载的' + title })
    })
  }

  @Builder
  ItemDivider() {
    Divider()
      .color('#F0F0F0')
      .margin({ left: 132 })
  }

  @Builder
  RecommendCard(poster: Resource, title: string, desc: string) {
    Column() {
      Image(poster)
        .width(110)
        .height(160)
        .borderRadius(BorderRadius.small)
        .objectFit(ImageFit.Cover)

      Text(title)
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textPrimary)
        .width('100%')
        .margin({ top: Spacing.sm })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(desc)
        .fontSize(10)
        .fontColor(Colors.textSecondary)
        .width('100%')
        .margin({ top: 2 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text('下载')
        .fontSize(10)
        .fontColor(Colors.textSecondary)
        .width('100%')
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor('#F5F5F5')
        .borderRadius(BorderRadius.small)
        .margin({ top: Spacing.sm })
    }
    .width(110)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      promptAction.showToast({ message: '开始下载' + title })
    })
  }
}

export default DownloadPage
