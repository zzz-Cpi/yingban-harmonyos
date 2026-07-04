import router from '@ohos.router'
import web_webview from '@ohos.web.webview'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'WebPlayerPage'

@Entry
@Component
struct WebPlayerPage {
  @State webUrl: string = ''
  @State pageTitle: string = ''
  @State isLoading: boolean = true
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params) {
      this.webUrl = params['url'] || ''
      this.pageTitle = params['title'] || '播放'
    }
    hilog.info(0, TAG, `WebPlayerPage url: ${this.webUrl}`)
  }

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('app.media.icon_arrow_left'))
            .width(20)
            .height(20)
            .fillColor(Color.White)
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('rgba(0,0,0,0.3)')
        .onClick(() => {
          router.back()
        })

        Text(this.pageTitle)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank()
          .width(36)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      .backgroundColor(Color.Black)

      Stack() {
        Web({ src: this.webUrl, controller: this.webviewController })
          .width('100%')
          .layoutWeight(1)
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .mixedMode(MixedMode.All)
          .onPageEnd(() => {
            this.isLoading = false
          })

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(32)
              .height(32)
              .color('#F992A5')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
