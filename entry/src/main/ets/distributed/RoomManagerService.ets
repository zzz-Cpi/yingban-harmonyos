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
  private localDeviceId: string = 'local_device'
  private isServiceReady: boolean = false

  private onRoomCreatedCallback: (room: Room) => void = () => {}
  private onRoomJoinedCallback: (room: Room) => void = () => {}
  private onMemberJoinCallback: (member: RoomMember) => void = () => {}
  private onMemberLeaveCallback: (userId: string) => void = () => {}
  private onPlayerStateChangeCallback: (state: PlayerState) => void = () => {}
  private onChatMessageCallback: (message: ChatMessageSync) => void = () => {}
  private onNearbyRoomUpdateCallback: (rooms: Room[]) => void = () => {}

  private constructor() {}

  static getInstance(): RoomManagerService {
    if (!RoomManagerService.instance) {
      RoomManagerService.instance = new RoomManagerService()
    }
    return RoomManagerService.instance
  }

  async init(): Promise<void> {
    if (this.isServiceReady) {
      return
    }
    try {
      await DeviceManagerService.getInstance().init()
      hilog.info(0, TAG, 'DeviceManagerService initialized')

      const localDev = DeviceManagerService.getInstance().getLocalDevice()
      if (localDev) {
        this.localDeviceId = localDev.deviceId
        this.localUserId = 'user_' + localDev.deviceId.substring(0, 8)
        if (localDev.deviceName && localDev.deviceName !== '本机设备') {
          this.localUserName = localDev.deviceName
        }
      }
      hilog.info(0, TAG, `Local user: ${this.localUserName}, deviceId: ${this.localDeviceId}`)

      try {
        await DataSyncService.getInstance().init()
        hilog.info(0, TAG, 'DataSyncService initialized (distributed mode)')
      } catch (syncErr) {
        hilog.warn(0, TAG, `DataSyncService init failed, will use mock mode: ${JSON.stringify(syncErr)}`)
      }

      this.setupDataSyncCallbacks()
      this.setupDeviceManagerCallbacks()

      this.isServiceReady = true
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
        hilog.info(0, TAG, `Player state change: ${state.action}`)
        if (this.onPlayerStateChangeCallback) {
          this.onPlayerStateChangeCallback(state)
        }
      }
    })

    dataSync.setOnChatMessageCallback((message: ChatMessageSync) => {
      if (this.currentRoom) {
        hilog.info(0, TAG, `Chat message received: ${message.userName}`)
        if (this.onChatMessageCallback) {
          this.onChatMessageCallback(message)
        }
      }
    })

    dataSync.setOnRoomInfoChangeCallback((room: RoomMemberSync) => {
      hilog.info(0, TAG, `Room info changed: ${room.roomName}, memberCount=${room.memberCount}`)
      if (this.currentRoom && this.currentRoom.roomId === room.roomId) {
        this.currentRoom.memberCount = room.memberCount
        this.currentRoom.status = room.status
        this.currentRoom.movieTitle = room.movieTitle
        this.currentRoom.moviePoster = room.moviePoster
        this.scanNearbyRoomsSilent()
      }
    })
  }

  private setupDeviceManagerCallbacks(): void {
    const deviceMgr = DeviceManagerService.getInstance()

    deviceMgr.setOnDeviceOnlineCallback((device: DeviceInfo) => {
      hilog.info(0, TAG, `Device online: ${device.deviceName}`)
      this.scanNearbyRoomsSilent()
    })

    deviceMgr.setOnDeviceOfflineCallback((device: DeviceInfo) => {
      hilog.info(0, TAG, `Device offline: ${device.deviceName}`)
      if (this.currentRoom) {
        const leftMember = this.currentRoom.members.find(
          (m: RoomMember) => m.deviceId === device.deviceId
        )
        if (leftMember && !leftMember.isHost) {
          this.currentRoom.members = this.currentRoom.members.filter(
            (m: RoomMember) => m.deviceId !== device.deviceId
          )
          this.currentRoom.memberCount = this.currentRoom.members.length
          this.updateRoomInfoBroadcast()
          this.onMemberLeaveCallback(leftMember.userId)
        }
      }
      this.scanNearbyRoomsSilent()
    })
  }

  async createRoom(
    roomName: string,
    maxMember?: number,
    themeId?: number,
    movieTitle?: string,
    moviePoster?: string,
    movieUrl?: string
  ): Promise<Room> {
    await this.init()

    const roomId = 'room_' + this.localDeviceId + '_' + Date.now()
    const hostId = this.localUserId
    const now = Date.now()

    const hostMember: RoomMember = {
      userId: this.localUserId,
      userName: this.localUserName,
      isHost: true,
      isOnline: true,
      deviceId: this.localDeviceId
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
      hilog.info(0, TAG, `Room created and broadcasted: ${roomName}`)
    } catch (err) {
      hilog.warn(0, TAG, `Failed to broadcast room info: ${JSON.stringify(err)}`)
    }

    if (this.onRoomCreatedCallback) {
      this.onRoomCreatedCallback(room)
    }

    return room
  }

  async joinRoom(room: Room): Promise<void> {
    await this.init()

    this.currentRoom = room
    this.isHost = false

    const member: RoomMember = {
      userId: this.localUserId,
      userName: this.localUserName,
      isHost: false,
      isOnline: true,
      deviceId: this.localDeviceId
    }

    const existingMember = this.currentRoom.members.find(
      (m: RoomMember) => m.userId === this.localUserId
    )
    if (!existingMember) {
      this.currentRoom.members.push(member)
      this.currentRoom.memberCount = this.currentRoom.members.length
    }

    this.updateRoomInfoBroadcast()

    hilog.info(0, TAG, `Joined room: ${room.roomName}`)

    if (this.onRoomJoinedCallback && this.currentRoom) {
      this.onRoomJoinedCallback(this.currentRoom)
    }

    await this.sendSystemMessage(`${this.localUserName} 加入了房间`)
  }

  async leaveRoom(): Promise<void> {
    if (this.currentRoom) {
      await this.sendSystemMessage(`${this.localUserName} 离开了房间`)

      if (this.isHost) {
        try {
          await DataSyncService.getInstance().delete(
            DistributedConstants.KEY_ROOM_PREFIX + this.currentRoom.roomId
          )
          hilog.info(0, TAG, `Room broadcast removed: ${this.currentRoom.roomName}`)
        } catch (err) {
          hilog.warn(0, TAG, `Failed to remove room broadcast: ${JSON.stringify(err)}`)
        }
      } else {
        this.currentRoom.members = this.currentRoom.members.filter(
          (m: RoomMember) => m.userId !== this.localUserId
        )
        this.currentRoom.memberCount = this.currentRoom.members.length
        this.updateRoomInfoBroadcast()
      }

      hilog.info(0, TAG, `Left room: ${this.currentRoom.roomName}`)
    }

    this.currentRoom = null
    this.isHost = false
  }

  private updateRoomInfoBroadcast(): void {
    if (!this.currentRoom || !this.isHost) return

    const roomSync: RoomMemberSync = {
      roomId: this.currentRoom.roomId,
      roomName: this.currentRoom.roomName,
      hostId: this.currentRoom.hostId,
      hostName: this.currentRoom.hostName,
      memberCount: this.currentRoom.memberCount,
      maxMember: this.currentRoom.maxMember,
      status: this.currentRoom.status,
      movieTitle: this.currentRoom.movieTitle,
      moviePoster: this.currentRoom.moviePoster,
      createdTime: this.currentRoom.createdTime
    }

    DataSyncService.getInstance().updateRoomInfo(roomSync).catch((err: Error) => {
      hilog.warn(0, TAG, `Failed to update room broadcast: ${err.message}`)
    })
  }

  async startPlaying(): Promise<void> {
    if (!this.currentRoom || !this.isHost) return

    this.currentRoom.status = DistributedConstants.ROOM_STATUS_PLAYING
    this.updateRoomInfoBroadcast()

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
      id: 'msg_' + Date.now() + '_' + Math.floor(Math.random() * 1000),
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
    await this.init()

    let discoveredDevices: DeviceInfo[] = []
    try {
      discoveredDevices = await DeviceManagerService.getInstance().startDeviceDiscovery()
      hilog.info(0, TAG, `Discovered ${discoveredDevices.length} devices`)
    } catch (err) {
      hilog.warn(0, TAG, `Device discovery failed: ${JSON.stringify(err)}`)
    }

    const rooms: Room[] = []

    try {
      const roomEntries = await DataSyncService.getInstance().getEntriesByPrefix(
        DistributedConstants.KEY_ROOM_PREFIX
      )
      hilog.info(0, TAG, `Found ${roomEntries.length} room broadcasts in KVStore`)

      for (let i = 0; i < roomEntries.length; i++) {
        try {
          const roomSync: RoomMemberSync = JSON.parse(roomEntries[i].value)
          const hostMember: RoomMember = {
            userId: roomSync.hostId,
            userName: roomSync.hostName,
            isHost: true,
            isOnline: true
          }
          const room: Room = {
            roomId: roomSync.roomId,
            roomName: roomSync.roomName,
            hostId: roomSync.hostId,
            hostName: roomSync.hostName,
            memberCount: roomSync.memberCount,
            maxMember: roomSync.maxMember,
            status: roomSync.status,
            movieTitle: roomSync.movieTitle,
            moviePoster: roomSync.moviePoster,
            createdTime: roomSync.createdTime,
            members: [hostMember]
          }

          if (!rooms.find((r: Room) => r.roomId === room.roomId)) {
            rooms.push(room)
          }
        } catch (parseErr) {
          hilog.warn(0, TAG, `Failed to parse room data: ${JSON.stringify(parseErr)}`)
        }
      }
    } catch (err) {
      hilog.warn(0, TAG, `Failed to read room broadcasts: ${JSON.stringify(err)}`)
    }

    if (rooms.length === 0) {
      for (let i = 0; i < discoveredDevices.length; i++) {
        const device = discoveredDevices[i]
        if (!device.isOnline) continue
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
          createdTime: Date.now(),
          members: [hostMember]
        }
        rooms.push(room)
      }
    }

    hilog.info(0, TAG, `Total nearby rooms: ${rooms.length}`)
    return rooms
  }

  private scanNearbyRoomsSilent(): void {
    if (!this.onNearbyRoomUpdateCallback) return
    this.discoverNearbyRooms()
      .then((rooms: Room[]) => {
        if (this.onNearbyRoomUpdateCallback) {
          this.onNearbyRoomUpdateCallback(rooms)
        }
      })
      .catch(() => {})
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

  setOnNearbyRoomUpdateCallback(callback: (rooms: Room[]) => void): void {
    this.onNearbyRoomUpdateCallback = callback
  }

  async release(): Promise<void> {
    DeviceManagerService.getInstance().release()
    await DataSyncService.getInstance().release()
    this.currentRoom = null
    this.isHost = false
    this.isServiceReady = false
  }
}

export default RoomManagerService
