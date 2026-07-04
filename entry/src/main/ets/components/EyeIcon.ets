@Component
export struct EyeIcon {
  @State isOpen: boolean = true
  @State color: string = '#99182431'

  build() {
    Column()
      .width(20)
      .height(20)
      .backgroundColor(Color.Transparent)
  }
}