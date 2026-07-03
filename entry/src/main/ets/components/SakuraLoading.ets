@Component
export struct SakuraLoading {
  @State private rotateAngle: number = 0
  @State private scaleValue: number = 1

  build() {
    Stack() {
      Image($r('app.media.loading_sakura'))
        .width(48)
        .height(48)
        .objectFit(ImageFit.Contain)
        .rotate({ angle: this.rotateAngle })
        .scale({ x: this.scaleValue, y: this.scaleValue })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .onAppear(() => {
      this.startAnimation()
    })
  }

  startAnimation() {
    animateTo({
      duration: 1500,
      curve: Curve.EaseOut,
      iterations: -1,
      onFinish: () => {
      }
    }, () => {
      this.rotateAngle = 360
    })

    setInterval(() => {
      animateTo({
        duration: 300,
        curve: Curve.FastOutSlowIn
      }, () => {
        this.scaleValue = 1.2
      })
      setTimeout(() => {
        animateTo({
          duration: 400,
          curve: Curve.EaseOut
        }, () => {
          this.scaleValue = 1
        })
      }, 300)
    }, 1500)
  }
}

@Component
export struct MiniSakuraLoading {
  @State private rotateAngle: number = 0

  build() {
    Image($r('app.media.loading_sakura'))
      .width(20)
      .height(20)
      .objectFit(ImageFit.Contain)
      .rotate({ angle: this.rotateAngle })
      .onAppear(() => {
        animateTo({
          duration: 1200,
          curve: Curve.EaseOut,
          iterations: -1
        }, () => {
          this.rotateAngle = 360
        })
      })
  }
}