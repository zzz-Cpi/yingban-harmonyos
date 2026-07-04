import { StorageUtil, UserInfo } from './StorageUtil'

export interface LoginResult {
  success: boolean
  message: string
  userInfo?: UserInfo
}

export interface RegisterResult {
  success: boolean
  message: string
}

export interface SmsVerifyResult {
  success: boolean
  message: string
}

interface MockUser {
  phoneNumber: string
  password: string
  nickname: string
  avatar: string
}

export class UserService {
  static async login(phoneNumber: string, password: string, rememberPassword: boolean): Promise<LoginResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const mockUsers: MockUser[] = [
          { phoneNumber: '123456', password: '123456', nickname: '追剧少年', avatar: '' },
          { phoneNumber: '13800138000', password: '123456', nickname: '影视达人', avatar: '' },
          { phoneNumber: '13900139000', password: '654321', nickname: '电影迷', avatar: '' },
        ]

        const user = mockUsers.find(u => u.phoneNumber === phoneNumber && u.password === password)
        if (user) {
          const userInfo: UserInfo = {
            phoneNumber: user.phoneNumber,
            password: rememberPassword ? password : '',
            token: 'token_' + Date.now() + '_' + phoneNumber,
            nickname: user.nickname,
            avatar: user.avatar,
            rememberPassword: rememberPassword
          }
          StorageUtil.setUserInfo(userInfo)
          StorageUtil.setToken(userInfo.token)
          resolve({ success: true, message: '登录成功', userInfo })
        } else {
          resolve({ success: false, message: '账号密码错误，请重新输入' })
        }
      }, 800)
    })
  }

  static async loginWithSms(phoneNumber: string, code: string): Promise<LoginResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (code === '8888') {
          const userInfo: UserInfo = {
            phoneNumber: phoneNumber,
            password: '',
            token: 'token_' + Date.now() + '_' + phoneNumber,
            nickname: '用户' + phoneNumber.slice(-4),
            avatar: '',
            rememberPassword: false
          }
          StorageUtil.setUserInfo(userInfo)
          StorageUtil.setToken(userInfo.token)
          resolve({ success: true, message: '登录成功', userInfo })
        } else {
          resolve({ success: false, message: '验证码错误' })
        }
      }, 500)
    })
  }

  static async sendSmsCode(phoneNumber: string): Promise<SmsVerifyResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (/^1[3-9]\d{9}$/.test(phoneNumber)) {
          resolve({ success: true, message: '验证码已发送' })
        } else {
          resolve({ success: false, message: '请输入正确的手机号' })
        }
      }, 500)
    })
  }

  static async register(phoneNumber: string, password: string, nickname: string): Promise<RegisterResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (!/^1[3-9]\d{9}$/.test(phoneNumber)) {
          resolve({ success: false, message: '请输入正确的手机号' })
          return
        }
        if (password.length < 6) {
          resolve({ success: false, message: '密码至少6位' })
          return
        }
        if (!nickname || nickname.length < 2) {
          resolve({ success: false, message: '昵称至少2个字符' })
          return
        }

        const userInfo: UserInfo = {
          phoneNumber: phoneNumber,
          password: password,
          token: 'token_' + Date.now() + '_' + phoneNumber,
          nickname: nickname,
          avatar: '',
          rememberPassword: false
        }
        StorageUtil.setUserInfo(userInfo)
        StorageUtil.setToken(userInfo.token)
        resolve({ success: true, message: '注册成功' })
      }, 800)
    })
  }

  static async resetPassword(phoneNumber: string, code: string, newPassword: string): Promise<RegisterResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (code !== '8888') {
          resolve({ success: false, message: '验证码错误' })
          return
        }
        if (newPassword.length < 6) {
          resolve({ success: false, message: '密码至少6位' })
          return
        }

        const userInfo: UserInfo = {
          phoneNumber: phoneNumber,
          password: newPassword,
          token: '',
          nickname: '',
          avatar: '',
          rememberPassword: false
        }
        StorageUtil.setUserInfo(userInfo)
        resolve({ success: true, message: '密码重置成功' })
      }, 800)
    })
  }

  static async logout(): Promise<void> {
    await StorageUtil.clearUserInfo()
    await StorageUtil.clearToken()
  }

  static async isLoggedIn(): Promise<boolean> {
    const token = await StorageUtil.getToken()
    return token !== ''
  }

  static async getCurrentUser(): Promise<UserInfo | null> {
    return await StorageUtil.getUserInfo()
  }

  static async loginWithThirdParty(type: string): Promise<LoginResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const nicknames: Record<string, string> = {
          'wechat': '微信用户',
          'qq': 'QQ用户',
          'apple': 'Apple用户'
        }
        const userInfo: UserInfo = {
          phoneNumber: '',
          password: '',
          token: 'token_' + Date.now() + '_' + type,
          nickname: nicknames[type] || '用户',
          avatar: '',
          rememberPassword: false
        }
        StorageUtil.setUserInfo(userInfo)
        StorageUtil.setToken(userInfo.token)
        resolve({ success: true, message: `${nicknames[type]}登录成功`, userInfo })
      }, 1000)
    })
  }
}