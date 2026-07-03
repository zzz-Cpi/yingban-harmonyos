import { Colors, Spacing, BorderRadius, Shadows, FontSizes, FontWeightValue } from '../../utils/Constants'
import { RoomManagerService, Room, RoomMember } from '../../distributed/RoomManagerService'
import { PlayerState, ChatMessageSync } from '../../distributed/DataSyncService'
import router from '@ohos.router'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'RoomDetailPage'

interface RouteParams {
  roomId?: string
  roomName?: string
  isHost?: boolean
}

interface PreparedEvent {
  duration: number
}

interface UpdateEvent {
  time: number
}

interface MemberItem {
  id: string
  name: string
  avatar: string
  isHost: boolean
  isOnline: boolean
}

interface DanmakuItem {
  id: string
  content: string
  userName: string
  top: number
  color: string
  speed: number
}

@Entry
@Component
struct RoomDetailPage {
  @State private roomId: string = ''
  @State private roomName: string = ''
  @State private isHost: boolean = false
  @State private currentRoom: Room | null = null
  @State private members: MemberItem[] = []
  @State private chatMessages: ChatMessageSync[] = []
  @State private chatInput: string = ''
  @State private isPlaying: boolean = false
  @State private currentPosition: number = 0
  @State private duration: number = 0
  @State private playbackSpeed: number = 1
  @State private showMemberList: boolean = false
  @State private showMoreMenu: boolean = false
  @State private showLeaveConfirm: boolean = false
  @State private showMoviePicker: boolean = false
  @State private danmakuList: DanmakuItem[] = []
  @State private showDanmaku: boolean = true
  private videoController: VideoController = new VideoController()

  private readonly TEST_VIDEO_URL: string = 'https://www.w3schools.com/html/mov_bbb.mp4'
  private danmakuColors: string[] = ['#FFFFFF', '#FFD700', '#00FF7F', '#FF6B6B', '#4ECDC4', '#A8E6CF']

  aboutToAppear() {
    this.initPage()
    this.setupRoomCallbacks()
  }

  private initPage(): void {
    const params = router.getParams() as RouteParams
    if (params) {
      this.roomId = params.roomId || ''
      this.roomName = params.roomName || '观影房'
      this.isHost = params.isHost || false
    }

    this.currentRoom = RoomManagerService.getInstance().getCurrentRoom()
    if (this.currentRoom) {
      const roomMembers: RoomMember[] = this.currentRoom.members
      if (roomMembers && roomMembers.length > 0) {
        const list: MemberItem[] = []
        for (let i = 0; i < roomMembers.length; i++) {
          const m: RoomMember = roomMembers[i]
          list.push({
            id: m.userId,
            name: m.userName,
            avatar: '',
            isHost: m.isHost,
            isOnline: m.isOnline
          })
        }
        this.members = list
      }
    }

    if (this.members.length === 0) {
      this.members.push({
        id: 'local_user',
        name: '我',
        avatar: '',
        isHost: this.isHost,
        isOnline: true
      })
    }
  }

  private setupRoomCallbacks(): void {
    const roomMgr = RoomManagerService.getInstance()

    roomMgr.setOnPlayerStateChangeCallback((state: PlayerState) => {
      hilog.info(0, TAG, `Player state changed: ${state.action}`)
      this.handleRemotePlayerState(state)
    })

    roomMgr.setOnChatMessageCallback((message: ChatMessageSync) => {
      hilog.info(0, TAG, `Chat message received: ${message.content}`)
      if (this.isMessageDuplicate(message.id)) {
        hilog.info(0, TAG, `Duplicate message skipped: ${message.id}`)
        return
      }
      this.chatMessages.push(message)
      this.markMessageReceived(message.id)
      if (message.type !== 'system' && message.userId !== this.getLocalUserId()) {
        this.addDanmaku(message.content, message.userName)
      }
    })

    roomMgr.setOnMemberJoinCallback((member: RoomMember) => {
      hilog.info(0, TAG, `Member joined: ${member.userName}`)
      if (!this.members.find((m: MemberItem) => m.id === member.userId)) {
        const newMember: MemberItem = {
          id: member.userId,
          name: member.userName,
          avatar: '',
          isHost: member.isHost,
          isOnline: member.isOnline
        }
        this.members.push(newMember)
      }
    })

    roomMgr.setOnMemberLeaveCallback((userId: string) => {
      hilog.info(0, TAG, `Member left: ${userId}`)
      this.members = this.members.filter((m: MemberItem) => m.id !== userId)
    })
  }

  private receivedMessageIds: Set<string> = new Set()

  private isMessageDuplicate(msgId: string): boolean {
    return this.receivedMessageIds.has(msgId)
  }

  private markMessageReceived(msgId: string): void {
    this.receivedMessageIds.add(msgId)
    if (this.receivedMessageIds.size > 500) {
      this.receivedMessageIds.clear()
    }
  }

  private getLocalUserId(): string {
    const room = RoomManagerService.getInstance().getCurrentRoom()
    if (room && room.members && room.members.length > 0) {
      for (let i = 0; i < room.members.length; i++) {
        if (room.members[i].userId && room.members[i].userId !== 'local_user') {
          return room.members[i].userId
        }
      }
    }
    return 'local_user'
  }

  private handleRemotePlayerState(state: PlayerState): void {
    switch (state.action) {
      case 'play':
        this.isPlaying = true
        this.videoController.start()
        break
      case 'pause':
        this.isPlaying = false
        this.videoController.pause()
        if (state.position > 0) {
          this.videoController.setCurrentTime(state.position)
        }
        break
      case 'seek':
        this.videoController.setCurrentTime(state.position)
        break
      case 'speed':
        this.playbackSpeed = state.speed
        break
    }
  }

  async onPlayClick(): Promise<void> {
    if (this.isHost) {
      this.isPlaying = !this.isPlaying
      if (this.isPlaying) {
        this.videoController.start()
        await RoomManagerService.getInstance().startPlaying()
      } else {
        this.videoController.pause()
        await RoomManagerService.getInstance().pausePlaying(this.currentPosition)
      }
    }
  }

  async onSeek(position: number): Promise<void> {
    if (this.isHost) {
      this.currentPosition = position
      await RoomManagerService.getInstance().seekTo(position)
    }
  }

  async onSendChat(): Promise<void> {
    if (!this.chatInput.trim()) return

    const content: string = this.chatInput.trim()
    this.addDanmaku(content, '我', '#FFD700')

    const localMsg: ChatMessageSync = {
      id: 'msg_local_' + Date.now(),
      userId: this.getLocalUserId(),
      userName: '我',
      content: content,
      timestamp: Date.now(),
      type: 'chat'
    }
    this.chatMessages.push(localMsg)
    this.markMessageReceived(localMsg.id)

    try {
      await RoomManagerService.getInstance().sendChatMessage(content)
      this.chatInput = ''
    } catch (err) {
      hilog.error(0, TAG, `Failed to send message: ${JSON.stringify(err)}`)
    }
  }

  private addDanmaku(content: string, userName: string, color?: string): void {
    if (!this.showDanmaku) return
    const danmaku: DanmakuItem = {
      id: 'danmaku_' + Date.now() + '_' + Math.random(),
      content: content,
      userName: userName,
      top: Math.random() * 140 + 10,
      color: color || this.danmakuColors[Math.floor(Math.random() * this.danmakuColors.length)],
      speed: 8 + Math.random() * 6
    }
    this.danmakuList.push(danmaku)

    setTimeout(() => {
      this.danmakuList = this.danmakuList.filter((d: DanmakuItem) => d.id !== danmaku.id)
    }, 8000)
  }

  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  private formatMessageTime(timestamp: number): string {
    const date = new Date(timestamp)
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  }

  onBackClick(): void {
    this.showLeaveConfirm = true
  }

  async confirmLeaveRoom(): Promise<void> {
    this.showLeaveConfirm = false
    try {
      await RoomManagerService.getInstance().leaveRoom()
      router.back()
    } catch (err) {
      hilog.error(0, TAG, `Failed to leave room: ${JSON.stringify(err)}`)
    }
  }

  build() {
    Stack() {
      Column() {
        this.TopBar()
        this.VideoPlayer()
        this.PlayerControls()
        this.ChatArea()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.darkBackground)

      if (this.showMemberList) {
        this.MemberListPanel()
      }

      if (this.showMoreMenu) {
        this.MoreMenu()
      }

      if (this.showLeaveConfirm) {
        this.LeaveConfirmDialog()
      }

      if (this.showMoviePicker) {
        this.MoviePickerDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopBar() {
    Row() {
      Row({ space: 12 }) {
        Text('‹')
          .fontSize(24)
          .fontColor(Color.White)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBackClick()
          })

        Column() {
          Text(this.roomName)
            .fontSize(FontSizes.body)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Color.White)

          Text(`${this.members.length}人在线`)
            .fontSize(FontSizes.helper)
            .fontColor('rgba(255,255,255,0.6)')
        }
        .alignItems(HorizontalAlign.Start)
      }

      Blank()

      Row({ space: 16 }) {
        Text('👥')
          .fontSize(20)
          .onClick(() => {
            this.showMemberList = !this.showMemberList
            this.showMoreMenu = false
          })

        Text('⋯')
          .fontSize(20)
          .fontColor(Color.White)
          .onClick(() => {
            this.showMoreMenu = !this.showMoreMenu
            this.showMemberList = false
          })
      }
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.md })
    .backgroundColor('rgba(0,0,0,0.3)')
  }

  @Builder
  VideoPlayer() {
    Stack({ alignContent: Alignment.Center }) {
      Video({
        src: this.TEST_VIDEO_URL,
        controller: this.videoController
      })
        .width('100%')
        .height('100%')
        .autoPlay(false)
        .muted(false)
        .onPrepared((event: PreparedEvent) => {
          if (event && event.duration) {
            this.duration = event.duration
          }
          hilog.info(0, TAG, 'Video prepared')
        })
        .onUpdate((event: UpdateEvent) => {
          if (event && event.time) {
            this.currentPosition = event.time
          }
        })
        .onFinish(() => {
          this.isPlaying = false
          hilog.info(0, TAG, 'Video finished')
        })
        .onError(() => {
          hilog.error(0, TAG, 'Video error')
        })

      if (this.showDanmaku && this.danmakuList.length > 0) {
        Stack() {
          ForEach(this.danmakuList, (danmaku: DanmakuItem) => {
            Text(danmaku.content)
              .fontSize(14)
              .fontColor(danmaku.color)
              .fontWeight(FontWeightValue.medium)
              .textShadow({ radius: 2, color: 'rgba(0,0,0,0.8)' })
              .position({ x: '100%', y: danmaku.top })
              .margin({ right: -200 })
              .animation({
                duration: 8000,
                tempo: danmaku.speed / 10,
                curve: Curve.Linear,
                iterations: 1,
                playMode: PlayMode.Normal
              })
          }, (danmaku: DanmakuItem) => danmaku.id)
        }
        .width('100%')
        .height('100%')
      }

      if (!this.isPlaying) {
        Column() {
          Text(this.isHost ? '点击播放' : '等待房主播放...')
            .fontSize(FontSizes.body)
            .fontColor(Color.White)
            .margin({ top: Spacing.md })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onPlayClick()
        })
      }
    }
    .width('100%')
    .height(220)
    .backgroundColor(Color.Black)
  }

  @Builder
  PlayerControls() {
    Column() {
      Row({ space: Spacing.sm }) {
        Text(this.formatTime(this.currentPosition))
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.7)')

        Slider({
          value: this.currentPosition,
          min: 0,
          max: this.duration > 0 ? this.duration : 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .layoutWeight(1)
          .blockColor(Colors.primary)
          .trackColor('rgba(255,255,255,0.2)')
          .selectedColor(Colors.primary)
          .onChange((value: number) => {
            this.onSeek(value)
          })

        Text(this.formatTime(this.duration))
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.7)')
      }
      .width('100%')
      .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.sm })

      Row({ space: Spacing.xl }) {
        Text(this.isPlaying ? '⏸' : '▶️')
          .fontSize(24)
          .onClick(() => {
            this.onPlayClick()
          })

        Text('⏮')
          .fontSize(20)
          .onClick(() => {
            if (this.isHost) {
              const newPos = Math.max(0, this.currentPosition - 10)
              this.onSeek(newPos)
            }
          })

        Text('⏭')
          .fontSize(20)
          .onClick(() => {
            if (this.isHost) {
              const newPos = Math.min(this.duration, this.currentPosition + 10)
              this.onSeek(newPos)
            }
          })

        Blank()

        Text(this.showDanmaku ? '弹' : '闭')
          .fontSize(12)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.showDanmaku ? Colors.primary : 'rgba(255,255,255,0.2)')
          .borderRadius(4)
          .onClick(() => {
            this.showDanmaku = !this.showDanmaku
          })

        Text(`${this.playbackSpeed}x`)
          .fontSize(12)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(255,255,255,0.2)')
          .borderRadius(4)
          .onClick(() => {
            if (this.isHost) {
              const speeds = [0.5, 1, 1.25, 1.5, 2]
              const idx = speeds.indexOf(this.playbackSpeed)
              const nextIdx = (idx + 1) % speeds.length
              this.playbackSpeed = speeds[nextIdx]
              RoomManagerService.getInstance().setPlaybackSpeed(this.playbackSpeed)
            }
          })

        Text('🔊')
          .fontSize(20)

        Text('⛶')
          .fontSize(20)
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, bottom: Spacing.md })
    }
    .width('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
  }

  @Builder
  ChatArea() {
    Column() {
      List() {
        ForEach(this.chatMessages, (msg: ChatMessageSync) => {
          ListItem() {
            if (msg.type === 'system') {
              this.SystemMessage(msg)
            } else {
              this.ChatMessageItem(msg)
            }
          }
        }, (msg: ChatMessageSync) => msg.id)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.md })

      Row({ space: Spacing.sm }) {
        TextInput({ placeholder: '发个弹幕...', text: this.chatInput })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#2A2A2A')
          .borderRadius(20)
          .fontColor(Color.White)
          .placeholderColor('rgba(255,255,255,0.4)')
          .padding({ left: Spacing.lg, right: Spacing.lg })
          .onChange((value: string) => {
            this.chatInput = value
          })
          .onSubmit(() => {
            this.onSendChat()
          })

        Text('发送')
          .fontSize(FontSizes.caption)
          .fontColor(Color.White)
          .padding({ left: Spacing.lg, right: Spacing.lg, top: 10, bottom: 10 })
          .backgroundColor(Colors.primary)
          .borderRadius(20)
          .onClick(() => {
            this.onSendChat()
          })
      }
      .width('100%')
      .padding({ left: Spacing.md, right: Spacing.md, top: Spacing.sm, bottom: Spacing.lg })
      .backgroundColor('#1A1A1A')
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#121212')
  }

  @Builder
  ChatMessageItem(msg: ChatMessageSync) {
    Column() {
      Row({ space: 8 }) {
        Text(msg.userName)
          .fontSize(10)
          .fontColor(msg.userId === 'local_user' ? Colors.primary : Colors.secondary)

        Text(this.formatMessageTime(msg.timestamp))
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.3)')
      }
      .width('100%')

      Text(msg.content)
        .fontSize(FontSizes.caption)
        .fontColor('rgba(255,255,255,0.85)')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ bottom: Spacing.md })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SystemMessage(msg: ChatMessageSync) {
    Row() {
      Text(msg.content)
        .fontSize(FontSizes.helper)
        .fontColor('rgba(255,255,255,0.4)')
        .padding({ left: Spacing.md, right: Spacing.md, top: 6, bottom: 6 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(12)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Spacing.sm, bottom: Spacing.sm })
  }

  @Builder
  MemberListPanel() {
    if (this.showMemberList) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.showMemberList = false
          })

        Column() {
          Row() {
            Text(`在线成员 (${this.members.length})`)
              .fontSize(FontSizes.body)
              .fontWeight(FontWeightValue.semibold)
              .fontColor(Colors.textPrimary)

            Blank()

            Text('✕')
              .fontSize(18)
              .fontColor(Colors.textSecondary)
              .onClick(() => {
                this.showMemberList = false
              })
          }
          .width('100%')
          .padding({ bottom: Spacing.md })

          List() {
            ForEach(this.members, (member: MemberItem) => {
              ListItem() {
                Row({ space: Spacing.md }) {
                  Text(member.isHost ? '👑' : '👤')
                    .fontSize(24)

                  Column() {
                    Text(member.name)
                      .fontSize(FontSizes.body)
                      .fontColor(Colors.textPrimary)

                    if (member.isHost) {
                      Text('房主')
                        .fontSize(10)
                        .fontColor(Colors.primary)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor('rgba(255,107,107,0.1)')
                        .borderRadius(4)
                    }
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Text(member.isOnline ? '在线' : '离线')
                    .fontSize(FontSizes.helper)
                    .fontColor(member.isOnline ? Colors.success : Colors.textTertiary)
                }
                .width('100%')
                .padding({ top: Spacing.sm, bottom: Spacing.sm })
              }
            }, (member: MemberItem) => member.id)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('75%')
        .height('100%')
        .backgroundColor(Color.White)
        .padding(Spacing.lg)
        .borderRadius({ topLeft: BorderRadius.large, topRight: 0, bottomLeft: BorderRadius.large, bottomRight: 0 })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .backgroundColor('rgba(0,0,0,0.5)')
    }
  }

  @Builder
  MoreMenu() {
    if (this.showMoreMenu) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.showMoreMenu = false
          })

        Column({ space: 0 }) {
          this.MenuItem('🔄', '刷新房间')
          this.MenuItem('📋', '房间信息')
          if (this.isHost) {
            this.MenuItem('🎬', '选择影片')
            this.MenuItem('👑', '移交房主')
          }
          this.MenuItem('🚪', '退出房间', Colors.error)
        }
        .width(160)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.medium)
        .shadow(Shadows.floating)
        .margin({ top: 56, right: Spacing.md })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  @Builder
  MenuItem(icon: string, title: string, color?: string) {
    Row({ space: Spacing.md }) {
      Text(icon)
        .fontSize(16)

      Text(title)
        .fontSize(FontSizes.caption)
        .fontColor(color || Colors.textPrimary)
    }
    .width('100%')
    .height(44)
    .padding({ left: Spacing.lg, right: Spacing.lg })
    .onClick(() => {
      this.showMoreMenu = false
      if (title === '退出房间') {
        this.showLeaveConfirm = true
      } else if (title === '选择影片') {
        this.showMoviePicker = true
      }
    })
  }

  @Builder
  LeaveConfirmDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showLeaveConfirm = false
        })

      Column() {
        Text('退出房间')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .margin({ bottom: Spacing.md })

        Text('确定要退出当前观影房吗？')
          .fontSize(FontSizes.body)
          .fontColor(Colors.textSecondary)
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
              this.showLeaveConfirm = false
            })

          Text('确定退出')
            .fontSize(FontSizes.body)
            .fontColor(Color.White)
            .fontWeight(FontWeightValue.medium)
            .layoutWeight(1)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor(Colors.error)
            .borderRadius(BorderRadius.medium)
            .onClick(() => {
              this.confirmLeaveRoom()
            })
        }
        .width('100%')
      }
      .width('75%')
      .padding(Spacing.xl)
      .backgroundColor(Color.White)
      .borderRadius(BorderRadius.large)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MoviePickerDialog() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showMoviePicker = false
        })

      Column() {
        Row()
          .width(40)
          .height(4)
          .borderRadius(2)
          .backgroundColor('rgba(0,0,0,0.15)')
          .margin({ top: Spacing.md, bottom: Spacing.lg })

        Text('选择影片')
          .fontSize(FontSizes.sectionTitle)
          .fontWeight(FontWeightValue.bold)
          .fontColor(Colors.textPrimary)
          .margin({ bottom: Spacing.lg })

        Column() {
          this.MovieOptionItem('🎬', 'Big Buck Bunny', '经典测试影片', this.TEST_VIDEO_URL)
          this.MovieOptionItem('🎥', '示例影片2', '待添加', '')
          this.MovieOptionItem('📺', '示例影片3', '待添加', '')
        }
        .width('100%')

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

  @Builder
  MovieOptionItem(icon: string, title: string, desc: string, url: string) {
    Row() {
      Text(icon)
        .fontSize(28)

      Column() {
        Text(title)
          .fontSize(FontSizes.body)
          .fontWeight(FontWeightValue.medium)
          .fontColor(Colors.textPrimary)

        Text(desc)
          .fontSize(FontSizes.helper)
          .fontColor(Colors.textSecondary)
          .margin({ top: 2 })
      }
      .margin({ left: Spacing.md })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('选择')
        .fontSize(FontSizes.caption)
        .fontColor(Colors.primary)
        .padding({ left: Spacing.md, right: Spacing.md, top: 6, bottom: 6 })
        .border({ width: 1, color: Colors.primary })
        .borderRadius(BorderRadius.small)
        .onClick(() => {
          if (url) {
            hilog.info(0, TAG, `Selected movie: ${title}`)
            this.showMoviePicker = false
          }
        })
    }
    .width('100%')
    .padding({ top: Spacing.md, bottom: Spacing.md })
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}

export default RoomDetailPage
