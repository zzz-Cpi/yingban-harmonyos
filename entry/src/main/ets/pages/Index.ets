// 主入口页面 - 包含底部Tab导航
import { Colors } from '../utils/Constants'
import HomePage from './home/HomePage'
import DramaPage from './drama/DramaPage'
import TheaterPage from './theater/TheaterPage'
import MinePage from './mine/MinePage'

interface TabConfig {
  title: string
  activeIcon: Resource
  inactiveIcon: Resource
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  private tabs: TabConfig[] = [
    { title: '首页', activeIcon: $r('app.media.tab_home_active'), inactiveIcon: $r('app.media.tab_home_inactive') },
    { title: '追剧', activeIcon: $r('app.media.tab_drama_active'), inactiveIcon: $r('app.media.tab_drama_inactive') },
    { title: '观影厅', activeIcon: $r('app.media.tab_theater_active'), inactiveIcon: $r('app.media.tab_theater_inactive') },
    { title: '我的', activeIcon: $r('app.media.tab_mine_active'), inactiveIcon: $r('app.media.tab_mine_inactive') }
  ]

  build() {
    Column() {
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

      Row() {
        ForEach(this.tabs, (tab: TabConfig, index: number) => {
          Column() {
            Image(this.currentIndex === index ? tab.activeIcon : tab.inactiveIcon)
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)

            Text(tab.title)
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
        }, (tab: TabConfig, index: number) => tab.title)
      }
      .width('100%')
      .height(56)
      .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }
}
