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
    .onBackPressed(() => {
      // 如果 WebView 有后退历史，先后退 WebView
      if (this.controller.accessBackward()) {
        this.controller.backward()
        return true
      }
      // 否则返回追剧页
      return false
    })
  }
}
