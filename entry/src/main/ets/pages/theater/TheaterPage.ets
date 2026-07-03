import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../../utils/Constants'
import { RoomManagerService, Room } from '../../distributed/RoomManagerService'
import router from '@ohos.router'
import pasteboard from '@ohos.pasteboard'
import promptAction from '@ohos.promptAction'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { MiniSakuraLoading } from '../../components/SakuraLoading'

const TAG = 'TheaterPage'
const SCAN_RESULT_KEY = 'theater_scan_result'

// 房间主题配置
interface RoomTheme {
  id: number
  name: string
  icon: Resource
  gradientColors: string[]
  bgColor: string
}

const ROOM_THEMES: RoomTheme[] = [
  { id: 1, name: '影院之夜', icon: $r('app.media.theme_icon_1'), gradientColors: ['#667eea', '#764ba2'], bgColor: 'rgba(102,126,234,0.15)' },
  { id: 2, name: '温馨小聚', icon: $r('app.media.theme_icon_2'), gradientColors: ['#f093fb', '#f5576c'], bgColor: 'rgba(240,147,251,0.15)' },
  { id: 3, name: '动漫乐园', icon: $r('app.media.theme_icon_3'), gradientColors: ['#4facfe', '#00f2fe'], bgColor: 'rgba(79,172,254,0.15)' },
  { id: 4, name: '经典怀旧', icon: $r('app.media.theme_icon_4'), gradientColors: ['#fa709a', '#fee140'], bgColor: 'rgba(250,112,154,0.15)' },
  { id: 5, name: '游戏之夜', icon: $r('app.media.theme_icon_5'), gradientColors: ['#a8edea', '#fed6e3'], bgColor: 'rgba(168,237,234,0.15)' },
  { id: 6, name: '静谧时光', icon: $r('app.media.theme_icon_6'), gradientColors: ['#667eea', '#764ba2'], bgColor: 'rgba(26,26,46,0.12)' }
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
  @StorageProp(SCAN_RESULT_KEY) @Watch('onScanResultChanged') private scanResult: string = ''
  private roomRefreshTimer: number = -1

  aboutToAppear() {
    this.initService()
    this.loadNearbyRooms()
    this.checkScanResult()
    this.setupNearbyRoomCallback()
    this.startRoomRefreshTimer()
  }

  onPageShow(): void {
    this.checkScanResult()
    this.loadNearbyRooms()
  }

  onPageHide(): void {
    this.stopRoomRefreshTimer()
  }

  aboutToDisappear(): void {
    this.stopRoomRefreshTimer()
  }

  private onScanResultChanged(): void {
    this.checkScanResult()
  }

  private setupNearbyRoomCallback(): void {
    RoomManagerService.getInstance().setOnNearbyRoomUpdateCallback((rooms: Room[]) => {
      hilog.info(0, TAG, `Received nearby rooms update: ${rooms.length} rooms`)
      this.nearbyRooms = rooms
      this.isScanning = false
    })
  }

  private startRoomRefreshTimer(): void {
    this.stopRoomRefreshTimer()
    this.roomRefreshTimer = setInterval(() => {
      this.loadNearbyRooms()
    }, 3000)
  }

  private stopRoomRefreshTimer(): void {
    if (this.roomRefreshTimer !== -1) {
      clearInterval(this.roomRefreshTimer)
      this.roomRefreshTimer = -1
    }
  }

  private async checkScanResult(): Promise<void> {
    if (this.scanResult && this.scanResult.length > 0) {
      hilog.info(0, TAG, `Received scan result from AppStorage: ${this.scanResult}`)
      const result = this.scanResult
      AppStorage.delete(SCAN_RESULT_KEY)
      this.scanResult = ''
      await this.handleScanResult(result)
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
    const roomCode = this.currentRoomInfo.roomCode || ''
    return `movietheater://join?roomId=${this.currentRoomInfo.roomId}&roomCode=${roomCode}&roomName=${encodeURIComponent(this.currentRoomInfo.roomName)}&host=${encodeURIComponent(this.currentRoomInfo.hostName)}`
  }

  private copyRoomCode(): void {
    if (!this.currentRoomInfo || !this.currentRoomInfo.roomCode) return
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.currentRoomInfo.roomCode)
      pasteboard.getSystemPasteboard().setData(data)
      promptAction.showToast({ message: '房间号已复制', duration: 1500 })
    } catch (err) {
      hilog.error(0, TAG, 'Copy room code failed')
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
  async handleScanResult(result: string): Promise<void> {
    hilog.info(0, TAG, `Handle scan result: ${result}`)
    if (!result || result.trim().length === 0) {
      this.showError('扫码结果为空，请重新扫码')
      return
    }

    const trimmed: string = result.trim()
    let roomId: string = ''
    let roomCode: string = ''
    let roomName: string = '扫码加入的房间'
    let hostName: string = '房主'

    // 解析标准协议格式: movietheater://join?roomId=xxx&roomCode=xxx&roomName=xxx&host=xxx
    if (trimmed.startsWith('movietheater://join?')) {
      const queryStr: string = trimmed.substring('movietheater://join?'.length)
      const params: string[] = queryStr.split('&')
      for (let i = 0; i < params.length; i++) {
        const kv: string[] = params[i].split('=')
        if (kv.length >= 2) {
          const key: string = kv[0]
          const value: string = decodeURIComponent(kv[1])
          if (key === 'roomId') {
            roomId = value
          } else if (key === 'roomCode') {
            roomCode = value
          } else if (key === 'roomName') {
            roomName = value
          } else if (key === 'host') {
            hostName = value
          }
        }
      }
    } else if (/^[A-Za-z0-9]{6}$/.test(trimmed)) {
      // 6位字母数字当作房间号
      roomCode = trimmed
    } else {
      // 兼容纯 roomId 格式
      roomId = trimmed
    }

    if (!roomId && !roomCode) {
      this.showError('无效的二维码格式')
      return
    }

    // 优先通过房间号搜索附近真实房间
    if (roomCode) {
      try {
        this.isScanning = true
        const foundRoom = await RoomManagerService.getInstance().findRoomByCode(roomCode)
        this.isScanning = false
        if (foundRoom) {
          this.onJoinRoom(foundRoom)
          return
        }
      } catch (err) {
        this.isScanning = false
        hilog.warn(0, TAG, `Find room by code failed: ${JSON.stringify(err)}`)
      }
    }

    // 未搜索到或仅有 roomId 时，构造房间对象尝试加入
    if (roomId) {
      const room: Room = {
        roomId: roomId,
        roomName: roomName,
        roomCode: roomCode,
        hostId: 'remote_host',
        hostName: hostName,
        memberCount: 1,
        maxMember: 8,
        status: 'waiting',
        createdTime: Date.now(),
        members: []
      }
      this.onJoinRoom(room)
      return
    }

    this.showError('未找到对应房间，请确认房间号正确或房主已开启房间')
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
      // 背景层：低透明度渐变朦胧效果
      this.BackgroundLayer()

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
    .backgroundColor(Colors.background)
  }

  // 背景朦胧渐变层 - 粉蓝梦幻柔和
  @Builder
  BackgroundLayer() {
    Stack() {
      // 粉色渐变层
      Column()
        .width('100%')
        .height(300)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [0x20FFB6C1, 0],
            [0x40FFC0CB, 0.4],
            [0x30FFE4E1, 0.7],
            [0x10FFF0F5, 1]
          ]
        })

      // 浅蓝渐变层（旋转叠加）
      Column()
        .width('100%')
        .height(280)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [0x20B0E0E6, 0],
            [0x30E0F0F5, 0.5],
            [0x20F0F8FF, 1]
          ]
        })
        .rotate({ angle: 12 })
        .position({ x: 30, y: -40 })
    }
    .width('100%')
    .height('100%')
  }

  // 顶部导航栏 - 磨砂毛玻璃效果
  @Builder
  TopBar() {
    Row() {
      Column() {
        Text('观影厅')
          .fontSize(24)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')

        Text('近场分布式同步观影 | 鸿蒙软总线原生能力')
          .fontSize(11)
          .fontColor('#9A9AA3')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row() {
        if (this.isScanning) {
          MiniSakuraLoading()
            .margin({ right: 8 })
        }

        // 历史按钮 - 磨砂圆形
        Stack() {
          Row()
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('rgba(255,240,245,0.7)')
            .backdropBlur(15)

          Text('🕐')
            .fontSize(16)
        }
        .onClick(() => {
          promptAction.showToast({ message: '历史记录开发中', duration: 1500 })
        })
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(Colors.background)
    .backdropBlur(20)
  }

  // 核心操作区：创建房间 + 扫码加入 - 粉蓝渐变柔和风格
  @Builder
  CoreActions() {
    Column({ space: 12 }) {
      // 创建观影房主按钮：粉到浅蓝渐变
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(88)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#FFB6C1', 0], ['#FFC0CB', 0.3], ['#B0E0E6', 0.7], ['#E0F0F5', 1]]
          })
          .borderRadius(20)
          .shadow({ radius: 16, color: 'rgba(255, 182, 193, 0.25)', offsetY: 8 })

        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(44)
              .height(44)
              .borderRadius(22)
              .backgroundColor('rgba(255,255,255,0.3)')
              .backdropBlur(10)

            Text('+')
              .fontSize(28)
              .fontColor('#2D2D3A')
              .fontWeight(FontWeightValue.regular)
          }

          Column() {
            Text('创建观影房')
              .fontSize(18)
              .fontWeight(FontWeightValue.bold)
              .fontColor('#2D2D3A')

            Text('邀请好友一起同步观影')
              .fontSize(12)
              .fontColor('rgba(45,45,58,0.7)')
              .margin({ top: 2 })
          }
          .margin({ left: 14 })
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .height(88)
      .onClick(() => {
        hilog.info(0, TAG, 'Create room button clicked')
        this.showCreateDialog = true
      })

      // 扫码加入：磨砂半透明卡片+粉蓝渐变描边
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(76)
          .backgroundColor('rgba(255,240,245,0.6)')
          .backdropBlur(25)
          .borderRadius(20)
          .border({ width: 1.5, color: 'rgba(255,182,193,0.5)' })
          .shadow({ radius: 10, color: 'rgba(176,224,230,0.15)', offsetY: 4 })

        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(40)
              .height(40)
              .borderRadius(20)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['rgba(255,182,193,0.3)', 0], ['rgba(176,224,230,0.3)', 1]]
              })

            Image($r('app.media.xiangji'))
              .width(20)
              .height(20)
          }

          Column() {
            Text('扫码加入房间')
              .fontSize(16)
              .fontWeight(FontWeightValue.semibold)
              .fontColor('#2D2D3A')

            Text('扫描二维码快速加入')
              .fontSize(12)
              .fontColor('#9A9AA3')
              .margin({ top: 2 })
          }
          .margin({ left: 14 })
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('›')
            .fontSize(20)
            .fontColor('#C8C8D0')
        }
        .padding({ left: 24, right: 20 })
      }
      .width('100%')
      .height(76)
      .onClick(() => {
        this.onScanClick()
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16 })
  }

  // 错误提示 - 柔和粉色风格
  @Builder
  ErrorTip() {
    Row() {
      Text('⚠️')
        .fontSize(14)

      Text(this.errorMessage)
        .fontSize(12)
        .fontColor('#E8A0B0')
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('rgba(255,240,245,0.8)')
    .borderRadius(16)
    .margin({ left: 20, right: 20, top: 12 })
  }

  // 附近房间模块 - 粉蓝柔和风格
  @Builder
  NearbyRooms() {
    Column() {
      // 标题栏
      Row() {
        Row({ space: 10 }) {
          // 粉蓝渐变环形图标
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(22)
              .height(22)
              .borderRadius(11)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
              })

            Row()
              .width(10)
              .height(10)
              .borderRadius(5)
              .backgroundColor('#FFF0F5')
          }

          Text('附近房间')
            .fontSize(18)
            .fontWeight(FontWeightValue.semibold)
            .fontColor('#2D2D3A')
        }

        Blank()

        Row({ space: 10 }) {
          Text(this.isScanning ? '扫描中...' : `${this.nearbyRooms.length}个在线`)
            .fontSize(12)
            .fontColor('#9A9AA3')

          if (this.isScanning) {
            MiniSakuraLoading()
          } else {
            Image($r('app.media.shuaxin'))
              .width(14)
              .height(14)
              .onClick(() => {
                this.loadNearbyRooms()
              })
          }
        }
      }
      .width('100%')
      .margin({ bottom: 14 })

      // 房间列表 or 空状态
      if (this.nearbyRooms.length === 0) {
        this.EmptyRoomTip()
      } else {
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.nearbyRooms, (room: Room) => {
              this.RoomCard(room)
            }, (room: Room) => room.roomId)
          }
          .padding({ right: 4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 28 })
  }

  // 空状态：简约梦幻柔和风格
  @Builder
  EmptyRoomTip() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 粉蓝渐变圆形底
        Row()
          .width(72)
          .height(72)
          .borderRadius(36)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['rgba(255,182,193,0.25)', 0], ['rgba(176,224,230,0.25)', 1]]
          })

        // 简约线性插画
        Column() {
          Row()
            .width(32)
            .height(20)
            .borderRadius(10)
            .border({ width: 1.5, color: '#E8D0D8' })

          Row()
            .width(20)
            .height(12)
            .borderRadius(6)
            .border({ width: 1.5, color: '#D8E0E8' })
            .margin({ top: 4 })
        }
      }

      Text(this.isScanning ? '正在扫描附近房间...' : '暂无附近房间')
        .fontSize(14)
        .fontColor('#7A7A88')
        .fontWeight(FontWeightValue.medium)
        .margin({ top: 14 })

      Text(this.isScanning ? '请确保设备已开启蓝牙和WLAN' : '创建一个房间，邀请好友加入吧')
        .fontSize(12)
        .fontColor('#B8B8C0')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(170)
    .backgroundColor('rgba(255,240,245,0.5)')
    .backdropBlur(20)
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 12, color: 'rgba(255,182,193,0.1)', offsetY: 4 })
  }

  // 房间卡片（横向滚动卡片）- 磨砂半透明风格
  @Builder
  RoomCard(room: Room) {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(40)
            .height(40)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
            })

          Text(room.hostName.substring(0, 1))
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.bold)
        }

        Column() {
          Text(room.roomName)
            .fontSize(14)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(room.memberCount >= room.maxMember ? '#B8B8C0' : '#2D2D3A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(room.memberCount + '/' + room.maxMember + '人')
            .fontSize(11)
            .fontColor(room.memberCount >= room.maxMember ? '#C8C8D0' : '#9A9AA3')
            .margin({ top: 2 })
        }
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 状态标签 - 粉蓝柔和
        if (room.memberCount >= room.maxMember) {
          Text('已满')
            .fontSize(10)
            .fontColor(Color.White)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#E8A0B0', 0], ['#B0E0E6', 1]]
            })
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(8)
        } else if (room.status === 'playing') {
          Text('播放中')
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor('#B0E0E6')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(8)
        } else {
          Text('等待中')
            .fontSize(10)
            .fontColor('#FFB6C1')
            .backgroundColor('rgba(255,182,193,0.15)')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(8)
        }
      }
      .width('100%')
    }
    .width(170)
    .padding(14)
    .backgroundColor('rgba(255,240,245,0.6)')
    .backdropBlur(15)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(255,182,193,0.3)' })
    .shadow({ radius: 10, color: 'rgba(176,224,230,0.1)', offsetY: 4 })
    .opacity(room.memberCount >= room.maxMember ? 0.6 : 1)
    .onClick(() => {
      this.onJoinRoom(room)
    })
  }

  // 观影厅核心优势 - 柔和浪漫风格
  @Builder
  UsageTips() {
    Column() {
      Row() {
        Text('观影厅核心优势')
          .fontSize(18)
          .fontWeight(FontWeightValue.bold)
          .fontColor('#2D2D3A')
      }
      .width('100%')
      .margin({ bottom: 14 })

      Row({ space: 10 }) {
        this.AdvantageCard($r('app.media.1'), '无需流量', '近场直连', 'rgba(255,182,193,0.2)', '#FFB6C1')
        this.AdvantageCard($r('app.media.2'), '一碰建组', '鸿蒙设备', 'rgba(176,224,230,0.2)', '#B0E0E6')
        this.AdvantageCard($r('app.media.3'), '同步播放', '进度一致', 'rgba(255,192,203,0.15)', '#FFC0CB')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 28 })
  }

  // 优势卡片 - 磨砂半透明柔和风格
  @Builder
  AdvantageCard(icon: string | Resource, title: string, subtitle: string, bgColor: string, accentColor: string) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(44)
          .height(44)
          .borderRadius(22)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[bgColor, 0], [accentColor, 1]]
          })
          .backdropBlur(10)

        Image(icon)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
      }

      Text(title)
        .fontSize(13)
        .fontWeight(FontWeightValue.semibold)
        .fontColor('#2D2D3A')
        .margin({ top: 10 })

      Text(subtitle)
        .fontSize(11)
        .fontColor('#9A9AA3')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor('rgba(255,240,245,0.6)')
    .backdropBlur(20)
    .borderRadius(20)
    .border({ width: 1, color: 'rgba(255,182,193,0.25)' })
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 8, color: 'rgba(255,182,193,0.08)', offsetY: 3 })
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
                  Image(theme.icon)
                    .width(28)
                    .height(28)
                    .objectFit(ImageFit.Contain)
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
            Text('房间号: ' + (this.currentRoomInfo.roomCode || this.currentRoomInfo.roomId))
              .fontSize(FontSizes.helper)
              .fontColor(Colors.textTertiary)

            Text('复制')
              .fontSize(FontSizes.helper)
              .fontColor(Colors.primary)
              .margin({ left: Spacing.sm })
              .onClick(() => {
                this.copyRoomCode()
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
