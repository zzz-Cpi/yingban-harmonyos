import { DistributedConstants } from './DistributedConstants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { distributedKVStore } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'

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
  roomCode?: string
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
  private kvManager: distributedKVStore.KVManager | null = null
  private kvStore: distributedKVStore.SingleKVStore | null = null
  private useDistributedStore: boolean = false
  private bundleName: string = 'yingban_theater'
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
      const context: Context | undefined = AppStorage.get('appContext') as Context
      if (!context) {
        hilog.warn(0, TAG, 'No application context found, fallback to local mode')
        this.isInitialized = true
        return
      }

      this.bundleName = context.applicationInfo.name || 'com.example.application'
      hilog.info(0, TAG, `Initializing distributed KVStore with bundleName: ${this.bundleName}`)

      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        context: context,
        bundleName: this.bundleName
      }
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig)
      hilog.info(0, TAG, 'KVManager created successfully')

      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      }

      this.kvStore = await this.kvManager.getKVStore(DistributedConstants.STORE_ID, options)
      this.useDistributedStore = true
      hilog.info(0, TAG, '✅ Distributed KVStore initialized successfully - cross-device sync enabled')

      this.subscribeDataChanges()
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `❌ Failed to init distributed KVStore: ${errorMsg}, fallback to local mode`)
      this.useDistributedStore = false
      this.kvStore = null
      this.kvManager = null
    }

    this.isInitialized = true
  }

  private subscribeDataChanges(): void {
    if (!this.kvStore) {
      return
    }

    try {
      this.kvStore.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL,
        (data: distributedKVStore.ChangeNotification) => {
          try {
            const entries = data.insertEntries.concat(data.updateEntries)
            for (let i = 0; i < entries.length; i++) {
              const entry = entries[i]
              const key = entry.key
              const valueObj = entry.value
              let value = ''
              if (valueObj) {
                const actualValue = valueObj.value
                if (typeof actualValue === 'string') {
                  value = actualValue
                } else if (actualValue instanceof Uint8Array) {
                  value = this.uint8ArrayToString(actualValue)
                }
              }
              if (value && value.length > 0) {
                this.localData.set(key, value)
                this.dispatchDataChange(key, value)
              }
            }
          } catch (err) {
            const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
            hilog.error(0, TAG, `Failed to handle data change: ${errorMsg}`)
          }
        })
      hilog.info(0, TAG, 'Subscribed to distributed data changes')
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.warn(0, TAG, `Failed to subscribe data changes: ${errorMsg}`)
    }
  }

  private uint8ArrayToString(array: Uint8Array): string {
    let result = ''
    for (let i = 0; i < array.length; i++) {
      result += String.fromCharCode(array[i])
    }
    return result
  }

  async put(key: string, value: string, skipDispatch?: boolean): Promise<void> {
    try {
      this.localData.set(key, value)

      if (this.useDistributedStore && this.kvStore) {
        await this.kvStore.put(key, value)
        hilog.info(0, TAG, `Data stored to distributed KV: key=${key}`)
      } else {
        hilog.info(0, TAG, `Data stored to local cache: key=${key}`)
        if (!skipDispatch) {
          this.dispatchDataChange(key, value)
        }
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to put data: key=${key}, err=${errorMsg}`)
      throw err instanceof Error ? err : new Error(String(err))
    }
  }

  async get(key: string): Promise<string | null> {
    try {
      if (this.useDistributedStore && this.kvStore) {
        const value = await this.kvStore.get(key)
        if (value === null || value === undefined) {
          return null
        }
        if (typeof value === 'string') {
          return value
        }
        if (value instanceof Uint8Array) {
          return this.uint8ArrayToString(value)
        }
        return String(value)
      }
      const localValue = this.localData.get(key)
      return localValue !== undefined ? localValue : null
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to get data: key=${key}, err=${errorMsg}`)
      return null
    }
  }

  async delete(key: string): Promise<void> {
    try {
      this.localData.delete(key)
      if (this.useDistributedStore && this.kvStore) {
        await this.kvStore.delete(key)
      }
      hilog.info(0, TAG, `Data deleted: key=${key}`)
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to delete data: key=${key}, err=${errorMsg}`)
    }
  }

  async getKeysByPrefix(prefix: string): Promise<string[]> {
    try {
      if (this.useDistributedStore && this.kvStore) {
        const entries = await this.kvStore.getEntries(prefix)
        const keys: string[] = []
        for (let i = 0; i < entries.length; i++) {
          keys.push(entries[i].key)
        }
        return keys
      }
      const keys: string[] = []
      this.localData.forEach((value: string, key: string) => {
        if (key.startsWith(prefix)) {
          keys.push(key)
        }
      })
      return keys
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to get keys by prefix: ${errorMsg}`)
      return []
    }
  }

  async getEntriesByPrefix(prefix: string): Promise<KVEntry[]> {
    try {
      const keys = await this.getKeysByPrefix(prefix)
      const entries: KVEntry[] = []
      for (let i = 0; i < keys.length; i++) {
        const value = await this.get(keys[i])
        if (value !== null && value !== undefined) {
          entries.push({ key: keys[i], value: value })
        }
      }
      return entries
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.error(0, TAG, `Failed to get entries by prefix: ${errorMsg}`)
      return []
    }
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

  async sendChatMessage(message: ChatMessageSync, skipDispatch?: boolean): Promise<void> {
    const key = DistributedConstants.KEY_CHAT_PREFIX + message.id
    const value = JSON.stringify(message)
    await this.put(key, value, skipDispatch)
    hilog.info(0, TAG, `Chat message sent: ${message.id}, skipDispatch: ${skipDispatch}`)
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

  isDistributedStoreEnabled(): boolean {
    return this.useDistributedStore && this.kvStore !== null
  }

  async release(): Promise<void> {
    try {
      if (this.kvStore) {
        this.kvStore.off('dataChange')
        if (this.kvManager) {
          await this.kvManager.closeKVStore(this.bundleName, DistributedConstants.STORE_ID)
        }
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err)
      hilog.warn(0, TAG, `Failed to release KVStore: ${errorMsg}`)
    }
    this.localData.clear()
    this.kvStore = null
    this.kvManager = null
    this.useDistributedStore = false
    this.isInitialized = false
    hilog.info(0, TAG, 'DataSyncService released')
  }
}

export default DataSyncService
