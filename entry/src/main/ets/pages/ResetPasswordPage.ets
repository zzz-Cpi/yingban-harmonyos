import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Colors } from '../utils/Constants'
import { UserService } from '../utils/UserService'
import { EyeIcon } from '../components/EyeIcon'

@Entry
@Component
struct ResetPasswordPage {
  @State phoneNumber: string = ''
  @State smsCode: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State smsCountdown: number = 0
  @State isLoading: boolean = false
  @State showPassword: boolean = false

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#99182431')
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20 })

      Text('忘记密码')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .margin({ top: 30 })
      Text('通过手机号重置密码')
        .fontSize(16)
        .fontColor('#99182431')
        .margin({ top: 10, bottom: 30 })

      TextInput({ placeholder: '请输入手机号' })
        .maxLength(11)
        .type(InputType.Number)
        .inputStyle()
        .onChange((value: string) => {
          this.phoneNumber = value
        })

      Divider()
        .height(1)
        .color('#33182431')

      Row({ space: 10 }) {
        TextInput({ placeholder: '请输入验证码' })
          .maxLength(6)
          .type(InputType.Number)
          .width('60%')
          .height(45)
          .fontSize(18)
          .backgroundColor('#f1f3f5')
          .placeholderColor('#99182431')
          .onChange((value: string) => {
            this.smsCode = value
          })
        Button(this.smsCountdown > 0 ? `${this.smsCountdown}s` : '获取验证码')
          .width('35%')
          .height(45)
          .fontSize(14)
          .fontColor('#FFA5AE')
          .backgroundColor('#FFFAF5')
          .borderRadius(8)
          .enabled(this.smsCountdown === 0 && this.phoneNumber.length === 11)
          .onClick(() => {
            this.sendSmsCode()
          })
      }
      .width('100%')

      Divider()
        .height(1)
        .color('#33182431')

      Stack({ alignContent: Alignment.End }) {
        TextInput({ placeholder: '请设置新密码（至少6位）' })
          .maxLength(20)
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .inputStyle()
          .onChange((value: string) => {
            this.newPassword = value
          })
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          EyeIcon({ isOpen: this.showPassword, color: '#99182431' })
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showPassword = !this.showPassword
        })
      }
      .width('100%')

      Divider()
        .height(1)
        .color('#33182431')

      TextInput({ placeholder: '请确认新密码' })
        .maxLength(20)
        .type(this.showPassword ? InputType.Normal : InputType.Password)
        .inputStyle()
        .onChange((value: string) => {
          this.confirmPassword = value
        })

      Divider()
        .height(1)
        .color('#33182431')

      Button({ type: ButtonType.Capsule }) {
        if (this.isLoading) {
          Row({ space: 8 }) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
            Text('重置中...')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
        } else {
          Text('重置密码')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
      }
      .width('90%')
      .height(40)
      .backgroundColor('#F992A5')
      .margin({ top: 40, bottom: 10 })
      .enabled(!this.isLoading)
      .onClick(() => {
        if (this.isLoading) return
        if (!this.validateInput()) return

        this.isLoading = true
        this.performReset()
      })

      Row({ space: 4 }) {
        Text('记得密码了？')
          .fontSize(14)
          .fontColor('#99182431')
        Text('立即登录')
          .fontSize(14)
          .fontColor('#FFA5AE')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            router.back()
          })
      }
      .margin({ top: 20 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Colors.background)
    .padding({ left: 20, right: 20 })
  }

  private validateInput(): boolean {
    if (this.phoneNumber.length === 0) {
      promptAction.showToast({ message: '请输入手机号', duration: 1500 })
      return false
    }
    if (!/^1[3-9]\d{9}$/.test(this.phoneNumber)) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 1500 })
      return false
    }
    if (this.smsCode.length === 0) {
      promptAction.showToast({ message: '请输入验证码', duration: 1500 })
      return false
    }
    if (this.smsCode.length !== 4) {
      promptAction.showToast({ message: '验证码为4位', duration: 1500 })
      return false
    }
    if (this.newPassword.length === 0) {
      promptAction.showToast({ message: '请输入新密码', duration: 1500 })
      return false
    }
    if (this.newPassword.length < 6) {
      promptAction.showToast({ message: '密码至少6位', duration: 1500 })
      return false
    }
    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致', duration: 1500 })
      return false
    }
    return true
  }

  private async performReset(): Promise<void> {
    const result = await UserService.resetPassword(this.phoneNumber, this.smsCode, this.newPassword)
    if (result.success) {
      promptAction.showToast({ message: result.message, duration: 1500 })
      setTimeout(() => {
        router.back()
      }, 1000)
    } else {
      promptAction.showToast({ message: result.message, duration: 1500 })
      this.isLoading = false
    }
  }

  private async sendSmsCode(): Promise<void> {
    const result = await UserService.sendSmsCode(this.phoneNumber)
    if (result.success) {
      promptAction.showToast({ message: result.message, duration: 1500 })
      this.smsCountdown = 60
      const timer = setInterval(() => {
        this.smsCountdown--
        if (this.smsCountdown <= 0) {
          clearInterval(timer)
        }
      }, 1000)
    } else {
      promptAction.showToast({ message: result.message, duration: 1500 })
    }
  }
}

@Extend(TextInput)
function inputStyle() {
  .height(45)
  .width('100%')
  .fontSize(18)
  .backgroundColor('#f1f3f5')
  .placeholderColor('#99182431')
}