import dataPreferences from '@ohos.data.preferences'

const PREFERENCES_NAME = 'user_preferences'

export interface UserInfo {
  phoneNumber: string
  password: string
  token: string
  nickname: string
  avatar: string
  rememberPassword: boolean
}

let preferencesInstance: dataPreferences.Preferences | null = null

export class StorageUtil {
  static async init(context: Context): Promise<void> {
    if (preferencesInstance) return
    try {
      preferencesInstance = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
    } catch (e) {
      console.error('StorageUtil init failed:', JSON.stringify(e))
    }
  }

  static async setUserInfo(userInfo: UserInfo): Promise<void> {
    if (!preferencesInstance) return
    try {
      await preferencesInstance.put('user_info', JSON.stringify(userInfo))
      await preferencesInstance.flush()
    } catch (e) {
      console.error('StorageUtil setUserInfo failed:', JSON.stringify(e))
    }
  }

  static async getUserInfo(): Promise<UserInfo | null> {
    if (!preferencesInstance) return null
    try {
      const data = await preferencesInstance.get('user_info', '')
      if (typeof data === 'string' && data) {
        return JSON.parse(data) as UserInfo
      }
      return null
    } catch (e) {
      console.error('StorageUtil getUserInfo failed:', JSON.stringify(e))
      return null
    }
  }

  static async clearUserInfo(): Promise<void> {
    if (!preferencesInstance) return
    try {
      await preferencesInstance.delete('user_info')
      await preferencesInstance.flush()
    } catch (e) {
      console.error('StorageUtil clearUserInfo failed:', JSON.stringify(e))
    }
  }

  static async setToken(token: string): Promise<void> {
    if (!preferencesInstance) return
    try {
      await preferencesInstance.put('token', token)
      await preferencesInstance.flush()
    } catch (e) {
      console.error('StorageUtil setToken failed:', JSON.stringify(e))
    }
  }

  static async getToken(): Promise<string> {
    if (!preferencesInstance) return ''
    try {
      const token = await preferencesInstance.get('token', '')
      return typeof token === 'string' ? token : ''
    } catch (e) {
      console.error('StorageUtil getToken failed:', JSON.stringify(e))
      return ''
    }
  }

  static async clearToken(): Promise<void> {
    if (!preferencesInstance) return
    try {
      await preferencesInstance.delete('token')
      await preferencesInstance.flush()
    } catch (e) {
      console.error('StorageUtil clearToken failed:', JSON.stringify(e))
    }
  }
}