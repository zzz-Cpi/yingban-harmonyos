import { DistributedConstants } from './DistributedConstants'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'DataSyncService'

export interface PlayerState {
  action: string
  position: number
  speed: number
  timestamp: number
  hostId: string
}

export interface ChatMessageSync {
  id: string
  userId: string
  userName: string
  content: string
  timestamp: number
  type: string
}

export interface RoomMemberSync {
  roomId: string
  roomName: string
  hostId: string
  hostName: string
  memberCount: number
  maxMember: number
  status: string
  movieTitle?: string
  moviePoster?: string
  createdTime: number
}

export interface KVEntry {
  key: string
  value: string
}

export class DataSyncService {
  private static instance: DataSyncService | null = null
  private isInitialized: boolean = false
  private localData: Map<string, string> = new Map()
  private onDataChangeCallback: (key: string, value: string) => void = () => {}
  private onPlayerStateChangeCallback: (state: PlayerState) => void = () => {}
  private onChatMessageCallback: (message: ChatMessageSync) => void = () => {}
  private onRoomInfoChangeCallback: (room: RoomMemberSync) => void = () => {}

  private constructor() {}

  static getInstance(): DataSyncService {
    if (!DataSyncService.instance) {
      DataSyncService.instance = new DataSyncService()
    }
    return DataSyncService.instance
  }

  async init(): Promise<void> {
    if (this.isInitialized) {
      return
    }

    try {
      hilog.info(0, TAG, 'DataSyncService initialized (local mode, ready for distributed extension)')
      this.isInitialized = true
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to init DataSyncService: ${errorMsg}`)
      throw err instanceof Error ? err : new Error(String(err))
    }
  }

  async put(key: string, value: string): Promise<void> {
    try {
      this.localData.set(key, value)
      hilog.info(0, TAG, `Data stored: key=${key}`)
      this.dispatchDataChange(key, value)
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to put data: key=${key}, err=${errorMsg}`)
      throw err instanceof Error ? err : new Error(String(err))
    }
  }

  async get(key: string): Promise<string | null> {
    try {
      const value = this.localData.get(key)
      return value !== undefined ? value : null
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to get data: key=${key}, err=${errorMsg}`)
      return null
    }
  }

  async delete(key: string): Promise<void> {
    try {
      this.localData.delete(key)
      hilog.info(0, TAG, `Data deleted: key=${key}`)
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to delete data: key=${key}, err=${errorMsg}`)
    }
  }

  async getKeysByPrefix(prefix: string): Promise<string[]> {
    const keys: string[] = []
    this.localData.forEach((value: string, key: string) => {
      if (key.startsWith(prefix)) {
        keys.push(key)
      }
    })
    return keys
  }

  async getEntriesByPrefix(prefix: string): Promise<KVEntry[]> {
    const entries: KVEntry[] = []
    this.localData.forEach((value: string, key: string) => {
      if (key.startsWith(prefix)) {
        entries.push({ key: key, value: value })
      }
    })
    return entries
  }

  private dispatchDataChange(key: string, value: string): void {
    try {
      if (key.startsWith(DistributedConstants.KEY_PLAYER_PREFIX)) {
        const playerState: PlayerState = JSON.parse(value) as PlayerState
        if (this.onPlayerStateChangeCallback) {
          this.onPlayerStateChangeCallback(playerState)
        }
      } else if (key.startsWith(DistributedConstants.KEY_CHAT_PREFIX)) {
        const message: ChatMessageSync = JSON.parse(value) as ChatMessageSync
        if (this.onChatMessageCallback) {
          this.onChatMessageCallback(message)
        }
      } else if (key.startsWith(DistributedConstants.KEY_ROOM_PREFIX)) {
        const room: RoomMemberSync = JSON.parse(value) as RoomMemberSync
        if (this.onRoomInfoChangeCallback) {
          this.onRoomInfoChangeCallback(room)
        }
      }

      if (this.onDataChangeCallback) {
        this.onDataChangeCallback(key, value)
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to dispatch data change: ${errorMsg}`)
    }
  }

  async updatePlayerState(state: PlayerState): Promise<void> {
    const key = DistributedConstants.KEY_PLAYER_PREFIX + state.hostId
    const value = JSON.stringify(state)
    await this.put(key, value)
    hilog.info(0, TAG, `Player state updated: ${state.action}`)
  }

  async sendChatMessage(message: ChatMessageSync): Promise<void> {
    const key = DistributedConstants.KEY_CHAT_PREFIX + message.id
    const value = JSON.stringify(message)
    await this.put(key, value)
    hilog.info(0, TAG, `Chat message sent: ${message.id}`)
  }

  async updateRoomInfo(room: RoomMemberSync): Promise<void> {
    const key = DistributedConstants.KEY_ROOM_PREFIX + room.roomId
    const value = JSON.stringify(room)
    await this.put(key, value)
    hilog.info(0, TAG, `Room info updated: ${room.roomName}`)
  }

  setOnDataChangeCallback(callback: (key: string, value: string) => void): void {
    this.onDataChangeCallback = callback
  }

  setOnPlayerStateChangeCallback(callback: (state: PlayerState) => void): void {
    this.onPlayerStateChangeCallback = callback
  }

  setOnChatMessageCallback(callback: (message: ChatMessageSync) => void): void {
    this.onChatMessageCallback = callback
  }

  setOnRoomInfoChangeCallback(callback: (room: RoomMemberSync) => void): void {
    this.onRoomInfoChangeCallback = callback
  }

  async release(): Promise<void> {
    this.localData.clear()
    this.isInitialized = false
    hilog.info(0, TAG, 'DataSyncService released')
  }
}

export default DataSyncService