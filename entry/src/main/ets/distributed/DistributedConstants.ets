export class DistributedConstants {
  static readonly STORE_ID: string = 'yingban_theater_store'

  static readonly KEY_ROOM_PREFIX: string = 'room_'
  static readonly KEY_MEMBER_PREFIX: string = 'member_'
  static readonly KEY_CHAT_PREFIX: string = 'chat_'
  static readonly KEY_PLAYER_PREFIX: string = 'player_'

  static readonly ROOM_STATUS_WAITING: string = 'waiting'
  static readonly ROOM_STATUS_PLAYING: string = 'playing'

  static readonly PLAYER_ACTION_PLAY: string = 'play'
  static readonly PLAYER_ACTION_PAUSE: string = 'pause'
  static readonly PLAYER_ACTION_SEEK: string = 'seek'
  static readonly PLAYER_ACTION_SPEED: string = 'speed'

  static readonly MESSAGE_TYPE_CHAT: string = 'chat'
  static readonly MESSAGE_TYPE_SYSTEM: string = 'system'

  static readonly SCAN_TIMEOUT_MS: number = 10000
}
