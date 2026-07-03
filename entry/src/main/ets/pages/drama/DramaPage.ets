// 追剧页 - 多平台追剧管理
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockDramas, mockPlaylists, Drama, Playlist, createPlaylist } from '../../model/MockData'
import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'


@Component
struct DramaPage {
  @State private currentTab: number = 0
  @State private currentPlaylist: number = 1

  // 新建片单弹窗状态
  @State private showCreatePlaylistDialog: boolean = false
  @State private inputPlaylistName: string = ''
  @State private playlistRefreshKey: number = 0

  // ========== 管理模式相关状态 ==========
  @State private isManageMode: boolean = false // 是否处于管理模式
  @State private selectedDramas: Drama[] = [] // 当前选中的剧集列表
  @State private dramaRefreshKey: number = 0 // 强制刷新剧集列表标记

  // ========== 自定义移动弹窗状态 ==========
  @State private showMoveDialog: boolean = false
  @State private targetMovePlaylistId: number = -1 // 记录当前选中的目标片单ID

  // 悬浮球坐标状态
  @State private btnX: number = 320
  @State private btnY: number = 600
  private startX: number = 280
  private startY: number = 550

  private statusTabs: string[] = ['待看', '在追', '追完']

  // 辅助获取当前状态的 key
  private getCurrentStatusKey(): string {
    const statusMap: string[] = ['want', 'watching', 'finished']
    return statusMap[this.currentTab]
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        this.StatusTabBar()
        this.PlaylistBar()
        this.DramaGrid()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.background)

      // 将悬浮球作为 Stack 的子元素，确保它在最上层
      if (!this.isManageMode) {
        this.AddButton()
      }

      // 底部操作栏（删除/移动）
      if (this.isManageMode) {
        this.ActionBottomBar()
      }

      // 弹窗层级，放在最后保证覆盖全局
      this.CreatePlaylistDialog()
      this.MovePlaylistDialog()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatusTabBar() {
    Column() {
      Row() {
        Row() {
          ForEach(this.statusTabs, (tab: string, index: number) => {
            Column() {
              Text(tab)
                .fontSize(FontSizes.body)
                .fontColor(this.currentTab === index ? Colors.primary : Colors.textSecondary)
                .fontWeight(this.currentTab === index ? FontWeightValue.semibold : FontWeightValue.regular)

              if (this.currentTab === index) {
                Row()
                  .width(24)
                  .height(3)
                  .backgroundColor(Colors.primary)
                  .borderRadius(2)
                  .margin({ top: 4 })
              }
            }
            .width(60)
            .onClick(() => {
              if (this.isManageMode) return
              this.currentTab = index
            })
          })
        }
        .layoutWeight(1)

        Text(this.isManageMode ? '完成' : '管理')
          .fontSize(FontSizes.body)
          .fontColor(this.isManageMode ? Colors.primary : Colors.textSecondary)
          .padding({ left: 10, top: 4, bottom: 4 })
          .onClick(() => {
            this.isManageMode = !this.isManageMode
            if (!this.isManageMode) {
              this.selectedDramas = []
            }
          })
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: 8, bottom: 8 })
      .backgroundColor(Colors.background)
    }
  }

  @Builder
  PlaylistBar() {
    Column() {
      Scroll() {
        Row({ space: Spacing.md }) {
          Row() {
            Text('全部')
              .fontSize(FontSizes.caption)
              .fontColor(this.currentPlaylist === 1 ? Colors.primary : Colors.textSecondary)

            if (!this.isManageMode) {
              Text(this.getPlaylistTotal(0, this.getCurrentStatusKey()).toString())
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor(this.currentPlaylist === 1 ? Colors.primary : Colors.textTertiary)
                .borderRadius(10)
                .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                .margin({ left: 4 })
            }
          }
          .height(32)
          .padding({ left: 12, right: 12 })
          .alignItems(VerticalAlign.Center)
          .backgroundColor(this.currentPlaylist === 1 ? '#FFF0F0' : '#F5F5F5')
          .borderRadius(BorderRadius.small)
          .onClick(() => {
            if (!this.isManageMode) this.currentPlaylist = 1
          })

          ForEach(mockPlaylists, (playlist: Playlist) => {
            Row() {
              Text(playlist.name)
                .fontSize(FontSizes.caption)
                .fontColor(this.currentPlaylist === playlist.id ? Colors.primary : Colors.textSecondary)

              if (this.isManageMode) {
                Text('×')
                  .fontSize(12)
                  .fontWeight(FontWeightValue.bold)
                  .fontColor(Color.White)
                  .backgroundColor('#FF4D4F')
                  .borderRadius(10)
                  .width(16)
                  .height(16)
                  .textAlign(TextAlign.Center)
                  .margin({ left: 6 })
                  .onClick(() => {
                    const index = mockPlaylists.findIndex(p => p.id === playlist.id)
                    if (index > -1) {
                      mockPlaylists.splice(index, 1)
                      if (this.currentPlaylist === playlist.id) {
                        this.currentPlaylist = 1
                      }
                      this.playlistRefreshKey += 1
                    }
                  })
              } else if (this.getPlaylistTotal(playlist.id, this.getCurrentStatusKey()) > 0) {
                Text(this.getPlaylistTotal(playlist.id, this.getCurrentStatusKey()).toString())
                  .fontSize(10)
                  .fontColor(Color.White)
                  .backgroundColor(this.currentPlaylist === playlist.id ? Colors.primary : Colors.textTertiary)
                  .borderRadius(10)
                  .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                  .margin({ left: 4 })
              }
            }
            .height(32)
            .padding({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center)
            .backgroundColor(this.currentPlaylist === playlist.id ? '#FFF0F0' : '#F5F5F5')
            .borderRadius(BorderRadius.small)
            .onClick(() => {
              if (!this.isManageMode) this.currentPlaylist = playlist.id
            })
          }, (item: Playlist) => item.id.toString() + this.playlistRefreshKey.toString())

          if (!this.isManageMode) {
            Row() {
              Text('+')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
              Text('新建')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
                .margin({ left: 2 })
            }
            .height(32)
            .padding({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center)
            .borderRadius(BorderRadius.small)
            .border({ width: 1, color: Colors.textTertiary, style: BorderStyle.Dashed })
            .onClick(() => {
              this.inputPlaylistName = ''
              this.showCreatePlaylistDialog = true
            })
          }
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .align(Alignment.Start)
      .width('100%')
    }
    .constraintSize({ minHeight: 44 })
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: 10, bottom: 7 })
    .backgroundColor(Colors.background)
  }

  // 计算某个片单下特定状态的剧集数量
  private getPlaylistTotal(targetId: number, statusKey: string): number {
    let list = mockDramas.filter(item => item.status === statusKey)
    if (targetId === 0) return list.length
    return list.filter(item => item.playlistId === targetId).length
  }

  // 计算某个片单下的总剧集数量（弹窗里展示用）
  private getPlaylistTotalAllStatus(targetId: number): number {
    if (targetId === 0) return mockDramas.length
    return mockDramas.filter(item => item.playlistId === targetId).length
  }

  @Builder
  DramaGrid() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 1. 底层：隐藏的到底提示文字（永远贴在页面最下方）
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.getFilteredDramas().length > 0) {
          Text('- 已经到底啦 -')
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ bottom: 16 })
        }
      }
      .width('100%')
      .height('100%')

      // 2. 上层：可滚动的剧集网格
      Scroll() {
        Column() {
          Grid() {
            ForEach(this.getFilteredDramas(), (drama: Drama) => {
              GridItem() {
                this.DramaCard(drama)
              }
              .align(Alignment.Top)
            }, (drama: Drama) => drama.movie.title + this.dramaRefreshKey.toString() + this.isManageMode.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(Spacing.md)
          .rowsGap(Spacing.md)
          // 修改处：彻底去掉了原本 bottom: 80 的留白，改为正常的标准间距
          .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg, bottom: Spacing.lg })
          .width('100%')
        }
        .width('100%')
        // 关键1：约束最小高度为 100%，确保即使只有1部剧，白色背景也能撑满全屏盖住底部的字
        .constraintSize({ minHeight: '100%' })
        // 关键2：给内容区添加与整体统一的实体背景色。用于平时完美遮挡底层的文字
        .backgroundColor(Colors.background)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      // 关键3：开启阻尼回弹效果。滑到底部继续拉伸时，内容上移，底层的字就会露出来！
      .edgeEffect(EdgeEffect.Spring)

      // 3. 空状态提示保持不变
      if (this.getFilteredDramas().length === 0) {
        Column() {
          Text('这里还没有内容哦~')
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
          Text('去添加一部剧吧')
            .fontSize(FontSizes.caption)
            .fontColor(Colors.textTertiary)
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .layoutWeight(1)
    .width('100%')
  }

  private getPosterResource(name: string): Resource | string {
    if (name.startsWith('http')) return name
    switch (name) {
      case 'poster_fanhua': return $r('app.media.poster_fanhua')
      case 'poster_qingyunian': return $r('app.media.poster_qingyunian')
      case 'poster_aletai': return $r('app.media.poster_aletai')
      case 'poster_feichi': return $r('app.media.poster_feichi')
      case 'poster_zhongdiba': return $r('app.media.poster_zhongdiba')
      case 'poster_bushanliang': return $r('app.media.poster_bushanliang')
      case 'poster_langyabang': return $r('app.media.poster_langyabang')
      case 'poster_kuangbiao': return $r('app.media.poster_kuangbiao')
      case 'poster_manchangdeji': return $r('app.media.poster_manchangdeji')
      case 'poster_waipodexinshijie': return $r('app.media.poster_waipodexinshijie')
      case 'poster_taochubaihuyuan': return $r('app.media.poster_taochubaihuyuan')
      case 'poster_meiguidagushi': return $r('app.media.poster_meiguidagushi')
      case 'poster_jinyongwuxia': return $r('app.media.poster_jinyongwuxia')
      case 'poster_moyuyunjian': return $r('app.media.poster_moyuyunjian')
      case 'poster_duhuanian': return $r('app.media.poster_duhuanian')
      case 'poster_aletai2': return $r('app.media.poster_aletai2')
      case 'poster_yanxinji': return $r('app.media.poster_yanxinji')
      case 'poster_relaguangtang': return $r('app.media.poster_relaguangtang')
      case 'poster_diershitiao': return $r('app.media.poster_diershitiao')
      case 'poster_womenyiqi': return $r('app.media.poster_womenyiqi')
      case 'poster_xiongchumo': return $r('app.media.poster_xiongchumo')
      case 'poster_hongtanxiansheng': return $r('app.media.poster_hongtanxiansheng')
      case 'poster_dahongbao': return $r('app.media.poster_dahongbao')
      case 'poster_saohei': return $r('app.media.poster_saohei')
      default: return $r('app.media.startIcon')
    }
  }

  private getDramaUrl(title: string): string {
    switch (title) {
      case '繁花': return 'https://v.qq.com/x/cover/mzc00200whsp9r6/a0047l69jnp.html'
      case '庆余年第二季':
      case '庆余年2': return 'https://v.qq.com/x/cover/mzc002002kqssyu/q4100dpkd26.html'
      case '飞驰人生2': return 'https://v.qq.com/x/cover/mzc00200rx67svy/q410050ws4m.html'
      case '我的阿勒泰': return 'https://www.iqiyi.com/v_al19ckpf80.html?e2=34da212765549d56104655c3840d8101&qyTrace=M0w49LfPEN3A1HS5'
      case '狂飙': return 'https://www.iqiyi.com/v_xkt6z3z798.html?e2=5aba21b5552e3aa8f1e5d77a4441c53d&qyTrace=ALfGPhHdI9NOWylA'
      case '琅琊榜': return 'https://w.yangshipin.cn/video?type=0&vid=s0000251n05&channel=txsp_quanwangsou'
      default: return ''
    }
  }

  @Builder
  DramaCard(drama: Drama) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.getPosterResource(drama.movie.posterUrl))
          .width('100%')
          .height(160)
          .borderRadius({
            topLeft: BorderRadius.large,
            topRight: BorderRadius.large,
            bottomLeft: 0,
            bottomRight: 0
          })
          .objectFit(ImageFit.Cover)
          .align(Alignment.Top)
          .backgroundColor('#E0E0E0')

        if (this.isManageMode) {
          Row() {
            if (this.selectedDramas.includes(drama)) {
              Text('✓')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeightValue.bold)
            }
          }
          .width(22)
          .height(22)
          .margin(8)
          .borderRadius(11)
          .border({ width: 1.5, color: Color.White })
          .backgroundColor(this.selectedDramas.includes(drama) ? Colors.primary : 'rgba(0,0,0,0.3)')
          .justifyContent(FlexAlign.Center)
        } else {
          Text(this.getStatusText(drama.status))
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getStatusColor(drama.status))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius({ topRight: BorderRadius.large, bottomLeft: BorderRadius.small })
        }
      }

      Column() {
        Text(drama.movie.title)
          .fontSize(FontSizes.caption)
          .fontColor(Colors.textPrimary)
          .margin({ top: Spacing.sm })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 4 }) {
          ForEach(drama.movie.platform.slice(0, 2), (p: string) => {
            Text(p)
              .fontSize(10)
              .fontColor(Colors.textSecondary)
          })
        }
        .margin({ top: 2 })
        .width('100%')

        if (drama.status === 'watching') {
          Column() {
            Row() {
              Text('更新至' + drama.currentEpisode + '/' + drama.totalEpisodes + '集')
                .fontSize(FontSizes.helper)
                .fontColor(Colors.textSecondary)
            }
            .width('100%')
            .margin({ bottom: 4 })

            Stack() {
              Row()
                .width('100%')
                .height(4)
                .backgroundColor('#E0E0E0')
                .borderRadius(2)

              Row()
                .width(drama.watchProgress + '%')
                .height(4)
                .backgroundColor(Colors.primary)
                .borderRadius(2)
            }
            .alignContent(Alignment.Start)
          }
          .width('100%')
          .margin({ top: Spacing.sm })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Spacing.sm, right: Spacing.sm, bottom: Spacing.sm })
    }
    .width('100%')
    .backgroundColor(Colors.cardBackground)
    .borderRadius(BorderRadius.large)
    .onClick(() => {
      if (this.isManageMode) {
        const isSelected = this.selectedDramas.includes(drama)
        if (isSelected) {
          this.selectedDramas = this.selectedDramas.filter(d => d !== drama)
        } else {
          this.selectedDramas.push(drama)
        }
      } else {
        const url = this.getDramaUrl(drama.movie.title)
        if (url) {
          let context = getContext(this) as common.UIAbilityContext
          let want: Want = {
            action: 'ohos.want.action.viewData',
            entities: ['entity.system.browsable'],
            uri: url
          }
          context.startAbility(want)
        }
      }
    })
  }

  @Builder
  AddButton() {
    Column() {
      Button('+')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontColor(Color.White)
        .backgroundColor(Colors.primary)
        .borderRadius(28)
        .shadow({ radius: 6, color: '#40000000', offsetY: 3 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/home/SearchPage' })
        })
    }
    .position({ x: this.btnX, y: this.btnY })
    .gesture(
      PanGesture()
        .onActionStart((event: GestureEvent) => {
          this.startX = this.btnX
          this.startY = this.btnY
        })
        .onActionUpdate((event: GestureEvent) => {
          let targetX = this.startX + event.offsetX
          let targetY = this.startY + event.offsetY
          this.btnX = Math.max(0, Math.min(targetX, 320))
          this.btnY = Math.max(0, Math.min(targetY, 636))
        })
        .onActionEnd(() => {
          animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            if (this.btnX < 160) this.btnX = 0
            else this.btnX = 320
          })
        })
    )
  }

  // ========== 原底部操作栏，选中前颜色已修复为一致的浅灰色 ==========
  @Builder
  ActionBottomBar() {
    Row({ space: 10 }) {
      Button('删除 (' + this.selectedDramas.length + ')')
        .layoutWeight(1)
        .height(44)
        .fontSize(FontSizes.body)
        .backgroundColor(this.selectedDramas.length > 0 ? Colors.primary : '#D9D9D9')
        .fontColor(Color.White)
        .borderRadius(BorderRadius.large)
        .enabled(this.selectedDramas.length > 0)
        .onClick(() => {
          if (this.selectedDramas.length === 0) return
          this.selectedDramas.forEach(selectedDrama => {
            const index = mockDramas.findIndex(d => d === selectedDrama)
            if (index !== -1) mockDramas.splice(index, 1)
          })
          this.selectedDramas = []
          this.dramaRefreshKey += 1
          this.playlistRefreshKey += 1
        })

      Button('移动到...')
        .layoutWeight(1)
        .height(44)
        .fontSize(FontSizes.body)
        .backgroundColor(this.selectedDramas.length > 0 ? Colors.primary : '#D9D9D9')
        .fontColor(Color.White)
        .borderRadius(BorderRadius.large)
        .enabled(this.selectedDramas.length > 0)
        .onClick(() => {
          if (this.selectedDramas.length === 0) return
          this.targetMovePlaylistId = -1 // 唤起弹窗前，重置未选择状态
          this.showMoveDialog = true
        })
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.sm, bottom: Spacing.lg })
    .backgroundColor(Colors.background)
    .border({ width: { top: 1 }, color: '#EEEEEE' })
  }

  // ========== 新增：高还原度的卡片式移动弹窗（数量统计异步更新已修复） ==========
  @Builder
  MovePlaylistDialog() {
    if (this.showMoveDialog) {
      Stack({ alignContent: Alignment.Bottom }) {
        // 背景遮罩层
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => this.showMoveDialog = false)

        // 底部内容面板
        Column() {
          // 头部：标题与新建按钮
          Row() {
            Text('选择片单')
              .fontSize(16)
              .fontWeight(FontWeightValue.semibold)
              .fontColor(Colors.textPrimary)

            Row() {
              Text('+ ')
                .fontSize(16)
                .fontColor(Colors.textSecondary)
              Text('新建片单')
                .fontSize(14)
                .fontColor(Colors.textSecondary)
            }
            .onClick(() => {
              // 点击新建，隐藏当前弹窗，呼出新建弹窗
              this.showMoveDialog = false
              this.inputPlaylistName = ''
              this.showCreatePlaylistDialog = true
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 20, right: 20, top: 20, bottom: 12 })

          // 核心列表区（白色卡片包裹）
          Column() {
            Scroll() {
              Column() {
                ForEach(mockPlaylists, (playlist: Playlist, index: number) => {
                  Column() {
                    Row() {
                      // 左侧文案
                      Column() {
                        Text(playlist.name)
                          .fontSize(16)
                          .fontColor(Colors.textPrimary)
                          .margin({ bottom: 4 })

                        // 【状态深度绑定】：混入刷新Key计算，强制ArkUI框架追踪全局数组属性变化并强制重绘
                        Text(`${this.getPlaylistTotalAllStatus(playlist.id) + (this.playlistRefreshKey * 0)}部剧集`)
                          .fontSize(12)
                          .fontColor(Colors.textSecondary)
                      }
                      .alignItems(HorizontalAlign.Start)

                      // 右侧单选框（自定义高仿Radio UI）
                      Stack({ alignContent: Alignment.Center }) {
                        Row()
                          .width(22)
                          .height(22)
                          .borderRadius(11)
                          .border({
                            width: 1.5,
                            color: this.targetMovePlaylistId === playlist.id ? Colors.primary : '#CCCCCC'
                          })
                        if (this.targetMovePlaylistId === playlist.id) {
                          Row()
                            .width(12)
                            .height(12)
                            .borderRadius(6)
                            .backgroundColor(Colors.primary)
                        }
                      }
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .alignItems(VerticalAlign.Center)
                    .padding(16)
                    .onClick(() => {
                      this.targetMovePlaylistId = playlist.id
                    })

                    // 选项之间的分割线
                    if (index < mockPlaylists.length - 1) {
                      Divider()
                        .color('#F0F0F0')
                        .strokeWidth(1)
                        .padding({ left: 16, right: 16 })
                    }
                  }
                }, (item: Playlist) => item.id.toString() + this.playlistRefreshKey.toString())
              }
            }
            .constraintSize({ maxHeight: 300 }) // 列表太长时限制高度并允许滚动
          }
          .width('92%')
          .backgroundColor(Color.White)
          .borderRadius(BorderRadius.large)
          .margin({ bottom: 20 })

          // 底部纯白完成按钮
          Text('完成')
            .width('100%')
            .height(56)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor(this.targetMovePlaylistId !== -1 ? Colors.textPrimary : Colors.textSecondary)
            .backgroundColor(Color.White)
            .onClick(() => {
              if (this.targetMovePlaylistId !== -1) {
                // 执行转移逻辑
                this.selectedDramas.forEach(drama => {
                  const index = mockDramas.findIndex(d => d === drama)
                  if (index !== -1) mockDramas[index].playlistId = this.targetMovePlaylistId
                })
                this.selectedDramas = []
                this.isManageMode = false // 操作完成后退出管理模式

                // 【核心同步】：联动刷新全局UI数据树结构
                this.dramaRefreshKey += 1
                this.playlistRefreshKey += 1
              }
              this.showMoveDialog = false
            })
        }
        .width('100%')
        .backgroundColor('#F7F7F7') // 与白色卡片形成层次感的浅灰底色
        .borderRadius({ topLeft: BorderRadius.large, topRight: BorderRadius.large })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(999) // 确保弹窗在最顶层
    }
  }

  @Builder
  CreatePlaylistDialog() {
    if (this.showCreatePlaylistDialog) {
      Stack() {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => this.showCreatePlaylistDialog = false)

        Column() {
          Text('新建片单')
            .fontSize(FontSizes.pageTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor(Colors.textPrimary)
            .margin({ bottom: Spacing.lg })

          TextInput({ text: this.inputPlaylistName, placeholder: '请输入片单名称' })
            .width('100%')
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(BorderRadius.small)
            .padding({ left: Spacing.md, right: Spacing.md })
            .onChange(val => this.inputPlaylistName = val)
            .margin({ bottom: Spacing.xl })

          Row({ space: Spacing.md }) {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .fontColor(Colors.textSecondary)
              .backgroundColor('#F5F5F5')
              .borderRadius(BorderRadius.small)
              .onClick(() => this.showCreatePlaylistDialog = false)

            Button('确认创建')
              .layoutWeight(1)
              .height(44)
              .fontColor(Color.White)
              .backgroundColor(Colors.primary)
              .borderRadius(BorderRadius.small)
              .onClick(() => {
                const name = this.inputPlaylistName.trim()
                if (name.length === 0) return
                const maxId = mockPlaylists.reduce((max, item) => item.id > max ? item.id : max, 0)
                const newPlaylist = createPlaylist(maxId + 1, name, 0)
                mockPlaylists.push(newPlaylist)
                this.currentPlaylist = newPlaylist.id
                this.playlistRefreshKey += 1
                this.showCreatePlaylistDialog = false
              })
          }
        }
        .width('85%')
        .padding(Spacing.xl)
        .backgroundColor(Color.White)
        .borderRadius(BorderRadius.large)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }

  private getFilteredDramas(): Drama[] {
    const status: string = this.getCurrentStatusKey()
    const result: Drama[] = []
    if (this.currentPlaylist === 1) {
      for (let i: number = 0; i < mockDramas.length; i++) {
        if (mockDramas[i].status === status) {
          result.push(mockDramas[i])
        }
      }
    } else {
      for (let i: number = 0; i < mockDramas.length; i++) {
        if (mockDramas[i].status === status && mockDramas[i].playlistId === this.currentPlaylist) {
          result.push(mockDramas[i])
        }
      }
    }
    return result
  }

  private getStatusText(status: string): string {
    if (status === 'want') return '待看'
    if (status === 'watching') return '在追'
    if (status === 'finished') return '追完'
    return status
  }

  private getStatusColor(status: string): string {
    if (status === 'want') return Colors.warning
    if (status === 'watching') return Colors.primary
    if (status === 'finished') return Colors.success
    return Colors.textSecondary
  }
}

export default DramaPage
