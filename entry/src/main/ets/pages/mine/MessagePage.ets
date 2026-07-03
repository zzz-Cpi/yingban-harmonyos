import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import promptAction from '@ohos.promptAction'

interface MessageItem {
  id: number
  type: 'system' | 'notify' | 'like' | 'comment'
  title: string
  content: string
  time: string
  unread: boolean
  icon: Resource
}

const mockMessages: MessageItem[] = [
  {
    id: 1,
    type: 'system',
    title: '系统通知',
    content: '欢迎使用影伴，开启你的追剧之旅吧！',
    time: '刚刚',
    unread: true,
    icon: $r('app.media.icon_msg')
  },
  {
    id: 2,
    type: 'notify',
    title: '追剧提醒',
    content: '「庆余年 第二季」第36集已更新',
    time: '2小时前',
    unread: true,
    icon: $r('app.media.icon_msg')
  },
  {
    id: 3,
    type: 'like',
    title: '点赞提醒',
    content: '你的观影笔记获得了 5 个赞',
    time: '昨天',
    unread: false,
    icon: $r('app.media.feature_like')
  },
  {
    id: 4,
    type: 'system',
    title: '观影邀请',
    content: '小明邀请你一起观看「繁花」',
    time: '2天前',
    unread: false,
    icon: $r('app.media.icon_msg')
  }
]

@Entry
@Component
struct MessagePage {
  @State messages: MessageItem[] = mockMessages

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

        Text('消息通知')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)
          .margin({ left: Spacing.md })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.background)

      Divider().color('#EEEEEE')

      Scroll() {
        Column() {
          ForEach(this.messages, (item: MessageItem) => {
            this.MessageItem(item)
          }, (item: MessageItem) => item.id.toString())
        }
        .width('100%')
        .padding(Spacing.lg)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  MessageItem(item: MessageItem) {
    Row() {
      Stack() {
        Image(item.icon)
          .width(44)
          .height(44)
          .borderRadius(22)
          .backgroundColor('#F0F0F0')

        if (item.unread) {
          Row()
            .width(10)
            .height(10)
            .borderRadius(5)
            .backgroundColor('#FF3B30')
            .position({ x: 36, y: 0 })
        }
      }

      Column() {
        Row() {
          Text(item.title)
            .fontSize(FontSizes.caption)
            .fontWeight(FontWeightValue.medium)
            .fontColor(Colors.textPrimary)

          Blank()

          Text(item.time)
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
        }
        .width('100%')

        Text(item.content)
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textSecondary)
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: Spacing.md })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Spacing.md)
    .backgroundColor(Colors.cardBackground)
    .borderRadius(BorderRadius.medium)
    .margin({ bottom: Spacing.md })
    .onClick(() => {
      promptAction.showToast({ message: item.title })
    })
  }
}

export default MessagePage
