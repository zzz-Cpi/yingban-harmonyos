// 扫码识别页 - 接入鸿蒙 ScanKit 二维码识别
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { scanCore, scanBarcode } from '@kit.ScanKit'

const TAG = 'ScanQrCodePage'
const SCAN_RESULT_KEY = 'theater_scan_result'

// 扫码结果回调参数
interface ScanResultCallback {
  result: string
}

// 扫码选项类型
interface ScanOptionsType {
  scanTypes: number[]
  enableMultiMode: boolean
  enableAlbum: boolean
}

@Entry
@Component
struct ScanQrCodePage {
  @State private scanResult: string = ''
  @State private scanStatus: string = '正在启动扫码...'
  @State private isScanning: boolean = false
  @State private showManualInput: boolean = false
  @State private manualRoomId: string = ''
  @State private hasCameraPermission: boolean = false
  @State private errorMessage: string = ''

  aboutToAppear(): void {
    hilog.info(0, TAG, 'ScanQrCodePage appear')
    this.startScan()
  }

  // 启动系统扫码
  private startScan(): void {
    this.isScanning = true
    this.scanStatus = '正在启动扫码...'
    this.errorMessage = ''

    try {
      // 构建扫码选项：识别所有类型条码，支持相册
      const options: ScanOptionsType = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: false,
        enableAlbum: true
      }

      hilog.info(0, TAG, 'Starting scan with options')

      // 调用鸿蒙系统扫码接口
      scanBarcode.startScanForResult(getContext(this), options as scanBarcode.ScanOptions,
        (error: Error, result: scanBarcode.ScanResult) => {
          this.isScanning = false
          if (error) {
            hilog.error(0, TAG, `Scan failed: ${error.message}`)
            this.scanStatus = '扫码失败'
            this.errorMessage = '扫码不可用，可手动输入房间ID'
            this.showManualInput = true
            return
          }

          // 获取扫码结果
          const scanValue: string = result.originalValue
          hilog.info(0, TAG, `Scan success: ${scanValue}`)
          this.scanResult = scanValue
          this.scanStatus = '识别成功'
          this.handleScanResult(scanValue)
        })
    } catch (err) {
      const e = err as Error
      hilog.error(0, TAG, `ScanKit unavailable: ${e.message}`)
      this.isScanning = false
      this.scanStatus = '扫码不可用'
      this.errorMessage = '扫码模块不可用，可手动输入房间ID'
      this.showManualInput = true
    }
  }

  // 处理扫码识别结果
  private handleScanResult(result: string): void {
    if (!result || result.trim().length === 0) {
      this.errorMessage = '识别内容为空，请重新扫码'
      this.scanStatus = '识别失败'
      return
    }

    setTimeout(() => {
      try {
        AppStorage.setOrCreate(SCAN_RESULT_KEY, result)
        router.back()
      } catch (err) {
        hilog.error(0, TAG, 'Back to theater page failed')
      }
    }, 800)
  }

  // 手动输入房间ID确认
  private onManualConfirm(): void {
    const roomId: string = this.manualRoomId.trim()
    if (roomId.length === 0) {
      this.errorMessage = '请输入房间ID'
      return
    }
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
      // 顶部导航栏
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

      // 扫码区域
      Stack({ alignContent: Alignment.Center }) {
        // 扫码框装饰
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            // 扫码框边框
            Column()
              .width(240)
              .height(240)
              .border({
                width: 2,
                color: Colors.secondary,
                radius: BorderRadius.medium
              })

            // 四个角的装饰
            Column()
              .width(240)
              .height(240)
              .border({
                width: { top: 4, bottom: 4, left: 4, right: 4 },
                color: {
                  top: Colors.primary,
                  bottom: Colors.primary,
                  left: Colors.primary,
                  right: Colors.primary
                },
                radius: BorderRadius.medium
              })

            // 扫描线动画
            if (this.isScanning) {
              Row()
                .width(220)
                .height(2)
                .backgroundColor(Colors.primary)
                .margin({ top: 0 })
            }
          }
          .width(240)
          .height(240)

          // 提示文字
          Text(this.scanStatus)
            .fontSize(FontSizes.caption)
            .fontColor('rgba(255,255,255,0.9)')
            .margin({ top: Spacing.xl })

          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.warning)
              .margin({ top: Spacing.sm })
              .padding({ left: Spacing.lg, right: Spacing.lg })
              .textAlign(TextAlign.Center)
          }

          // 扫码结果
          if (this.scanResult) {
            Text('识别结果: ' + this.scanResult)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.secondary)
              .margin({ top: Spacing.sm })
              .padding({ left: Spacing.lg, right: Spacing.lg })
              .textAlign(TextAlign.Center)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .justifyContent(FlexAlign.Center)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('rgba(0,0,0,0.9)')

      // 底部操作区
      Column() {
        // 重试扫码按钮
        Row() {
          Text('🔄')
            .fontSize(16)
            .fontColor(Color.White)

          Text('重新扫码')
            .fontSize(FontSizes.caption)
            .fontColor(Color.White)
            .margin({ left: Spacing.sm })
        }
        .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.sm, bottom: Spacing.sm })
        .borderRadius(BorderRadius.button)
        .backgroundColor('rgba(255,255,255,0.2)')
        .margin({ bottom: Spacing.md })
        .onClick(() => {
          this.startScan()
        })

        // 手动输入房间ID按钮
        Row() {
          Text('⌨️')
            .fontSize(16)
            .fontColor(Color.White)

          Text('手动输入房间ID')
            .fontSize(FontSizes.caption)
            .fontColor(Color.White)
            .margin({ left: Spacing.sm })
        }
        .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.sm, bottom: Spacing.sm })
        .borderRadius(BorderRadius.button)
        .backgroundColor('rgba(255,255,255,0.15)')
        .onClick(() => {
          this.showManualInput = !this.showManualInput
        })
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg, bottom: Spacing.xl })
      .backgroundColor('rgba(0,0,0,0.8)')

      // 手动输入弹窗
      if (this.showManualInput) {
        this.ManualInputDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  @Builder
  ManualInputDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.7)')
        .onClick(() => {
          this.showManualInput = false
        })

      Column() {
        Text('手动输入房间ID')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)
          .margin({ bottom: Spacing.md })

        Text('请输入房主分享的房间ID')
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textSecondary)
          .margin({ bottom: Spacing.lg })

        TextInput({ placeholder: '例如: room_xxx', text: this.manualRoomId })
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(BorderRadius.medium)
          .padding({ left: Spacing.md, right: Spacing.md })
          .onChange((value: string) => {
            this.manualRoomId = value
          })

        Row({ space: Spacing.md }) {
          Text('取消')
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
            .layoutWeight(1)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('#F5F5F5')
            .borderRadius(BorderRadius.medium)
            .onClick(() => {
              this.showManualInput = false
              this.manualRoomId = ''
            })

          Text('确认加入')
            .fontSize(FontSizes.body)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.medium)
            .layoutWeight(1)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor(Colors.primary)
            .borderRadius(BorderRadius.medium)
            .onClick(() => {
              this.onManualConfirm()
            })
        }
        .width('100%')
        .margin({ top: Spacing.lg })
      }
      .width('80%')
      .padding(Spacing.xl)
      .backgroundColor(Color.White)
      .borderRadius(BorderRadius.large)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}

export default ScanQrCodePage
