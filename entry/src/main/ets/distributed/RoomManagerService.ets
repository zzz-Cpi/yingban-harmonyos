import { DeviceManagerService, DeviceInfo } from './DeviceManagerService'
import { DataSyncService, PlayerState, ChatMessageSync, RoomMemberSync } from './DataSyncService'
import { DistributedConstants } from './DistributedConstants'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'RoomManagerService'

export interface Room {
  roomId: string
  roomName: string
  hostId: string
  hostName: string
  memberCount: number
  maxMember: number
  themeId?: number
  status: string
  movieTitle?: string
  moviePoster?: string
  movieUrl?: string
  createdTime: number
  members: RoomMember[]
}

export interface RoomMember {
  userId: string
  userName: string
  isHost: boolean
  isOnline: boolean
  deviceId?: string
}

export class RoomManagerService {
  private static instance: RoomManagerService | null = null
  private currentRoom: Room | null = null
  private isHost: boolean = false
  private localUserId: string = 'local_user'
  private localUserName: string = '我'

  private onRoomCreatedCallback: (room: Room) => void = () => {}
  private onRoomJoinedCallback: (room: Room) => void = () => {}
  private onMemberJoinCallback: (member: RoomMember) => void = () => {}
  private onMemberLeaveCallback: (userId: string) => void = () => {}
  private onPlayerStateChangeCallback: (state: PlayerState) => void = () => {}
  private onChatMessageCallback: (message: ChatMessageSync) => void = () => {}

  private constructor() {}

  static getInstance(): RoomManagerService {
    if (!RoomManagerService.instance) {
      RoomManagerService.instance = new RoomManagerService()
    }
    return RoomManagerService.instance
  }

  async init(): Promise<void> {
    try {
      await DeviceManagerService.getInstance().init()
      await DataSyncService.getInstance().init()

      this.setupDataSyncCallbacks()
      this.setupDeviceManagerCallbacks()

      hilog.info(0, TAG, 'RoomManagerService initialized')
    } catch (err) {
      hilog.error(0, TAG, `Failed to init RoomManagerService: ${JSON.stringify(err)}`)
      throw err as Error
    }
  }

  private setupDataSyncCallbacks(): void {
    const dataSync = DataSyncService.getInstance()

    dataSync.setOnPlayerStateChangeCallback((state: PlayerState) => {
      if (this.currentRoom && state.hostId === this.currentRoom.hostId) {
        if (this.onPlayerStateChangeCallback) {
          this.onPlayerStateChangeCallback(state)
        }
      }
    })

    dataSync.setOnChatMessageCallback((message: ChatMessageSync) => {
      if (this.onChatMessageCallback) {
        this.onChatMessageCallback(message)
      }
    })
  }

  private setupDeviceManagerCallbacks(): void {
    const deviceMgr = DeviceManagerService.getInstance()

    deviceMgr.setOnDeviceOnlineCallback((device: DeviceInfo) => {
      hilog.info(0, TAG, `Device online: ${device.deviceName}`)
    })

    deviceMgr.setOnDeviceOfflineCallback((device: DeviceInfo) => {
      hilog.info(0, TAG, `Device offline: ${device.deviceName}`)
    })
  }

  async createRoom(roomName: string, maxMember?: number, themeId?: number, movieTitle?: string, moviePoster?: string, movieUrl?: string): Promise<Room> {
    const roomId = 'room_' + Date.now()
    const hostId = this.localUserId
    const now = Date.now()

    const hostMember: RoomMember = {
      userId: this.localUserId,
      userName: this.localUserName,
      isHost: true,
      isOnline: true
    }

    const room: Room = {
      roomId: roomId,
      roomName: roomName,
      hostId: hostId,
      hostName: this.localUserName,
      memberCount: 1,
      maxMember: maxMember || 8,
      themeId: themeId || 1,
      status: DistributedConstants.ROOM_STATUS_WAITING,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      movieUrl: movieUrl,
      createdTime: now,
      members: [hostMember]
    }

    this.currentRoom = room
    this.isHost = true

    const roomSync: RoomMemberSync = {
      roomId: roomId,
      roomName: roomName,
      hostId: hostId,
      hostName: this.localUserName,
      memberCount: 1,
      maxMember: maxMember || 8,
      status: DistributedConstants.ROOM_STATUS_WAITING,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      createdTime: now
    }

    try {
      await DataSyncService.getInstance().updateRoomInfo(roomSync)
      hilog.info(0, TAG, `Room created: ${roomName}`)

      if (this.onRoomCreatedCallback) {
        this.onRoomCreatedCallback(room)
      }

      return room
    } catch (err) {
      hilog.error(0, TAG, `Failed to create room: ${JSON.stringify(err)}`)
      throw err as Error
    }
  }

  async joinRoom(room: Room): Promise<void> {
    this.currentRoom = room
    this.isHost = false

    const member: RoomMember = {
      userId: this.localUserId,
      userName: this.localUserName,
      isHost: false,
      isOnline: true
    }

    if (this.currentRoom) {
      const existingMember = this.currentRoom.members.find((m: RoomMember) => m.userId === this.localUserId)
      if (!existingMember) {
        this.currentRoom.members.push(member)
        this.currentRoom.memberCount = this.currentRoom.members.length
      }
    }

    hilog.info(0, TAG, `Joined room: ${room.roomName}`)

    if (this.onRoomJoinedCallback && this.currentRoom) {
      this.onRoomJoinedCallback(this.currentRoom)
    }

    await this.sendSystemMessage(`${this.localUserName} 加入了房间`)
  }

  async leaveRoom(): Promise<void> {
    if (this.currentRoom) {
      await this.sendSystemMessage(`${this.localUserName} 离开了房间`)
      hilog.info(0, TAG, `Left room: ${this.currentRoom.roomName}`)
    }

    this.currentRoom = null
    this.isHost = false
  }

  async startPlaying(): Promise<void> {
    if (!this.currentRoom || !this.isHost) return

    this.currentRoom.status = DistributedConstants.ROOM_STATUS_PLAYING

    const state: PlayerState = {
      action: DistributedConstants.PLAYER_ACTION_PLAY,
      position: 0,
      speed: 1,
      timestamp: Date.now(),
      hostId: this.currentRoom.hostId
    }

    await DataSyncService.getInstance().updatePlayerState(state)
    hilog.info(0, TAG, 'Started playing')
  }

  async pausePlaying(position: number): Promise<void> {
    if (!this.currentRoom || !this.isHost) return

    const state: PlayerState = {
      action: DistributedConstants.PLAYER_ACTION_PAUSE,
      position: position,
      speed: 1,
      timestamp: Date.now(),
      hostId: this.currentRoom.hostId
    }

    await DataSyncService.getInstance().updatePlayerState(state)
    hilog.info(0, TAG, `Paused at ${position}ms`)
  }

  async seekTo(position: number): Promise<void> {
    if (!this.currentRoom || !this.isHost) return

    const state: PlayerState = {
      action: DistributedConstants.PLAYER_ACTION_SEEK,
      position: position,
      speed: 1,
      timestamp: Date.now(),
      hostId: this.currentRoom.hostId
    }

    await DataSyncService.getInstance().updatePlayerState(state)
    hilog.info(0, TAG, `Seek to ${position}ms`)
  }

  async setPlaybackSpeed(speed: number): Promise<void> {
    if (!this.currentRoom || !this.isHost) return

    const state: PlayerState = {
      action: DistributedConstants.PLAYER_ACTION_SPEED,
      position: 0,
      speed: speed,
      timestamp: Date.now(),
      hostId: this.currentRoom.hostId
    }

    await DataSyncService.getInstance().updatePlayerState(state)
    hilog.info(0, TAG, `Speed set to ${speed}x`)
  }

  async sendChatMessage(content: string): Promise<void> {
    const message: ChatMessageSync = {
      id: 'msg_' + Date.now(),
      userId: this.localUserId,
      userName: this.localUserName,
      content: content,
      timestamp: Date.now(),
      type: DistributedConstants.MESSAGE_TYPE_CHAT
    }

    await DataSyncService.getInstance().sendChatMessage(message)
  }

  private async sendSystemMessage(content: string): Promise<void> {
    const message: ChatMessageSync = {
      id: 'sys_' + Date.now(),
      userId: 'system',
      userName: '系统消息',
      content: content,
      timestamp: Date.now(),
      type: DistributedConstants.MESSAGE_TYPE_SYSTEM
    }

    try {
      await DataSyncService.getInstance().sendChatMessage(message)
    } catch (err) {
      hilog.warn(0, TAG, `Failed to send system message: ${JSON.stringify(err)}`)
    }
  }

  async discoverNearbyRooms(): Promise<Room[]> {
    // 调用真实设备发现，发现周边在线鸿蒙设备
    let discoveredDevices: DeviceInfo[] = []
    try {
      discoveredDevices = await DeviceManagerService.getInstance().startDeviceDiscovery()
      hilog.info(0, TAG, `Discovered ${discoveredDevices.length} devices`)
    } catch (err) {
      hilog.warn(0, TAG, `Device discovery failed: ${JSON.stringify(err)}`)
    }

    // 基于真实发现的设备生成"附近房间"列表
    // 每个在线设备视为一个潜在的可加入房间（房主为该设备）
    const rooms: Room[] = []
    for (let i = 0; i < discoveredDevices.length; i++) {
      const device = discoveredDevices[i]
      if (!device.isOnline) {
        continue
      }
      const hostMember: RoomMember = {
        userId: device.deviceId,
        userName: device.deviceName,
        isHost: true,
        isOnline: true,
        deviceId: device.deviceId
      }
      const room: Room = {
        roomId: 'room_' + device.deviceId,
        roomName: device.deviceName + '的观影房',
        hostId: device.deviceId,
        hostName: device.deviceName,
        memberCount: 1,
        maxMember: 8,
        status: DistributedConstants.ROOM_STATUS_WAITING,
        movieTitle: undefined,
        moviePoster: undefined,
        createdTime: Date.now(),
        members: [hostMember]
      }
      rooms.push(room)
    }

    return rooms
  }

  getCurrentRoom(): Room | null {
    return this.currentRoom
  }

  isRoomHost(): boolean {
    return this.isHost
  }

  setLocalUserName(name: string): void {
    this.localUserName = name
  }

  getLocalUserName(): string {
    return this.localUserName
  }

  setOnRoomCreatedCallback(callback: (room: Room) => void): void {
    this.onRoomCreatedCallback = callback
  }

  setOnRoomJoinedCallback(callback: (room: Room) => void): void {
    this.onRoomJoinedCallback = callback
  }

  setOnMemberJoinCallback(callback: (member: RoomMember) => void): void {
    this.onMemberJoinCallback = callback
  }

  setOnMemberLeaveCallback(callback: (userId: string) => void): void {
    this.onMemberLeaveCallback = callback
  }

  setOnPlayerStateChangeCallback(callback: (state: PlayerState) => void): void {
    this.onPlayerStateChangeCallback = callback
  }

  setOnChatMessageCallback(callback: (message: ChatMessageSync) => void): void {
    this.onChatMessageCallback = callback
  }

  async release(): Promise<void> {
    DeviceManagerService.getInstance().release()
    await DataSyncService.getInstance().release()
    this.currentRoom = null
    this.isHost = false
  }
}

export default RoomManagerService
