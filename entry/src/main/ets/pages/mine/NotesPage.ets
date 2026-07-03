import { mockNotes, Note } from '../../model/MockData'
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import router from '@ohos.router'

@Entry
@Component
struct NotesPage {
  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back()
          })

        Text('观影笔记')
          .fontSize(FontSizes.pageTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .margin({ left: Spacing.md })

        Blank()
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg, bottom: Spacing.md })
      .backgroundColor(Color.White)

      List() {
        ForEach(mockNotes, (note: Note) => {
          ListItem() {
            this.NoteCard(note)
          }
        }, (note: Note) => note.id.toString())

        ListItem() {
          Column() {
            Row() {
              Text('+')
                .fontSize(32)
                .fontWeight(FontWeightValue.bold)
                .fontColor(Colors.primary)
                .width(40)
                .height(40)
                .textAlign(TextAlign.Center)
                .backgroundColor('#FFF0F0')
                .borderRadius(20)

              Text('添加更多笔记')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
                .margin({ left: Spacing.md })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(Spacing.md)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(BorderRadius.medium)
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: Spacing.md })
          .onClick(() => {
            console.info('点击添加更多笔记')
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
      .backgroundColor(Colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
  }

  @Builder
  NoteCard(note: Note) {
    Column() {
      Row() {
        Text(note.movieTitle)
          .fontSize(FontSizes.caption)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)

        Text(' - 第' + note.episode + '集')
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
          .margin({ left: 4 })
      }
      .width('100%')
      .margin({ bottom: Spacing.sm })

      Text(note.content)
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textSecondary)
        .width('100%')
        .margin({ bottom: Spacing.sm })

      Row({ space: 4 }) {
        ForEach(note.tags, (tag: string) => {
          Text(tag)
            .fontSize(10)
            .fontColor(Colors.primary)
            .backgroundColor('#FFF0F0')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(BorderRadius.small)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Spacing.md)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .margin({ bottom: Spacing.md })
  }
}