import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../../utils/Constants'
import { RoomManagerService, Room } from '../../distributed/RoomManagerService'
import router from '@ohos.router'
import pasteboard from '@ohos.pasteboard'
import promptAction from '@ohos.promptAction'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'TheaterPage'

interface RouterParams {
  scanResult?: string
}

// 房间主题配置
interface RoomTheme {
  id: number
  name: string
  icon: string
  gradientColors: string[]
  bgColor: string
}

const ROOM_THEMES: RoomTheme[] = [
  { id: 1, name: '影院之夜', icon: '🎬', gradientColors: ['#667eea', '#764ba2'], bgColor: 'rgba(102,126,234,0.15)' },
  { id: 2, name: '温馨小聚', icon: '🍿', gradientColors: ['#f093fb', '#f5576c'], bgColor: 'rgba(240,147,251,0.15)' },
  { id: 3, name: '动漫乐园', icon: '🎌', gradientColors: ['#4facfe', '#00f2fe'], bgColor: 'rgba(79,172,254,0.15)' },
  { id: 4, name: '经典怀旧', icon: '📽️', gradientColors: ['#fa709a', '#fee140'], bgColor: 'rgba(250,112,154,0.15)' },
  { id: 5, name: '游戏之夜', icon: '🎮', gradientColors: ['#a8edea', '#fed6e3'], bgColor: 'rgba(168,237,234,0.15)' },
  { id: 6, name: '静谧时光', icon: '🌙', gradientColors: ['#667eea', '#764ba2'], bgColor: 'rgba(26,26,46,0.12)' }
]

// 最大人数选项
const MAX_MEMBER_OPTIONS: number[] = [4, 6, 8, 12]

@Entry
@Component
struct TheaterPage {
  @State private isScanning: boolean = false
  @State private showCreateDialog: boolean = false
  @State private showQrDialog: boolean = false
  @State private roomName: string = ''
  @State private selectedThemeId: number = 1
  @State private selectedMaxMember: number = 8
  @State private nearbyRooms: Room[] = []
  @State private isServiceReady: boolean = false
  @State private errorMessage: string = ''
  @State private currentRoomInfo: Room | null = null
  @State private showJoinConfirm: boolean = false
  @State private selectedRoom: Room | null = null

  aboutToAppear() {
    this.initService()
    this.loadNearbyRooms()
  }

  // 页面显示时检查是否从扫码页返回并带有结果
  onPageShow(): void {
    const params = router.getParams() as RouterParams
    if (params && params.scanResult) {
      const scanResult: string = params.scanResult
      hilog.info(0, TAG, `Received scan result: ${scanResult}`)
      // 清除参数避免重复触发
      router.replaceUrl({ url: 'pages/theater/TheaterPage' })
      this.handleScanResult(scanResult)
    }
  }

  async initService(): Promise<void> {
    try {
      await RoomManagerService.getInstance().init()
      this.isServiceReady = true
      hilog.info(0, TAG, 'RoomManagerService initialized')
    } catch (err) {
      hilog.error(0, TAG, 'Failed to init service')
      this.errorMessage = '分布式服务初始化失败'
      promptAction.showToast({ message: '分布式服务初始化失败', duration: 2000 })
    }
  }

  async loadNearbyRooms(): Promise<void> {
    this.isScanning = true
    this.errorMessage = ''

    try {
      const rooms: Room[] = await RoomManagerService.getInstance().discoverNearbyRooms()
      this.nearbyRooms = rooms
      hilog.info(0, TAG, `Found ${rooms.length} nearby rooms`)
    } catch (err) {
      hilog.error(0, TAG, 'Failed to discover rooms')
      this.showError('扫描附近房间失败，请重试')
    } finally {
      this.isScanning = false
    }
  }

  async onCreateRoom(): Promise<void> {
    if (!this.roomName.trim()) {
      this.showError('请输入房间名称')
      return
    }

    try {
      const room: Room = await RoomManagerService.getInstance().createRoom(
        this.roomName.trim(),
        this.selectedMaxMember,
        this.selectedThemeId
      )
      hilog.info(0, TAG, `Room created: ${room.roomName}, theme: ${this.selectedThemeId}, max: ${this.selectedMaxMember}`)
      this.showCreateDialog = false
      this.roomName = ''
      this.showQrCodeDialog(room)
    } catch (err) {
      hilog.error(0, TAG, 'Failed to create room')
      this.showError('创建房间失败，请重试')
    }
  }

  showQrCodeDialog(room: Room): void {
    this.currentRoomInfo = room
    this.showQrDialog = true
  }

  private getQrContent(): string {
    if (!this.currentRoomInfo) return ''
    return `movietheater://join?roomId=${this.currentRoomInfo.roomId}&roomName=${encodeURIComponent(this.currentRoomInfo.roomName)}&host=${encodeURIComponent(this.currentRoomInfo.hostName)}`
  }

  private copyRoomId(): void {
    if (!this.currentRoomInfo) return
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.currentRoomInfo.roomId)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '房间号已复制', duration: 1500 })
    } catch (err) {
      hilog.error(0, TAG, 'Copy room id failed')
    }
  }

  private showError(msg: string): void {
    this.errorMessage = msg
    promptAction.showToast({ message: msg, duration: 2000 })
  }

  onJoinRoom(room: Room): void {
    if (room.memberCount >= room.maxMember) {
      this.showError('房间已满，无法加入')
      return
    }
    this.selectedRoom = room
    this.showJoinConfirm = true
  }

  async confirmJoinRoom(): Promise<void> {
    if (!this.selectedRoom) return
    this.showJoinConfirm = false

    try {
      await RoomManagerService.getInstance().joinRoom(this.selectedRoom)
      hilog.info(0, TAG, `Joined room: ${this.selectedRoom.roomName}`)
      this.navigateToRoomDetail(this.selectedRoom)
    } catch (err) {
      hilog.error(0, TAG, 'Failed to join room')
      this.showError('加入房间失败，请重试')
    }
  }

  // 点击扫码加入 - 跳转到独立的扫码识别页
  onScanClick(): void {
    try {
      router.pushUrl({ url: 'pages/theater/ScanQrCodePage' })
    } catch (err) {
      hilog.error(0, TAG, 'Navigate to scan page failed')
      this.showError('无法打开扫码页面')
    }
  }

  // 处理扫码识别结果（由 ScanQrCodePage 返回时调用）
  handleScanResult(result: string): void {
    hilog.info(0, TAG, `Handle scan result: ${result}`)
    if (!result || result.trim().length === 0) {
      this.showError('扫码结果为空，请重新扫码')
      return
    }

    const trimmed: string = result.trim()
    let roomId: string = ''
    let roomName: string = '扫码加入的房间'
    let hostName: string = '房主'

    // 解析标准协议格式: movietheater://join?roomId=xxx&roomName=xxx&host=xxx
    if (trimmed.startsWith('movietheater://join?')) {
      const queryStr: string = trimmed.substring('movietheater://join?'.length)
      const params: string[] = queryStr.split('&')
      for (let i = 0; i < params.length; i++) {
        const kv: string[] = params[i].split('=')
        if (kv.length === 2) {
          const key: string = kv[0]
          const value: string = decodeURIComponent(kv[1])
          if (key === 'roomId') {
            roomId = value
          } else if (key === 'roomName') {
            roomName = value
          } else if (key === 'host') {
            hostName = value
          }
        }
      }
    } else {
      // 兼容纯 roomId 格式
      roomId = trimmed
    }

    if (!roomId) {
      this.showError('无效的二维码格式')
      return
    }

    const room: Room = {
      roomId: roomId,
      roomName: roomName,
      hostId: 'remote_host',
      hostName: hostName,
      memberCount: 1,
      maxMember: 8,
      status: 'waiting',
      createdTime: Date.now(),
      members: []
    }
    this.onJoinRoom(room)
  }

  enterRoomDirectly(): void {
    this.showQrDialog = false
    if (this.currentRoomInfo) {
      this.navigateToRoomDetail(this.currentRoomInfo)
    }
  }

  navigateToRoomDetail(room: Room): void {
    try {
      router.pushUrl({
        url: 'pages/theater/RoomDetailPage',
        params: {
          roomId: room.roomId,
          roomName: room.roomName,
          isHost: RoomManagerService.getInstance().isRoomHost()
        }
      })
    } catch (err) {
      hilog.error(0, TAG, 'Failed to navigate to room detail')
    }
  }

  build() {
    Stack() {
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

      if (this.showCreateDialog) {
        this.CreateRoomDialog()
      }

      if (this.showQrDialog) {
        this.QrCodeDialog()
      }

      if (this.showJoinConfirm) {
        this.JoinConfirmDialog()
      }
    }
    .width('100%')
    .height('100%')
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
      // 创建观影房按钮
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
          .alignItems(HorizontalAlign.Start)
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
        hilog.info(0, TAG, 'Create room button clicked')
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
            .fontColor(room.memberCount >= room.maxMember ? Colors.textTertiary : Colors.textPrimary)

          Row({ space: 8 }) {
            Text('房主: ' + room.hostName)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)

            Text('·')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textTertiary)

            Text(room.memberCount + '/' + room.maxMember + '人')
              .fontSize(FontSizes.helper)
              .fontColor(room.memberCount >= room.maxMember ? Colors.error : Colors.textSecondary)
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row({ space: 8 }) {
          if (room.memberCount >= room.maxMember) {
            Text('已满')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor(Colors.error)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(BorderRadius.small)
          } else if (room.status === 'playing') {
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
    .opacity(room.memberCount >= room.maxMember ? 0.6 : 1)
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
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.closeCreateDialog()
        })

      Column() {
        Row()
          .width(40)
          .height(4)
          .borderRadius(2)
          .backgroundColor('rgba(0,0,0,0.15)')
          .margin({ top: Spacing.md, bottom: Spacing.lg })

        Row() {
          Column() {
            Text('创建观影房')
              .fontSize(FontSizes.largeTitle)
              .fontWeight(FontWeightValue.bold)
              .fontColor(Colors.textPrimary)

            Text('邀请好友一起同步观影，分享美好时光')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
              .margin({ top: Spacing.xs })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
        }
        .width('100%')
        .margin({ bottom: Spacing.xl })

        Column() {
          Text('房间名称')
            .fontSize(FontSizes.caption)
            .fontWeight(FontWeightValue.medium)
            .fontColor(Colors.textPrimary)
            .margin({ bottom: Spacing.sm })

          Row() {
            Text('🎞️')
              .fontSize(18)
              .margin({ right: Spacing.sm })

            TextInput({ placeholder: '给自己的房间起个名字吧', text: this.roomName })
              .layoutWeight(1)
              .fontSize(FontSizes.body)
              .fontColor(Colors.textPrimary)
              .placeholderColor(Colors.textTertiary)
              .onChange((value: string) => {
                this.roomName = value
              })
              .maxLength(20)
          }
          .width('100%')
          .height(52)
          .padding({ left: Spacing.lg, right: Spacing.lg })
          .backgroundColor('#F7F8FA')
          .borderRadius(BorderRadius.large)
        }
        .width('100%')
        .margin({ bottom: Spacing.xl })

        Column() {
          Row() {
            Text('房间主题')
              .fontSize(FontSizes.caption)
              .fontWeight(FontWeightValue.medium)
              .fontColor(Colors.textPrimary)

            Blank()

            Text(this.getCurrentThemeName())
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .width('100%')
          .margin({ bottom: Spacing.md })

          Row({ space: Spacing.md }) {
            ForEach(ROOM_THEMES, (theme: RoomTheme) => {
              Column() {
                Column() {
                  Text(theme.icon)
                    .fontSize(24)
                }
                .width(56)
                .height(56)
                .borderRadius(BorderRadius.large)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(theme.bgColor)
                .border({
                  width: this.selectedThemeId === theme.id ? 2 : 0,
                  color: Colors.primary
                })

                Text(theme.name)
                  .fontSize(FontSizes.helper)
                  .fontColor(this.selectedThemeId === theme.id ? Colors.primary : Colors.textSecondary)
                  .margin({ top: Spacing.xs })
              }
              .onClick(() => {
                this.selectedThemeId = theme.id
              })
            }, (theme: RoomTheme) => theme.id.toString())
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: Spacing.xl })

        Column() {
          Row() {
            Text('最大人数')
              .fontSize(FontSizes.caption)
              .fontWeight(FontWeightValue.medium)
              .fontColor(Colors.textPrimary)

            Blank()

            Text('最多' + this.selectedMaxMember + '人')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textSecondary)
          }
          .width('100%')
          .margin({ bottom: Spacing.md })

          Row({ space: Spacing.md }) {
            ForEach(MAX_MEMBER_OPTIONS, (num: number) => {
              Column() {
                Text(num.toString())
                  .fontSize(FontSizes.body)
                  .fontWeight(this.selectedMaxMember === num ? FontWeightValue.bold : FontWeightValue.medium)
                  .fontColor(this.selectedMaxMember === num ? Color.White : Colors.textPrimary)
              }
              .width(56)
              .height(40)
              .borderRadius(BorderRadius.medium)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.selectedMaxMember === num ? Colors.primary : '#F7F8FA')
              .onClick(() => {
                this.selectedMaxMember = num
              })
            }, (num: number) => num.toString())
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: Spacing.xxl })

        Row() {
          Text('🎉  创建观影房')
            .fontSize(FontSizes.body)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.roomName.trim().length > 0 ? Colors.primary : '#E0E0E0')
        .borderRadius(BorderRadius.button)
        .opacity(this.roomName.trim().length > 0 ? 1 : 0.5)
        .shadow(Shadows.floating)
        .onClick(() => {
          if (this.roomName.trim().length > 0) {
            this.onCreateRoom()
          }
        })

        Row()
          .width('100%')
          .height(20)
      }
      .width('100%')
      .padding({ left: Spacing.xl, right: Spacing.xl })
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 24, topRight: 24 })
    }
    .width('100%')
    .height('100%')
  }

  private getCurrentThemeName(): string {
    for (let i = 0; i < ROOM_THEMES.length; i++) {
      if (ROOM_THEMES[i].id === this.selectedThemeId) {
        return ROOM_THEMES[i].name
      }
    }
    return ''
  }

  private getThemeNameById(themeId: number): string {
    for (let i = 0; i < ROOM_THEMES.length; i++) {
      if (ROOM_THEMES[i].id === themeId) {
        return ROOM_THEMES[i].name
      }
    }
    return '默认主题'
  }

  private closeCreateDialog(): void {
    this.showCreateDialog = false
    this.roomName = ''
    this.selectedThemeId = 1
    this.selectedMaxMember = 8
  }

  @Builder
  QrCodeDialog() {
    if (this.currentRoomInfo) {
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
            .fontSize(FontSizes.largeTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)
            .margin({ bottom: Spacing.xs })

          Text(this.currentRoomInfo.roomName)
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
            .margin({ bottom: Spacing.lg })

          QRCode(this.getQrContent())
            .width(180)
            .height(180)
            .backgroundColor(Color.White)
            .padding(10)
            .borderRadius(BorderRadius.medium)
            .shadow(Shadows.card)

          Row() {
            Text('房间号: ' + this.currentRoomInfo.roomId)
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textTertiary)

            Text('复制')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.primary)
              .margin({ left: Spacing.sm })
              .onClick(() => {
                this.copyRoomId()
              })
          }
          .margin({ top: Spacing.md })

          Row() {
            Column() {
              Text(this.getThemeNameById(this.currentRoomInfo.themeId || 1))
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
            }
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(this.currentRoomInfo.maxMember + '人房')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
            }
            .margin({ left: Spacing.xl })
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text('等待中')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.secondary)
            }
            .margin({ left: Spacing.xl })
            .alignItems(HorizontalAlign.Center)
          }
          .margin({ top: Spacing.md })

          Text('扫码或分享房间号邀请好友加入')
            .fontSize(FontSizes.helper)
            .fontColor(Colors.textTertiary)
            .margin({ top: Spacing.lg })

          Row() {
            Text('进入房间')
              .fontSize(FontSizes.body)
              .fontColor(Color.White)
              .fontWeight(FontWeightValue.medium)
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Colors.primary)
          .borderRadius(BorderRadius.button)
          .margin({ top: Spacing.xl })
          .shadow(Shadows.floating)
          .onClick(() => {
            this.enterRoomDirectly()
          })
        }
        .width('85%')
        .padding(Spacing.xl)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
        .shadow(Shadows.floating)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  JoinConfirmDialog() {
    if (this.selectedRoom) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.showJoinConfirm = false
          })

        Column() {
          Text('加入房间')
            .fontSize(FontSizes.sectionTitle)
            .fontWeight(FontWeightValue.bold)
            .fontColor(Colors.textPrimary)
            .margin({ bottom: Spacing.md })

          Column() {
            Row() {
              Text('房间名称')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
              Blank()
              Text(this.selectedRoom.roomName)
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textPrimary)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            Row() {
              Text('房主')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
              Blank()
              Text(this.selectedRoom.hostName)
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textPrimary)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            Row() {
              Text('人数')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
              Blank()
              Text(this.selectedRoom.memberCount + '/' + this.selectedRoom.maxMember + '人')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textPrimary)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
          }
          .width('100%')
          .padding(Spacing.md)
          .backgroundColor('#F8F9FA')
          .borderRadius(BorderRadius.medium)
          .margin({ bottom: Spacing.xl })

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
                this.showJoinConfirm = false
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
                this.confirmJoinRoom()
              })
          }
          .width('100%')
        }
        .width('80%')
        .padding(Spacing.xl)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
  }
}

export default TheaterPage
