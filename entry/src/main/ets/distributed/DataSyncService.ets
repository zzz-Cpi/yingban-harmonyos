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

interface KVEntry {
  key: string
  value: string
}

interface DataChangeEvent {
  insertEntries?: KVEntry[]
  updateEntries?: KVEntry[]
}

export class DataSyncService {
  private static instance: DataSyncService | null = null
  private isInitialized: boolean = false
  private localData: Map<string, string> = new Map()
  private onDataChangeCallback: (key: string, value: string) => void = () => {}
  private onPlayerStateChangeCallback: (state: PlayerState) => void = () => {}
  private onChatMessageCallback: (message: ChatMessageSync) => void = () => {}

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
      hilog.info(0, TAG, 'DataSyncService initialized (local mock mode)')
      this.isInitialized = true
    } catch (err) {
      hilog.error(0, TAG, `Failed to init DataSyncService: ${JSON.stringify(err)}`)
      throw err as Error
    }
  }

  private handleDataChange(key: string, value: string): void {
    hilog.info(0, TAG, `Data changed: key=${key}`)

    try {
      if (key.startsWith(DistributedConstants.KEY_PLAYER_PREFIX)) {
        const playerState: PlayerState = JSON.parse(value)
        if (this.onPlayerStateChangeCallback) {
          this.onPlayerStateChangeCallback(playerState)
        }
      } else if (key.startsWith(DistributedConstants.KEY_CHAT_PREFIX)) {
        const message: ChatMessageSync = JSON.parse(value)
        if (this.onChatMessageCallback) {
          this.onChatMessageCallback(message)
        }
      }

      if (this.onDataChangeCallback) {
        this.onDataChangeCallback(key, value)
      }
    } catch (err) {
      hilog.error(0, TAG, `Failed to handle data change: ${JSON.stringify(err)}`)
    }
  }

  async put(key: string, value: string): Promise<void> {
    try {
      this.localData.set(key, value)
      hilog.info(0, TAG, `Data stored locally: key=${key}`)
    } catch (err) {
      hilog.error(0, TAG, `Failed to put data: key=${key}, err=${JSON.stringify(err)}`)
      throw err as Error
    }
  }

  async get(key: string): Promise<string | null> {
    try {
      const value = this.localData.get(key)
      return value !== undefined ? value : null
    } catch (err) {
      hilog.error(0, TAG, `Failed to get data: key=${key}, err=${JSON.stringify(err)}`)
      return null
    }
  }

  async delete(key: string): Promise<void> {
    try {
      this.localData.delete(key)
    } catch (err) {
      hilog.error(0, TAG, `Failed to delete data: key=${key}, err=${JSON.stringify(err)}`)
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
    
    if (this.onChatMessageCallback) {
      this.onChatMessageCallback(message)
    }
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

  async release(): Promise<void> {
    this.localData.clear()
    this.isInitialized = false
    hilog.info(0, TAG, 'DataSyncService released')
  }
}

export default DataSyncService
