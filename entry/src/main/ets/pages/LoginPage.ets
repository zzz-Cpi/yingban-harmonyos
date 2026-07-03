import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Colors } from '../utils/Constants'

@Entry
@Component
struct LoginPage {
  @State phoneNumber: string = ''
  @State password: string = ''
  @State isLoading: boolean = false

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

      TextInput({ placeholder: '请输入密码' })
        .maxLength(20)
        .type(InputType.Password)
        .inputStyle()
        .onChange((value: string) => {
          this.password = value
        })

      Divider()
        .height(1)
        .color('#33182431')

      Row() {
        Text('短信验证登录').blueTextStyle()
        Text('忘记密码').blueTextStyle()
      }
      .width('94%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10 })

      Button('登录')
        .width('90%')
        .height(40)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
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
          promptAction.showToast({ message: '注册功能开发中', duration: 1500 })
        })

      Text('其他登录方式')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#838D97')
        .margin({ top: 50, bottom: 10 })

      Row({ space: 45 }) {
        this.imageButton($r('app.media.login_method1'))
        this.imageButton($r('app.media.login_method2'))
        this.imageButton($r('app.media.login_method3'))
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
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码', duration: 1500 })
      return false
    }
    return true
  }

  private performLogin(): void {
    setTimeout(() => {
      if (this.phoneNumber === '123456' && this.password === '123456') {
        promptAction.showToast({ message: '账号成功登录', duration: 1500 })
        setTimeout(() => {
          router.pushUrl({ url: 'pages/Index' })
        }, 1000)
      } else {
        promptAction.showToast({ message: '账号密码错误，请重新输入', duration: 1500 })
        this.isLoading = false
      }
    }, 800)
  }

  @Builder
  imageButton(src: Resource) {
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
    .onClick(() => {
      promptAction.showToast({ message: '第三方登录开发中', duration: 1500 })
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
