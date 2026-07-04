import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Colors } from '../utils/Constants'
import { StorageUtil } from '../utils/StorageUtil'
import { UserService, LoginResult } from '../utils/UserService'
import { EyeIcon } from '../components/EyeIcon'

@Entry
@Component
struct LoginPage {
  @State phoneNumber: string = ''
  @State password: string = ''
  @State isLoading: boolean = false
  @State showPassword: boolean = false
  @State rememberPassword: boolean = false

  async aboutToAppear(): Promise<void> {
    const userInfo = await StorageUtil.getUserInfo()
    if (userInfo && userInfo.rememberPassword && userInfo.phoneNumber) {
      this.phoneNumber = userInfo.phoneNumber
      this.password = userInfo.password || ''
      this.rememberPassword = true
    }
  }

  build() {
    Column() {
      Image($r('app.media.logo'))
        .width(78)
        .height(78)
        .margin({ top: 100, bottom: 10 })
        .borderRadius(20)
      Text('影伴')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
      Text('登录账号以使用更多服务')
        .fontSize(16)
        .fontColor('#99182431')
        .margin({ top: 10, bottom: 30 })

      TextInput({ placeholder: '请输入账号' })
        .maxLength(11)
        .type(InputType.Number)
        .inputStyle()
        .onChange((value: string) => {
          this.phoneNumber = value
        })

      Divider()
        .height(1)
        .color('#33182431')

      Stack({ alignContent: Alignment.End }) {
        TextInput({ placeholder: '请输入密码' })
          .maxLength(20)
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .inputStyle()
          .onChange((value: string) => {
            this.password = value
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

      Row() {
        Row({ space: 8 }) {
          Checkbox()
            .select(this.rememberPassword)
            .selectedColor('#F992A5')
            .onChange((value: boolean) => {
              this.rememberPassword = value
            })
          Text('记住密码')
            .fontSize(14)
            .fontColor('#99182431')
        }
        Text('忘记密码')
          .blueTextStyle()
          .onClick(() => {
            router.pushUrl({ url: 'pages/ResetPasswordPage' })
          })
      }
      .width('94%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10 })

      Button({ type: ButtonType.Capsule }) {
        if (this.isLoading) {
          Row({ space: 8 }) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
            Text('登录中...')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
        } else {
          Text('登录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
      }
      .width('90%')
      .height(40)
      .backgroundColor('#F992A5')
      .margin({ top: 90, bottom: 10 })
      .enabled(!this.isLoading)
      .onClick(() => {
        if (this.isLoading) return
        if (!this.validateInput()) return

        this.isLoading = true
        this.performLogin()
      })

      Text('注册账号')
        .fontSize(16)
        .fontColor('#FFA5AE')
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          router.pushUrl({ url: 'pages/RegisterPage' })
        })

      Text('其他登录方式')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#838D97')
        .margin({ top: 50, bottom: 10 })

      Row({ space: 45 }) {
        this.thirdPartyButton($r('app.media.login_method1'), 'apple')
        this.thirdPartyButton($r('app.media.login_method2'), 'qq')
        this.thirdPartyButton($r('app.media.login_method3'), 'wechat')
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Colors.background)
    .padding({ left: 20, right: 20 })
  }

  private validateInput(): boolean {
    if (this.phoneNumber.length === 0) {
      promptAction.showToast({ message: '请输入账号', duration: 1500 })
      return false
    }
    if (!/^1[3-9]\d{9}$/.test(this.phoneNumber) && this.phoneNumber !== '123456') {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 1500 })
      return false
    }
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码', duration: 1500 })
      return false
    }
    if (this.password.length < 6 && this.password !== '123456') {
      promptAction.showToast({ message: '密码至少6位', duration: 1500 })
      return false
    }
    return true
  }

  private async performLogin(): Promise<void> {
    const result: LoginResult = await UserService.login(this.phoneNumber, this.password, this.rememberPassword)

    if (result.success) {
      promptAction.showToast({ message: result.message, duration: 1500 })
      setTimeout(() => {
        router.pushUrl({ url: 'pages/Index' })
      }, 1000)
    } else {
      promptAction.showToast({ message: result.message, duration: 1500 })
      this.isLoading = false
    }
  }

  private async thirdPartyLogin(type: string): Promise<void> {
    this.isLoading = true
    const result = await UserService.loginWithThirdParty(type)
    if (result.success) {
      promptAction.showToast({ message: result.message, duration: 1500 })
      setTimeout(() => {
        router.pushUrl({ url: 'pages/Index' })
      }, 1000)
    } else {
      promptAction.showToast({ message: result.message, duration: 1500 })
      this.isLoading = false
    }
  }

  @Builder
  thirdPartyButton(src: Resource, type: string) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image(src)
        .width(30)
        .height(30)
        .objectFit(ImageFit.Contain)
    }
    .width(56)
    .height(56)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 6, color: '#1A000000', offsetY: 2 })
    .enabled(!this.isLoading)
    .onClick(() => {
      if (this.isLoading) return
      this.thirdPartyLogin(type)
    })
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

@Extend(Text)
function blueTextStyle() {
  .fontColor('#FFA5AE')
  .fontSize(14)
  .fontWeight(FontWeight.Medium)
}