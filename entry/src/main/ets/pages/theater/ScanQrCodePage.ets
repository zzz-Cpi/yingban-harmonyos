import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'
import promptAction from '@ohos.promptAction'

const TAG = 'ScanQrCodePage'
const SCAN_RESULT_KEY = 'theater_scan_result'

@Entry
@Component
struct ScanQrCodePage {
  @State private scanResult: string = ''
  @State private scanStatus: string = '请输入房间号'
  @State private isScanning: boolean = false
  @State private showManualInput: boolean = true
  @State private manualRoomId: string = ''
  @State private errorMessage: string = ''

  aboutToAppear(): void {
    hilog.info(0, TAG, 'ScanQrCodePage appear')
  }

  private handleScanResult(result: string): void {
    if (!result || result.trim().length === 0) {
      this.errorMessage = '内容为空，请重新输入'
      this.scanStatus = '输入失败'
      return
    }

    setTimeout(() => {
      try {
        AppStorage.setOrCreate(SCAN_RESULT_KEY, result)
        router.back()
      } catch (err) {
        hilog.error(0, TAG, 'Back to theater page failed')
      }
    }, 500)
  }

  private onManualConfirm(): void {
    const roomId: string = this.manualRoomId.trim()
    if (roomId.length === 0) {
      this.errorMessage = '请输入房间ID或房间号'
      return
    }
    this.errorMessage = ''
    this.handleScanResult(roomId)
  }

  private onBack(): void {
    try {
      router.back()
    } catch (err) {
      hilog.error(0, TAG, 'Back failed')
    }
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(FontSizes.body)
          .fontColor(Color.White)
          .onClick(() => {
            this.onBack()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: Spacing.lg, right: Spacing.lg })
      .justifyContent(FlexAlign.Start)
      .backgroundColor('rgba(0,0,0,0.6)')

      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text('扫码加入房间')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Color.White)
            .margin({ bottom: Spacing.md })

          Text(this.scanStatus)
            .fontSize(FontSizes.caption)
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ bottom: Spacing.lg })

          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.warning)
              .margin({ bottom: Spacing.md })
              .padding({ left: Spacing.lg, right: Spacing.lg })
              .textAlign(TextAlign.Center)
          }

          TextInput({ placeholder: '请输入6位房间号', text: this.manualRoomId })
            .width(240)
            .height(48)
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(BorderRadius.medium)
            .fontColor(Color.White)
            .placeholderColor('rgba(255,255,255,0.4)')
            .padding({ left: Spacing.md, right: Spacing.md })
            .margin({ bottom: Spacing.lg })
            .onChange((value: string) => {
              this.manualRoomId = value.toUpperCase()
            })
            .onSubmit(() => {
              this.onManualConfirm()
            })

          Text('确认加入')
            .fontSize(FontSizes.body)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.medium)
            .padding({ left: Spacing.xl, right: Spacing.xl, top: 12, bottom: 12 })
            .backgroundColor(Colors.primary)
            .borderRadius(BorderRadius.button)
            .onClick(() => {
              this.onManualConfirm()
            })

          Text('提示：请向房主获取房间号')
            .fontSize(FontSizes.helper)
            .fontColor('rgba(255,255,255,0.4)')
            .margin({ top: Spacing.xl })
        }
        .justifyContent(FlexAlign.Center)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('rgba(0,0,0,0.9)')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}

export default ScanQrCodePage