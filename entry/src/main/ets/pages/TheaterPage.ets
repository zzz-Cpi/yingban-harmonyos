import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../utils/Constants'
import { RoomManagerService, Room } from '../distributed/RoomManagerService'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'

const TAG = 'TheaterPage'

interface QrCell {
  x: number
  y: number
  filled: boolean
}

@Entry
@Component
struct TheaterPage {
  @State private isScanning: boolean = false
  @State private showCreateDialog: boolean = false
  @State private showQrDialog: boolean = false
  @State private showScanDialog: boolean = false
  @State private roomName: string = ''
  @State private nearbyRooms: Room[] = []
  @State private isServiceReady: boolean = false
  @State private errorMessage: string = ''
  @State private currentRoomInfo: Room | null = null
  @State private qrCells: QrCell[] = []
  @State private scanResult: string = ''

  aboutToAppear() {
    this.initService()
    this.loadNearbyRooms()
  }

  async initService(): Promise<void> {
    try {
      await RoomManagerService.getInstance().init()
      this.isServiceReady = true
      hilog.info(0, TAG, 'RoomManagerService initialized')
    } catch (err) {
      hilog.error(0, TAG, `Failed to init service: ${JSON.stringify(err)}`)
      this.errorMessage = '分布式服务初始化失败'
    }
  }

  async loadNearbyRooms(): Promise<void> {
    this.isScanning = true
    this.errorMessage = ''

    try {
      const rooms = await RoomManagerService.getInstance().discoverNearbyRooms()
      this.nearbyRooms = rooms
      hilog.info(0, TAG, `Found ${rooms.length} nearby rooms`)
    } catch (err) {
      hilog.error(0, TAG, `Failed to discover rooms: ${JSON.stringify(err)}`)
      this.errorMessage = '扫描附近房间失败，请重试'
    } finally {
      this.isScanning = false
    }
  }

  async onCreateRoom(): Promise<void> {
    if (!this.roomName.trim()) {
      this.errorMessage = '请输入房间名称'
      return
    }

    try {
      const room = await RoomManagerService.getInstance().createRoom(this.roomName.trim())
      hilog.info(0, TAG, `Room created: ${room.roomName}`)
      this.showCreateDialog = false
      this.roomName = ''
      this.showQrCodeDialog(room)
    } catch (err) {
      hilog.error(0, TAG, `Failed to create room: ${JSON.stringify(err)}`)
      this.errorMessage = '创建房间失败，请重试'
    }
  }

  showQrCodeDialog(room: Room): void {
    this.currentRoomInfo = room
    this.qrCells = this.generateMockQrCode(room.roomId)
    this.showQrDialog = true
  }

  generateMockQrCode(content: string): QrCell[] {
    const size = 21
    const cells: QrCell[] = []
    let hash = 0
    for (let i = 0; i < content.length; i++) {
      hash = ((hash << 5) - hash) + content.charCodeAt(i)
      hash = hash & hash
    }

    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        let filled = false
        if ((x < 7 && y < 7) || (x >= size - 7 && y < 7) || (x < 7 && y >= size - 7)) {
          const lx = x < 7 ? x : x - (size - 7)
          const ly = y < 7 ? y : y - (size - 7)
          if ((lx === 0 || lx === 6 || ly === 0 || ly === 6) && lx >= 0 && lx <= 6 && ly >= 0 && ly <= 6) {
            filled = true
          }
          if (lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4) {
            filled = true
          }
        } else {
          const pseudo = (x * 31 + y * 17 + hash) % 7
          filled = pseudo < 3
        }
        cells.push({ x: x, y: y, filled: filled })
      }
    }
    return cells
  }

  async onJoinRoom(room: Room): Promise<void> {
    try {
      await RoomManagerService.getInstance().joinRoom(room)
      hilog.info(0, TAG, `Joined room: ${room.roomName}`)
      this.navigateToRoomDetail(room)
    } catch (err) {
      hilog.error(0, TAG, `Failed to join room: ${JSON.stringify(err)}`)
      this.errorMessage = '加入房间失败，请重试'
    }
  }

  onScanClick(): void {
    this.scanResult = ''
    this.showScanDialog = true
    this.startScan()
  }

  async startScan(): Promise<void> {
    try {
      const scanModule = await import('@ohos.scanBarcode')
      const options = {
        scanTypes: [0, 1],
        enableMultiMode: false,
        enableAlbum: true
      }
      scanModule.default.scan(options, (err: BusinessError, result: string) => {
        if (err) {
          hilog.error(0, TAG, `Scan failed: ${JSON.stringify(err)}`)
          this.scanResult = '扫码失败，请手动输入房间号'
        } else {
          hilog.info(0, TAG, `Scan result: ${result}`)
          this.handleScanResult(result)
        }
      })
    } catch (err) {
      hilog.warn(0, TAG, `Scan module not available: ${JSON.stringify(err)}`)
      this.scanResult = '当前设备不支持扫码功能'
    }
  }

  handleScanResult(result: string): void {
    hilog.info(0, TAG, `Handle scan result: ${result}`)
    this.showScanDialog = false
    
    const roomId = result
    const mockRoom: Room = {
      roomId: roomId,
      roomName: '扫码加入的房间',
      hostId: 'scan_host',
      hostName: '房主',
      memberCount: 1,
      maxMember: 8,
      status: 'waiting',
      createdTime: Date.now(),
      members: []
    }
    this.onJoinRoom(mockRoom)
  }

  enterRoomDirectly(): void {
    this.showQrDialog = false
    if (this.currentRoomInfo) {
      this.navigateToRoomDetail(this.currentRoomInfo)
    }
  }

  navigateToRoomDetail(room: Room): void {
    router.pushUrl({
      url: 'pages/theater/RoomDetailPage',
      params: {
        roomId: room.roomId,
        roomName: room.roomName,
        isHost: RoomManagerService.getInstance().isRoomHost()
      }
    })
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          this.CoreActions()

          if (this.errorMessage) {
            this.ErrorTip()
          }

          this.NearbyRooms()

          this.UsageTips()
        }
        .padding({ bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.background)
    .overlay(this.CreateRoomDialog())
    .overlay(this.QrCodeDialog())
    .overlay(this.ScanDialog())
  }

  @Builder
  TopBar() {
    Column() {
      Row() {
        Column() {
          Text('观影厅')
            .fontSize(FontSizes.pageTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)

          Text('近场零流量同步观影')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row({ space: 12 }) {
          if (this.isScanning) {
            LoadingProgress()
              .width(18)
              .height(18)
              .color(Colors.secondary)
          }

          Text('🔄')
            .fontSize(18)
            .onClick(() => {
              this.loadNearbyRooms()
            })
        }
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.md })
      .backgroundColor(Color.White)
    }
  }

  @Builder
  CoreActions() {
    Column() {
      Column() {
        Row() {
          Text('➕')
            .fontSize(24)
            .fontColor(Color.White)

          Column() {
            Text('创建观影房')
              .fontSize(FontSizes.body)
              .fontWeight(FontWeightValue.semibold)
              .fontColor(Color.White)

            Text('邀请好友一起同步观影')
              .fontSize(FontSizes.helper)
              .fontColor('rgba(255,255,255,0.8)')
          }
          .margin({ left: Spacing.md })
        }
        .width('100%')
      }
      .width('100%')
      .height(80)
      .backgroundColor(Colors.primary)
      .borderRadius(BorderRadius.large)
      .padding({ left: Spacing.xl, right: Spacing.xl })
      .shadow(Shadows.floating)
      .onClick(() => {
        this.showCreateDialog = true
      })

      Column() {
        Row() {
          Text('📷')
            .fontSize(24)
            .fontColor(Colors.secondary)

          Column() {
            Text('扫码加入')
              .fontSize(FontSizes.body)
              .fontWeight(FontWeightValue.semibold)
              .fontColor(Colors.textPrimary)

            Text('扫描二维码加入房间')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .margin({ left: Spacing.md })
        }
        .width('100%')
      }
      .width('100%')
      .height(80)
      .backgroundColor(Color.White)
      .borderRadius(BorderRadius.large)
      .padding({ left: Spacing.xl, right: Spacing.xl })
      .margin({ top: Spacing.md })
      .shadow(Shadows.card)
      .onClick(() => {
        this.onScanClick()
      })
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  ErrorTip() {
    Row() {
      Text('⚠️')
        .fontSize(14)

      Text(this.errorMessage)
        .fontSize(FontSizes.helper)
        .fontColor(Colors.warning)
        .margin({ left: Spacing.sm })
    }
    .width('100%')
    .padding(Spacing.md)
    .backgroundColor('#FFF8E1')
    .borderRadius(BorderRadius.medium)
    .margin({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
  }

  @Builder
  NearbyRooms() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Stack({ alignContent: Alignment.Center }) {
            if (this.isScanning) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color(Colors.secondary)
            } else {
              Row()
                .width(20)
                .height(20)
                .borderRadius(10)
                .border({ width: 2, color: Colors.secondary })
                .backgroundColor(Color.White)

              Row()
                .width(8)
                .height(8)
                .borderRadius(4)
                .backgroundColor(Colors.secondary)
            }
          }
          .width(20)
          .height(20)

          Text('附近房间')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Colors.textPrimary)
        }

        Blank()

        Text(this.isScanning ? '扫描中...' : `${this.nearbyRooms.length}个房间`)
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textSecondary)
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      if (this.nearbyRooms.length === 0) {
        this.EmptyRoomTip()
      } else {
        ForEach(this.nearbyRooms, (room: Room) => {
          this.RoomItem(room)
        }, (room: Room) => room.roomId)
      }
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  EmptyRoomTip() {
    Column() {
      Text('📡')
        .fontSize(48)
        .opacity(0.5)

      Text(this.isScanning ? '正在扫描附近房间...' : '暂无附近房间')
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textTertiary)
        .margin({ top: Spacing.md })

      Text(this.isScanning ? '请稍候...' : '创建一个房间开始观影吧')
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textTertiary)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(160)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.large)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  RoomItem(room: Room) {
    Column() {
      Row() {
        Column() {
          Text(room.roomName)
            .fontSize(FontSizes.body)
            .fontWeight(FontWeightValue.medium)
            .fontColor(Colors.textPrimary)

          Row({ space: 8 }) {
            Text('房主: ' + room.hostName)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)

            Text('·')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textTertiary)

            Text(room.memberCount + '/' + room.maxMember + '人')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row({ space: 8 }) {
          if (room.status === 'playing') {
            Text('播放中')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(Colors.primary)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(BorderRadius.small)
          } else {
            Text('等待中')
              .fontSize(10)
              .fontColor(Colors.secondary)
              .backgroundColor('#E0F7F5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(BorderRadius.small)
          }

          Text('>')
            .fontSize(14)
            .fontColor(Colors.textTertiary)
        }
      }
      .width('100%')

      if (room.movieTitle) {
        Row() {
          Text('▶')
            .fontSize(12)
            .fontColor(Colors.textSecondary)

          Text('正在播放: ' + room.movieTitle)
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textSecondary)
            .margin({ left: 4 })
        }
        .margin({ top: Spacing.sm })
      }
    }
    .width('100%')
    .padding(Spacing.lg)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.large)
    .margin({ bottom: Spacing.md })
    .shadow(Shadows.card)
    .onClick(() => {
      this.onJoinRoom(room)
    })
  }

  @Builder
  UsageTips() {
    Column() {
      Row() {
        Text('观影厅使用说明')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.semibold)
          .fontColor(Colors.textPrimary)
      }
      .width('100%')
      .margin({ bottom: Spacing.md })

      Row({ space: Spacing.md }) {
        this.TipItem('📡', '无需流量', '近场直连')
        this.TipItem('📱', '一碰建组', '鸿蒙设备')
        this.TipItem('🎬', '同步播放', '进度一致')
      }
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.xl })
  }

  @Builder
  TipItem(icon: string, title: string, subtitle: string) {
    Column() {
      Text(icon)
        .fontSize(24)

      Text(title)
        .fontSize(FontSizes.caption)
        .fontColor(Colors.textPrimary)
        .margin({ top: Spacing.sm })

      Text(subtitle)
        .fontSize(FontSizes.helper)
        .fontColor(Colors.textSecondary)
    }
    .layoutWeight(1)
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.medium)
    .justifyContent(FlexAlign.Center)
    .shadow(Shadows.card)
  }

  @Builder
  CreateRoomDialog() {
    if (this.showCreateDialog) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.showCreateDialog = false
            this.roomName = ''
          })

        Column() {
          Text('创建观影房')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)
            .margin({ bottom: Spacing.lg })

          Text('房间名称')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textSecondary)
            .margin({ bottom: Spacing.sm })
            .width('100%')

          TextInput({ placeholder: '请输入房间名称', text: this.roomName })
            .width('100%')
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(BorderRadius.medium)
            .padding({ left: Spacing.md, right: Spacing.md })
            .onChange((value: string) => {
              this.roomName = value
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
                this.showCreateDialog = false
                this.roomName = ''
              })

            Text('创建')
              .fontSize(FontSizes.body)
              .fontColor(Color.White)
              .fontWeight(FontWeightValue.medium)
              .layoutWeight(1)
              .height(44)
              .textAlign(TextAlign.Center)
              .backgroundColor(Colors.primary)
              .borderRadius(BorderRadius.medium)
              .onClick(() => {
                this.onCreateRoom()
              })
          }
          .width('100%')
          .margin({ top: Spacing.xl })
        }
        .width('80%')
        .padding(Spacing.xl)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
        .shadow(Shadows.floating)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  @Builder
  QrCodeDialog() {
    if (this.showQrDialog && this.currentRoomInfo) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.showQrDialog = false
          })

        Column() {
          Text('房间二维码')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)
            .margin({ bottom: Spacing.sm })

          Text(this.currentRoomInfo.roomName)
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
            .margin({ bottom: Spacing.xl })

          Stack({ alignContent: Alignment.Center }) {
            Column() {
              ForEach(this.qrCells, (cell: QrCell) => {
                Row()
                  .width(8)
                  .height(8)
                  .backgroundColor(cell.filled ? Color.Black : Color.White)
                  .position({ x: cell.x * 8, y: cell.y * 8 })
              }, (cell: QrCell) => `${cell.x}-${cell.y}`)
            }
            .width(168)
            .height(168)
            .backgroundColor(Color.White)
            .padding(8)
            .borderRadius(BorderRadius.medium)
          }
          .width(200)
          .height(200)
          .backgroundColor(Color.White)
          .borderRadius(BorderRadius.large)
          .justifyContent(FlexAlign.Center)

          Text('扫码加入观影房')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
            .margin({ top: Spacing.xl })

          Text('进入房间')
            .fontSize(FontSizes.body)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.medium)
            .width('100%')
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor(Colors.primary)
            .borderRadius(BorderRadius.medium)
            .margin({ top: Spacing.xl })
            .onClick(() => {
              this.enterRoomDirectly()
            })
        }
        .width('80%')
        .padding(Spacing.xl)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
        .shadow(Shadows.floating)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  @Builder
  ScanDialog() {
    if (this.showScanDialog) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.8)')
          .onClick(() => {
            this.showScanDialog = false
          })

        Column() {
          Text('扫码加入房间')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Color.White)
            .margin({ bottom: Spacing.xl })

          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(200)
              .height(200)
              .border({ width: 2, color: Colors.secondary })
              .borderRadius(BorderRadius.medium)

            Column()
              .width(200)
              .height(2)
              .backgroundColor(Colors.primary)
              .margin({ top: 0 })
          }
          .width(200)
          .height(200)

          Text('将二维码放入框内扫描')
            .fontSize(FontSizes.helper)
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ top: Spacing.xl })

          if (this.scanResult) {
            Text(this.scanResult)
              .fontSize(FontSizes.caption)
              .fontColor(Colors.warning)
              .margin({ top: Spacing.md })
          }

          Text('取消')
            .fontSize(FontSizes.body)
            .fontColor(Color.White)
            .width(120)
            .height(40)
            .textAlign(TextAlign.Center)
            .backgroundColor('rgba(255,255,255,0.2)')
            .borderRadius(20)
            .margin({ top: Spacing.xl })
            .onClick(() => {
              this.showScanDialog = false
            })
        }
        .width('85%')
        .padding(Spacing.xl)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }
}

export default TheaterPage
