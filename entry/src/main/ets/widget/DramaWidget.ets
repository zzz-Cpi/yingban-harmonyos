// 小艺AI桌面卡片 - 粉蓝渐变主题
let storage = new LocalStorage()

@Entry(storage)
@Component
struct DramaWidget {
  @LocalStorageProp('welcomeMsg') welcomeMsg: string = '不知道看什么？问问小艺吧～'
  @LocalStorageProp('quick1') quick1: string = '推荐点好看的剧'
  @LocalStorageProp('quick2') quick2: string = '古装权谋推荐'
  @LocalStorageProp('quick3') quick3: string = '有什么悬疑片'
  @LocalStorageProp('quick4') quick4: string = '高分经典有哪些'

  build() {
    Column() {
      // ===== 顶部标题栏 =====
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(32)
            .height(32)
            .borderRadius(16)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#F992A5', 0], ['#A0C8D8', 1]]
            })
          Text('艺')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }

        Column() {
          Text('小艺AI')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('你的追剧小助手')
            .fontSize(9)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })

        Blank()

        Text('×')
          .fontSize(18)
          .fontColor('rgba(255,255,255,0.8)')
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 8 })

      // ===== 欢迎语气泡 =====
      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(30)
            .height(30)
            .borderRadius(15)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#F992A5', 0], ['#A0C8D8', 1]]
            })
          Text('艺')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }

        Column() {
          Text(this.welcomeMsg)
            .fontSize(11)
            .fontColor('#2D2D3A')
            .maxLines(2)
        }
        .backgroundColor('rgba(255,255,255,0.85)')
        .borderRadius({ topLeft: 4, topRight: 14, bottomLeft: 14, bottomRight: 14 })
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .layoutWeight(1)

        Blank()
      }
      .width('100%')
      .padding({ left: 14, right: 14 })
      .margin({ top: 4 })

      // ===== 快捷提问标签 =====
      Column({ space: 6 }) {
        Text('💡 试试问我这些')
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.85)')
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          Text(this.quick1)
            .fontSize(10)
            .fontColor('#F992A5')
            .backgroundColor('rgba(255,255,255,0.75)')
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 6, bottom: 6 })
            .onClick(() => {
              postCardAction(this, {
                'action': 'router',
                'abilityName': 'EntryAbility',
                'params': { 'targetPage': 'aiChat', 'query': this.quick1 }
              })
            })

          Text(this.quick2)
            .fontSize(10)
            .fontColor('#A0C8D8')
            .backgroundColor('rgba(255,255,255,0.75)')
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 6, bottom: 6 })
            .onClick(() => {
              postCardAction(this, {
                'action': 'router',
                'abilityName': 'EntryAbility',
                'params': { 'targetPage': 'aiChat', 'query': this.quick2 }
              })
            })

          Text(this.quick3)
            .fontSize(10)
            .fontColor('#F992A5')
            .backgroundColor('rgba(255,255,255,0.75)')
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 6, bottom: 6 })
            .onClick(() => {
              postCardAction(this, {
                'action': 'router',
                'abilityName': 'EntryAbility',
                'params': { 'targetPage': 'aiChat', 'query': this.quick3 }
              })
            })

          Text(this.quick4)
            .fontSize(10)
            .fontColor('#A0C8D8')
            .backgroundColor('rgba(255,255,255,0.75)')
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 6, bottom: 6 })
            .onClick(() => {
              postCardAction(this, {
                'action': 'router',
                'abilityName': 'EntryAbility',
                'params': { 'targetPage': 'aiChat', 'query': this.quick4 }
              })
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 14, right: 14 })
      .layoutWeight(1)

      // ===== 底部输入区域 =====
      Row() {
        Row() {
          Text('和小艺聊聊追剧吧...')
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.7)')
        }
        .layoutWeight(1)
        .height(36)
        .backgroundColor('rgba(255,255,255,0.25)')
        .borderRadius(18)
        .padding({ left: 14, right: 14 })

        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor(Color.White)
          Text('→')
            .fontSize(14)
            .fontColor('#F992A5')
            .fontWeight(FontWeight.Bold)
        }
        .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 8, bottom: 14 })
      .onClick(() => {
        postCardAction(this, {
          'action': 'router',
          'abilityName': 'EntryAbility',
          'params': { 'targetPage': 'aiChat' }
        })
      })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [['#F992A5', 0], ['#B8A8D4', 0.5], ['#A0C8D8', 1]]
    })
  }
}
