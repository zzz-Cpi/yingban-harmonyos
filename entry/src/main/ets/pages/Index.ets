// 主入口页面 - 包含底部Tab导航
import HomePage from './HomePage'
import DramaPage from './DramaPage'
import TheaterPage from './TheaterPage'
import MinePage from './MinePage'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  private tabTitles: string[] = ['首页', '追剧', '观影厅', '我的']
  private tabIcons: string[] = ['🏠', '🎬', '📡', '👤']

  build() {
    Column() {
      // 页面内容区
      Stack() {
        if (this.currentIndex === 0) {
          HomePage()
        } else if (this.currentIndex === 1) {
          DramaPage()
        } else if (this.currentIndex === 2) {
          TheaterPage()
        } else if (this.currentIndex === 3) {
          MinePage()
        }
      }
      .layoutWeight(1)

      // 底部Tab栏
      Row() {
        ForEach(this.tabTitles, (title: string, index: number) => {
          Column() {
            Text(this.tabIcons[index])
              .fontSize(22)

            Text(title)
              .fontSize(10)
              .fontColor(this.currentIndex === index ? '#FF6B6B' : '#8E8E93')
              .margin({ top: 4 })
          }
          .width('25%')
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.currentIndex = index
          })
        })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5')
  }
}
