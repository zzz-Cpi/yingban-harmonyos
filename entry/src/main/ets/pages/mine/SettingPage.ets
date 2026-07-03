import router from '@ohos.router'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import promptAction from '@ohos.promptAction'

interface SettingRow {
  id: string
  title: string
  desc?: string
  showArrow: boolean
}

interface SettingGroup {
  title?: string
  items: SettingRow[]
}

const settingGroups: SettingGroup[] = [
  {
    items: [
      { id: 'account', title: '账号信息管理', showArrow: true },
      { id: 'device', title: '登录设备管理', showArrow: true },
      { id: 'appearance', title: '外观设置', showArrow: true },
      { id: 'teenager', title: '未成年人模式', showArrow: true },
      { id: 'parent', title: '家长守护', showArrow: true }
    ]
  },
  {
    items: [
      { id: 'play', title: '播放设置', showArrow: true },
      { id: 'download', title: '下载&上传设置', showArrow: true },
      { id: 'notify', title: '通知设置', showArrow: true },
      { id: 'storage', title: '存储空间管理', desc: '97M', showArrow: true }
    ]
  },
  {
    items: [
      { id: 'privacy', title: '隐私管理', showArrow: true },
      { id: 'about', title: '关于影伴视频', showArrow: true },
      { id: 'version', title: '版本号设置 V1.1.1', desc: '已是最新版本', showArrow: true }
    ]
  },
  {
    items: [
      { id: 'switch', title: '切换账号', showArrow: false }
    ]
  },
  {
    items: [
      { id: 'logout', title: '退出账号', showArrow: false }
    ]
  }
]

@Entry
@Component
struct SettingPage {
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

        Text('设置')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)

        Blank()

        Row()
          .width(26)
          .height(26)
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .backgroundColor(Colors.background)

      Divider().color('#EEEEEE')

      Scroll() {
        Column({ space: Spacing.md }) {
          ForEach(settingGroups, (group: SettingGroup, groupIndex: number) => {
            this.SettingGroupCard(group, groupIndex)
          }, (group: SettingGroup, index: number) => 'group_' + index)

          Text('查看《已收集个人信息清单》和《第三方信息共享清单》')
            .fontSize(10)
            .fontColor(Colors.textTertiary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: Spacing.sm, bottom: Spacing.lg })
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

  @Builder
  SettingGroupCard(group: SettingGroup, groupIndex: number) {
    Column() {
      ForEach(group.items, (item: SettingRow, index: number) => {
        this.SettingRow(item, groupIndex, index)
        if (index < group.items.length - 1) {
          Divider()
            .color('#F0F0F0')
            .margin({ left: Spacing.lg })
        }
      }, (item: SettingRow) => item.id)
    }
    .width('100%')
    .backgroundColor(Colors.cardBackground)
    .borderRadius(BorderRadius.medium)
  }

  @Builder
  SettingRow(item: SettingRow, groupIndex: number, itemIndex: number) {
    Row() {
      Text(item.title)
        .fontSize(FontSizes.caption)
        .fontColor(this.isSpecialAction(groupIndex) ? Colors.primary : Colors.textPrimary)
        .textAlign(this.isSpecialAction(groupIndex) ? TextAlign.Center : TextAlign.Start)
        .layoutWeight(this.isSpecialAction(groupIndex) ? 1 : 0)

      if (!this.isSpecialAction(groupIndex)) {
        Blank()
      }

      if (item.desc && item.desc.length > 0 && !this.isSpecialAction(groupIndex)) {
        Text(item.desc)
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textTertiary)
      }

      if (item.showArrow) {
        Image($r('app.media.icon_arrow_right'))
          .width(18)
          .height(18)
          .objectFit(ImageFit.Contain)
          .margin({ left: Spacing.sm })
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: Spacing.lg, right: Spacing.lg })
    .onClick(() => {
      this.handleClick(item)
    })
  }

  private isSpecialAction(groupIndex: number): boolean {
    return groupIndex >= 3
  }

  private handleClick(item: SettingRow): void {
    if (item.id === 'logout') {
      promptAction.showToast({ message: '已退出账号' })
    } else if (item.id === 'switch') {
      promptAction.showToast({ message: '切换账号' })
    } else {
      promptAction.showToast({ message: item.title + '开发中' })
    }
  }
}

export default SettingPage
