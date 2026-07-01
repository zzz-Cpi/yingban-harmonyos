import web_webview from '@ohos.web.webview'

@Component
export struct VideoWebPage {
  @State url: string = ''
  @State title: string = '视频播放'
  controller: web_webview.WebviewController = new web_webview.WebviewController()

  build() {
    NavDestination() {
      Column() {
        Web({
          src: this.url,
          controller: this.controller
        })

          .width('100%')
          .height('100%')
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .onlineImageAccess(true)
          .mixedMode(MixedMode.All)
          .mediaPlayGestureAccess(false)
          .onLoadIntercept((event) => {
            console.log('Web 跳转地址：', event.data.getRequestUrl())
            return false
          })
      }
      .width('100%')
      .height('100%')
    }
    .title(this.title)
  }
}
