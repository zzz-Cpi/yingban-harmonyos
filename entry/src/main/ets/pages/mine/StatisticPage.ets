import router from '@ohos.router';

class Point {
  x: number;
  y: number;
  constructor(x: number, y: number) { this.x = x; this.y = y; }
}

class PieItem {
  name: string;
  percent: number;
  color: string;
  constructor(name: string, percent: number, color: string) {
    this.name = name; this.percent = percent; this.color = color;
  }
}

class RankItem {
  name: string;
  hours: number;
  color: string;
  constructor(name: string, hours: number, color: string) {
    this.name = name; this.hours = hours; this.color = color;
  }
}

class RoomItem {
  name: string;
  duration: string;
  constructor(name: string, duration: string) {
    this.name = name; this.duration = duration;
  }
}

@Entry
@Component
struct StatisticPage {
  @State selectedDate: Date = new Date("2026-07-03")
  @State currentUsage: number = 128
  @State currentTab: number = 0
  @State wallOffsetX: number = 0

  private tabs: string[] = ['时长趋势', '房间统计', '影片分布', '好友排行']

  getDataByDate(date: Date): number {
    let seed = date.getFullYear() + date.getMonth() * 37 + date.getDate() * 17;
    return 30 + (seed % 180);
  }

  formatDate(date: Date): string { return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}` }

  build() {
    Column() {
      Row() {
        Text("<").fontSize(22).fontWeight(FontWeight.Bold).onClick(() => router.back())
        Text("数据统计").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text(" ").width(24)
      }.width('100%').padding({ top: 40, bottom: 15, left: 20, right: 20 })

      Scroll() {
        Column({ space: 15 }) {
          this.TopProfileAndDynamicCard()
          this.DateBar()
          this.ChartArea()
          this.BottomScrollArea()
        }.padding({ bottom: 40 }).width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#E1F5FE', 0.0], ['#F2E7E9', 0.4], ['#F2E7E9', 1.0]]
    })
  }

  @Builder TopProfileAndDynamicCard() {
    Column() {
      Row({ space: 15 }) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(56)
            .height(56)
            .borderRadius(28)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
            })
            .backdropBlur(15)

          Text("追")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        Column({ space: 6 }) {
          Text("追剧少年").fontSize(20).fontWeight(FontWeight.Bold).fontColor('#332225')
          Text("累计观看904小时").fontSize(13).fontColor('#665558')
        }.alignItems(HorizontalAlign.Start)
      }.width('92%').padding({ left: 10, bottom: 10 }).justifyContent(FlexAlign.Start)

      Stack({ alignContent: Alignment.Top }) {

        Column() {
          Row() {
            this.CollageGroup()
            this.CollageGroup()
          }
          .height('100%')
          .translate({ x: this.wallOffsetX })
          .onAppear(() => {
            animateTo({ duration: 30000, curve: Curve.Linear, iterations: -1 }, () => { this.wallOffsetX = -560 })
          })
        }
        .width('100%').height(160).clip(true)

        Stack() {
          Progress({ value: this.currentUsage, total: 240, type: ProgressType.Ring })
            .width(160).height(160).style({ strokeWidth: 14, enableSmoothEffect: true })
            .color(new LinearGradient([{ color: '#4ECDC4', offset: 0 }, { color: '#A29BFE', offset: 1 }]))
            .rotate({ angle: 135 })

          Column() {
            Text(`${this.currentUsage}`).fontSize(38).fontWeight(FontWeight.Bold).fontColor('#332225')
            Text("今日观看(分)").fontSize(12).fontColor('#554447')
          }
        }
        .width('92%').height(190)
        .margin({ top: 100 })
        .backgroundColor('rgba(255, 255, 255, 0.45)')
        .backdropBlur(30)
        .borderRadius(24)
        .shadow({ radius: 15, color: 'rgba(0,0,0,0.06)', offsetY: 8 })
      }
      .width('100%').height(300)
    }.width('100%')
  }

  @Builder CollageGroup() {
    Row({ space: 4 }) {
      Image($r('app.media.poster_bushanliang')).width(160).height(160).objectFit(ImageFit.Cover).borderRadius(12)
      Column({ space: 4 }) {
        Image($r('app.media.poster_dahongbao')).width(130).height(78).objectFit(ImageFit.Cover).borderRadius(12)
        Image($r('app.media.poster_diershitiao')).width(130).height(78).objectFit(ImageFit.Cover).borderRadius(12)
      }
      Image($r('app.media.poster_langyabang')).width(110).height(160).objectFit(ImageFit.Cover).borderRadius(12)
      Column({ space: 4 }) {
        Image($r('app.media.poster_feichi')).width(140).height(95).objectFit(ImageFit.Cover).borderRadius(12)
        Image($r('app.media.poster_qingyunian')).width(140).height(61).objectFit(ImageFit.Cover).borderRadius(12)
      }
    }
    .height(160).padding({ right: 4 })
  }

  @Builder DateBar() {
    Row() {
      Text("←").fontSize(20).fontColor('#554447').padding(10).onClick(() => {
        let d = new Date(this.selectedDate); d.setDate(d.getDate() - 1);
        this.selectedDate = d; this.currentUsage = this.getDataByDate(d);
      })
      Text(this.formatDate(this.selectedDate)).fontSize(16).fontWeight(FontWeight.Bold).padding(10)
        .onClick(() => CalendarPickerDialog.show({ selected: this.selectedDate, onAccept: (v: Date) => {
          this.selectedDate = v; this.currentUsage = this.getDataByDate(v);
        } }))
      Text("→").fontSize(20).fontColor('#554447').padding(10).onClick(() => {
        let d = new Date(this.selectedDate); d.setDate(d.getDate() + 1);
        this.selectedDate = d; this.currentUsage = this.getDataByDate(d);
      })
    }.width('100%').justifyContent(FlexAlign.Center)
  }

  @Builder ChartArea() {
    Column() {
      Column({ space: 12 }) {
        Text("观影趋势概况").fontSize(16).fontWeight(FontWeight.Bold)
        Row({ space: 8 }) {
          ForEach(this.tabs, (item: string, index: number) => {
            Text(item).fontSize(12).padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.currentTab === index ? '#4ECDC4' : 'rgba(255,255,255,0.4)')
              .fontColor(this.currentTab === index ? Color.White : '#554447')
              .borderRadius(12).animation({ duration: 300 })
              .onClick(() => this.currentTab = index)
          })
        }.width('100%').justifyContent(FlexAlign.Start).padding({ left: 6 })

        Stack() {
          if (this.currentTab === 0) {
            ScrollLineChart()
          } else if (this.currentTab === 1) {
            RoomList()
          } else if (this.currentTab === 2) {
            CanvasPieChart()
          } else if (this.currentTab === 3) {
            RankList()
          }
        }
        .width('100%').height(220)
        .backgroundColor('rgba(255,255,255,0.8)')
        .backdropBlur(10).borderRadius(20)
      }
      .width('92%').alignItems(HorizontalAlign.Start)
    }.width('100%')
  }

  @Builder BottomScrollArea() {
    Column({ space: 12 }) {
      Column() { Text("时光数据").fontSize(16).fontWeight(FontWeight.Bold) }.width('92%').alignItems(HorizontalAlign.Start)
      Scroll() {
        Row({ space: 16 }) {
          this.StatCard("累计时长", "904h", "#FF6B6B")
          this.StatCard("追剧总数", "18部", "#4ECDC4")
          this.StatCard("偏好类型", "古装", "#FFE66D")
          this.StatCard("观影房间", "3个", "#42A5F5")
        }.padding({ left: '4%', right: '4%' })
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%')
    }.width('100%')
  }

  @Builder StatCard(title: string, value: string, borderColor: string) {
    Column() {
      Text(title).fontSize(12).fontColor('#99888C')
      Text(value).fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 8 })
    }
    .width(130).height(90).backgroundColor('rgba(255,255,255,0.8)')
    .backdropBlur(8).borderRadius(16).border({ width: 2, color: borderColor })
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct ScrollLineChart {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private scroller: Scroller = new Scroller()
  @State chartWidth: number = 800
  @State chartHeight: number = 0
  private data: number[] = [30, 45, 80, 60, 120, 90, 150, 120, 100, 140, 85, 110, 160, 120]
  private labels: string[] = ['6.20', '6.21', '6.22', '6.23', '6.24', '6.25', '6.26', '6.27', '6.28', '6.29', '6.30', '7.01', '7.02', '7.03']

  build() {
    Scroll(this.scroller) {
      Canvas(this.ctx)
        .width(this.chartWidth).height('100%')
        .onAreaChange((_old: Area, newValue: Area) => {
          this.chartHeight = newValue.height as number; this.drawChart();
        })
        .onReady(() => {
          this.drawChart()
          setTimeout(() => { this.scroller.scrollEdge(Edge.End) }, 100)
        })
    }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height('100%')
  }

  drawChart() {
    if (!this.ctx || this.chartHeight === 0) return;
    this.ctx.clearRect(0, 0, this.chartWidth, this.chartHeight)
    let px = 25, py = 50, w = this.chartWidth - px * 2, h = this.chartHeight - py * 2, maxVal = Math.max(...this.data, 1)
    let points: Point[] = this.data.map((val: number, i: number) => new Point(px + (i / (this.data.length - 1)) * w, py + h - (val / maxVal) * h))
    let grd = this.ctx.createLinearGradient(0, py, 0, this.chartHeight - py)
    grd.addColorStop(0, 'rgba(78, 205, 196, 0.4)'); grd.addColorStop(1, 'rgba(78, 205, 196, 0.0)')
    this.ctx.beginPath(); this.ctx.moveTo(points[0].x, this.chartHeight - py)
    points.forEach((p: Point) => this.ctx.lineTo(p.x, p.y)); this.ctx.lineTo(points[points.length-1].x, this.chartHeight - py)
    this.ctx.fillStyle = grd; this.ctx.fill()
    this.ctx.beginPath(); this.ctx.moveTo(points[0].x, points[0].y)
    points.forEach((p: Point) => this.ctx.lineTo(p.x, p.y))
    this.ctx.lineWidth = 3; this.ctx.strokeStyle = '#4ECDC4'; this.ctx.stroke()

    this.ctx.textAlign = 'center'
    points.forEach((p: Point, i: number) => {
      this.ctx.beginPath(); this.ctx.arc(p.x, p.y, 4, 0, Math.PI * 2); this.ctx.fillStyle = '#FFF'; this.ctx.fill(); this.ctx.lineWidth = 2; this.ctx.strokeStyle = '#4ECDC4'; this.ctx.stroke()
      this.ctx.fillStyle = '#99888C'; this.ctx.font = '13px sans-serif'; this.ctx.fillText(this.labels[i], p.x, this.chartHeight - 15)
      this.ctx.fillStyle = '#554447'; this.ctx.font = 'bold 18px sans-serif'; this.ctx.fillText(this.data[i].toString(), p.x, p.y - 15)
    })
  }
}

@Component
struct RoomList {
  private data: RoomItem[] = [
    new RoomItem("家明GG的放映厅", "24.5小时"),
    new RoomItem("猪是念来过倒的房间", "18.2小时"),
    new RoomItem("Tim Wang的观影室", "12.0小时"),
    new RoomItem("周末宅家一起看", "8.5小时")
  ]

  build() {
    List({ space: 15 }) {
      ForEach(this.data, (item: RoomItem, index: number) => {
        ListItem() {
          Row({ space: 15 }) {
            Text(`${index + 1}`).fontSize(16).fontColor('#99888C').fontWeight(FontWeight.Medium).width(20).textAlign(TextAlign.Center)
            Text(item.name).fontSize(14).fontColor('#332225').fontWeight(FontWeight.Medium).layoutWeight(1)
            Text(`一起观看 ${item.duration}`).fontSize(12).fontColor('#99888C')
          }.width('100%').padding({ left: 20, right: 20 })
        }
      })
    }.width('100%').height('100%').padding({ top: 20, bottom: 20 })
  }
}

@Component
struct CanvasPieChart {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State chartWidth: number = 0; @State chartHeight: number = 0
  private data: PieItem[] = [
    new PieItem("古装", 40, "#4ECDC4"), new PieItem("悬疑", 30, "#FFE66D"),
    new PieItem("喜剧", 20, "#FF6B6B"), new PieItem("科幻", 10, "#A29BFE")
  ]

  build() {
    Row() {
      Canvas(this.ctx).width('55%').height('100%').onAreaChange((_o: Area, n: Area) => {
        this.chartWidth = n.width as number; this.chartHeight = n.height as number; this.drawChart();
      }).onReady(() => { this.drawChart() })
      Column({ space: 15 }) {
        ForEach(this.data, (item: PieItem) => {
          Row({ space: 8 }) {
            Circle({ width: 12, height: 12 }).fill(item.color)
            Text(item.name).fontSize(14).fontColor('#554447').width(40)
            Text(`${item.percent}%`).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#332225')
          }.width('100%').justifyContent(FlexAlign.Start)
        })
      }.width('45%').padding({ left: 10 }).justifyContent(FlexAlign.Center)
    }.width('100%').height('100%')
  }

  drawChart() {
    if (!this.ctx || this.chartWidth === 0) return;
    this.ctx.clearRect(0, 0, this.chartWidth, this.chartHeight);
    let cX = this.chartWidth / 2 + 10, cY = this.chartHeight / 2, r = Math.min(cX, cY) * 0.8, sA = -Math.PI / 2;
    this.data.forEach((item) => {
      let slA = (item.percent / 100) * 2 * Math.PI;
      this.ctx.beginPath(); this.ctx.moveTo(cX, cY); this.ctx.arc(cX, cY, r, sA, sA + slA); this.ctx.closePath();
      this.ctx.fillStyle = item.color; this.ctx.fill();
      this.ctx.lineWidth = 3; this.ctx.strokeStyle = '#FFFFFF'; this.ctx.stroke();
      sA += slA;
    });
    this.ctx.beginPath(); this.ctx.arc(cX, cY, r * 0.55, 0, 2 * Math.PI); this.ctx.fillStyle = '#FFFFFF'; this.ctx.fill();
  }
}

@Component
struct RankList {
  private data: RankItem[] = [
    new RankItem("李柱", 124, "#4ECDC4"), new RankItem("宇文恺", 98, "#FFE66D"),
    new RankItem("阎立德", 65, "#FF6B6B"), new RankItem("梁孝仁", 42, "#A29BFE")
  ]

  build() {
    List({ space: 15 }) {
      ForEach(this.data, (item: RankItem, index: number) => {
        ListItem() {
          Row({ space: 15 }) {
            Text(`0${index + 1}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor(index < 3 ? '#FF6B6B' : '#99888C').fontStyle(FontStyle.Italic)
            Column({ space: 6 }) {
              Row() {
                Text(item.name).fontSize(14).fontColor('#554447')
                Text(`${item.hours}h`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#332225')
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)
              Progress({ value: item.hours, total: 150, type: ProgressType.Linear }).width('100%').color(item.color).backgroundColor('#F0F0F0')
            }.layoutWeight(1)
          }.width('100%').padding({ left: 20, right: 20 })
        }
      })
    }.width('100%').height('100%').padding({ top: 20, bottom: 20 })
  }
}