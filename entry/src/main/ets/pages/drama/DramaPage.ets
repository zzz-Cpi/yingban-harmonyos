// 追剧页 - 多平台追剧管理（粉蓝磨砂柔和风格优化版）
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../../utils/Constants'
import { mockDramas, mockPlaylists, Drama, Playlist, createPlaylist } from '../../model/MockData'
import { VideoWebPage } from './VideoWebPage'
import { hilog } from '@kit.PerformanceAnalysisKit'
import router from '@ohos.router'

const TAG = 'DramaPage'

interface NavPathParam {
  url: string
  title: string
}

@Component
struct DramaPage {
  @State private currentTab: number = 1
  @State private currentPlaylist: number = 1
  // 新建片单弹窗状态
  @State private showCreatePlaylistDialog: boolean = false
  // 片单输入框绑定
  @State private inputPlaylistName: string = ''
  // 强制刷新片单列表响应式标记
  @State private playlistRefreshKey: number = 0

  // ========== 新增：管理模式相关状态 ==========
  @State private isManageMode: boolean = false // 是否处于管理模式
  @State private selectedDramas: Drama[] = [] // 当前选中的剧集列表
  @State private dramaRefreshKey: number = 0 // 强制刷新剧集列表标记
  @State pathStack: NavPathStack = new NavPathStack()

  private statusTabs: string[] = ['想看', '在看', '已看']

  // 辅助获取当前状态的 key
  private getCurrentStatusKey(): string {
    const statusMap: string[] = ['want', 'watching', 'finished']
    return statusMap[this.currentTab]
  }

  @Builder
  PageMap(name: string, param: Object) {
    if (name === 'VideoWebPage') {
      VideoWebPage({
        url: (param as NavPathParam).url,
        title: (param as NavPathParam).title
      })
    }
  }

  build() {
    Navigation(this.pathStack) {
      Stack() {
        // 粉蓝梦幻背景层
        Column()
          .width('100%')
          .height(200)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              [0x15FFB6C1, 0],
              [0x25FFC0CB, 0.5],
              [0x15E0F0F5, 1]
            ]
          })

        Column() {
          // 顶部状态切换栏
          this.StatusTabBar()

          // 片单筛选横栏（横向滚动正常保留）
          this.PlaylistBar()

          // 追剧卡片网格滚动区
          this.DramaGrid()

          // 根据是否为管理模式,切换底部按钮
          if (this.isManageMode) {
            this.DeleteBottomBar()
          } else {
            this.AddButton()
          }

          // 弹窗局部渲染，不拦截底层触摸
          this.CreatePlaylistDialog()
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFF5F8')
    }
    .navDestination(this.PageMap)
    .hideTitleBar(true)
  }

  // 顶部状态切换栏 - 磨砂毛玻璃柔和风格
  @Builder
  StatusTabBar() {
    Column() {
      Row() {
        Row({ space: 28 }) {
          ForEach(this.statusTabs, (tab: string, index: number) => {
            Column({ space: 6 }) {
              Text(tab)
                .fontSize(this.currentTab === index ? 20 : 16)
                .fontColor(this.currentTab === index ? '#2D2D3A' : '#9A9AA3')
                .fontWeight(this.currentTab === index ? FontWeightValue.bold : FontWeightValue.medium)

              // 粉蓝渐变指示条
              Row()
                .width(20)
                .height(3)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
                })
                .borderRadius(2)
                .opacity(this.currentTab === index ? 1 : 0)
            }
            .onClick(() => {
              if (this.isManageMode) return
              this.currentTab = index
            })
          })
        }
        .layoutWeight(1)

        // 管理按钮 - 磨砂柔和
        Text(this.isManageMode ? '完成' : '管理')
          .fontSize(FontSizes.caption)
          .fontColor(this.isManageMode ? '#FFB6C1' : '#9A9AA3')
          .padding({ left: 12, top: 6, bottom: 6, right: 12 })
          .backgroundColor(this.isManageMode ? 'rgba(255,182,193,0.15)' : 'rgba(255,240,245,0.5)')
          .backdropBlur(10)
          .borderRadius(12)
          .onClick(() => {
            this.isManageMode = !this.isManageMode
            if (!this.isManageMode) {
              this.selectedDramas = []
            }
          })
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.sm })
    }
    .backgroundColor('rgba(255,240,245,0.6)')
    .backdropBlur(20)
  }

  @Builder
  PlaylistBar() {
    Column() {
      Scroll() {
        Row({ space: Spacing.md }) {
          // ========== 【全部】特殊标签 - 粉蓝柔和磨砂优化 ==========
          Row() {
            Text('全部')
              .fontSize(FontSizes.caption)
              .fontColor(this.currentPlaylist === 1 ? Color.White : '#2D2D3A')

            // 统计全部剧集总数
            if (!this.isManageMode) {
              Text(this.getPlaylistTotal(0, this.getCurrentStatusKey()).toString())
                .fontSize(10)
                .fontColor(Color.White)
                .backgroundColor(this.currentPlaylist === 1 ? 'rgba(255,255,255,0.3)' : 'rgba(176,224,230,0.5)')
                .borderRadius(10)
                .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                .margin({ left: 4 })
            }
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          // 粉蓝磨砂半透明效果
          .backgroundColor(this.currentPlaylist === 1 ? 'rgba(0,0,0,0.01)' : 'rgba(255,240,245,0.6)')
          .backdropBlur(15)
          .borderRadius(14)
          .border({ width: 1, color: this.currentPlaylist === 1 ? 'rgba(255,182,193,0.5)' : 'rgba(176,224,230,0.3)' })
          .linearGradient(this.currentPlaylist === 1 ? {
            direction: GradientDirection.Right,
            colors: [[0x80FFB6C1, 0], [0x80B0E0E6, 1]]
          } : {
            direction: GradientDirection.Right,
            colors: [[0x15FFB6C1, 0], [0x15B0E0E6, 1]]
          })
          .onClick(() => {
            if (!this.isManageMode) this.currentPlaylist = 1
          })

          // ========== 自定义片单循环渲染（粉蓝磨砂优化）==========
          ForEach(mockPlaylists, (playlist: Playlist) => {
            Row() {
              Text(playlist.name)
                .fontSize(FontSizes.caption)
                .fontColor(this.currentPlaylist === playlist.id ? Color.White : '#2D2D3A')

              // ========== 修改：管理模式下显示删除小叉，非管理模式显示数量 ==========
              if (this.isManageMode) {
                Text('×')
                  .fontSize(12)
                  .fontWeight(FontWeightValue.bold)
                  .fontColor(Color.White)
                  .backgroundColor('#FF6B9D') // 柔和粉红色删除按钮
                  .borderRadius(10)
                  .width(16)
                  .height(16)
                  .textAlign(TextAlign.Center)
                  .margin({ left: 6 })
                  .onClick(() => {
                    // 删除片单逻辑
                    const index = mockPlaylists.findIndex((p: Playlist) => p.id === playlist.id)
                    if (index > -1) {
                      mockPlaylists.splice(index, 1)
                      // 如果删除的是当前选中的片单，回退到"全部"
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
                  .backgroundColor(this.currentPlaylist === playlist.id ? 'rgba(255,255,255,0.3)' : 'rgba(176,224,230,0.5)')
                  .borderRadius(10)
                  .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                  .margin({ left: 4 })
              }
            }
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            // 粉蓝磨砂半透明效果
            .backgroundColor(this.currentPlaylist === playlist.id ? 'rgba(0,0,0,0.01)' : 'rgba(255,240,245,0.6)')
            .backdropBlur(10)
            .borderRadius(BorderRadius.small)
            .border({
              width: 1,
              color: this.currentPlaylist === playlist.id ? 'rgba(255,182,193,0.5)' : 'rgba(176,224,230,0.3)'
            })
            .linearGradient(this.currentPlaylist === playlist.id ? {
              direction: GradientDirection.Right,
              colors: [[0x80FFB6C1, 0], [0x80B0E0E6, 1]]
            } : {
              direction: GradientDirection.Right,
              colors: [[0x15FFB6C1, 0], [0x15B0E0E6, 1]]
            })
            .onClick(() => {
              if (!this.isManageMode) this.currentPlaylist = playlist.id
            })
          }, (item: Playlist) => item.id.toString() + this.playlistRefreshKey.toString())

          // 新建片单按钮（粉蓝磨砂优化，管理模式下隐藏）
          if (!this.isManageMode) {
            Row() {
              Text('+')
                .fontSize(FontSizes.body)
                .fontColor('#2D2D3A')

              Text('新建')
                .fontSize(FontSizes.caption)
                .fontColor('#2D2D3A')
                .margin({ left: 2 })
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('rgba(255,240,245,0.6)')
            .backdropBlur(10)
            .borderRadius(BorderRadius.small)
            .border({ width: 1, color: 'rgba(176,224,230,0.5)', style: BorderStyle.Dashed })
            .onClick(() => {
              this.inputPlaylistName = ''
              this.showCreatePlaylistDialog = true
            })
          }
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
    .backgroundColor('rgba(255,255,255,0.6)') // 粉蓝磨砂背景优化
    .backdropBlur(15)
  }

  private getPlaylistTotal(targetId: number, statusKey: string): number {
    let list = mockDramas.filter((item: Drama) => item.status === statusKey)
    if(targetId === 0){
      return list.length
    }
    return list.filter((item: Drama) => item.playlistId === targetId).length
  }

  @Builder
  DramaGrid() {
    Scroll() {
      Grid() {
        ForEach(this.getFilteredDramas(), (drama: Drama) => {
          GridItem() {
            this.DramaCard(drama)
          }
          // 防止某些卡片高度不一致导致上下错位，强制顶部对齐
          .align(Alignment.Top)
        }, (drama: Drama) => drama.movie.title + this.dramaRefreshKey.toString() + this.isManageMode.toString())
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Spacing.md)
      .rowsGap(Spacing.md)
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.lg, bottom: 80 })
      // 【核心修复】：强制 Grid 占满整个 Scroll 的宽度
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    // 确保 Scroll 内部内容整体靠上显示
    .align(Alignment.TopStart)
  }

  private getPosterResource(name: string): Resource | string {
    if (name.startsWith('http')) {
      return name
    }
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

  // DramaCard - 磨砂半透明柔和卡片优化
  @Builder
  DramaCard(drama: Drama) {
    Column() {
      // 1. 图片与标签层（紧贴顶部）
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.getPosterResource(drama.movie.posterUrl))
          .width('100%')
          .height(160)
          // 【修改点】：只保留顶部两个圆角，底部直角，这样能完美贴合卡片边缘
          .borderRadius({
            topLeft: 20, // 粉蓝大圆角优化
            topRight: 20,
            bottomLeft: 0,
            bottomRight: 0
          })
          .objectFit(ImageFit.Cover)
          // 【附加优化】：如果海报太长被截断，加这行能让画面从"顶部"开始裁剪，防止人物切头
          .align(Alignment.Top)
          .backgroundColor('#E8E8F0')

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
          .margin(8) // 稍微加大一点 margin，因为现在紧贴边缘了
          .borderRadius(11)
          .border({ width: 1.5, color: Color.White })
          .backgroundColor(this.selectedDramas.includes(drama) ? '#FFB6C1' : 'rgba(176,224,230,0.5)') // 粉蓝柔和选中态
          .justifyContent(FlexAlign.Center)
        } else {
          Text(this.getStatusText(drama.status))
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.getStatusColor(drama.status))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius({ topRight: 20, bottomLeft: 8 }) // 粉蓝圆角优化
        }
      }

      // 2. 文字和进度条区域（单独包裹并加上内边距）
      Column() {
        Text(drama.movie.title)
          .fontSize(FontSizes.caption)
          .fontColor('#2D2D3A')
          .margin({ top: Spacing.sm })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 4 }) {
          ForEach(drama.movie.platform.slice(0, 2), (p: string) => {
            Text(p)
              .fontSize(10)
              .fontColor('#9A9AA3')
          })
        }
        .margin({ top: 2 })
        .width('100%')

        if (drama.status === 'watching') {
          Column() {
            Row() {
              Text('更新至' + drama.currentEpisode + '/' + drama.totalEpisodes + '集')
                .fontSize(FontSizes.helper)
                .fontColor('#9A9AA3')
            }
            .width('100%')
            .margin({ bottom: 4 })

            Stack() {
              Row()
                .width('100%')
                .height(4)
                .backgroundColor('rgba(176,224,230,0.3)') // 浅青蓝进度条底色
                .borderRadius(2)

              Row()
                .width(drama.watchProgress + '%')
                .height(4)
                .linearGradient({ // 粉蓝渐变进度条
                  direction: GradientDirection.Right,
                  colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
                })
                .borderRadius(2)
            }
            .alignContent(Alignment.Start) // 确保进度条从左边开始
          }
          .width('100%')
          .margin({ top: Spacing.sm })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Spacing.sm, right: Spacing.sm, bottom: Spacing.sm }) // 【修改点】：把外层的边距移到这里，保护文字
    }
    .width('100%')
    // 磨砂半透明卡片背景 + 柔和阴影
    .backgroundColor('rgba(255,255,255,0.75)')
    .backdropBlur(20)
    .borderRadius(20) // 粉蓝大圆角优化
    .border({ width: 1, color: 'rgba(255,182,193,0.15)' }) // 柔和粉蓝边框
    .shadow({ radius: 8, color: 'rgba(255,182,193,0.1)', offsetX: 0, offsetY: 2 }) // 极淡柔和阴影
    // .padding(Spacing.sm) <--- 【修改点】：删掉了这里的全局 padding，让图片能碰到边缘
    .onClick(() => {
      if (this.isManageMode) {
        const isSelected = this.selectedDramas.includes(drama)
        if (isSelected) {
          this.selectedDramas = this.selectedDramas.filter((d: Drama) => d !== drama)
        } else {
          this.selectedDramas.push(drama)
        }
      } else {
        this.onDramaClick(drama)
      }
    })
  }

  // AddButton - 粉蓝渐变圆形磨砂按钮优化
  @Builder
  AddButton() {
    Column() {
      Button('+')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontColor(Color.White)
        .linearGradient({ // 粉蓝渐变填充
          direction: GradientDirection.Right,
          colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
        })
        .borderRadius(28)
        .backdropBlur(15) // 磨砂效果
        .border({ width: 1, color: 'rgba(255,182,193,0.3)' })
        .shadow({ radius: 10, color: 'rgba(255,182,193,0.2)', offsetX: 0, offsetY: 4 }) // 柔和阴影
        .onClick(() => {
          try {
            router.pushUrl({ url: 'pages/home/SearchPage' })
          } catch (err) {
            hilog.error(0, TAG, 'Navigate to search failed')
          }
        })
    }
    .position({ x: '85%', y: '80%' })
  }

  // ========== 新增：底部的删除操作栏（粉蓝柔和优化）==========
  @Builder
  DeleteBottomBar() {
    Row() {
      Button(`删除 (${this.selectedDramas.length})`)
        .width('100%')
        .height(44)
        .fontSize(FontSizes.body)
        .backgroundColor(this.selectedDramas.length > 0 ? '#FF6B9D' : '#FFAAAB') // 柔和粉红色
        .fontColor(Color.White)
        .borderRadius(20) // 粉蓝大圆角
        .backdropBlur(15)
        .border({ width: 1, color: 'rgba(255,182,193,0.3)' })
        .enabled(this.selectedDramas.length > 0)
        .onClick(() => {
          if (this.selectedDramas.length === 0) return

          // 执行多选删除逻辑
          this.selectedDramas.forEach((selectedDrama: Drama) => {
            const index = mockDramas.findIndex((d: Drama) => d === selectedDrama)
            if (index !== -1) {
              mockDramas.splice(index, 1)
            }
          })

          // 清空选中项并强制刷新 UI
          this.selectedDramas = []
          this.dramaRefreshKey += 1
          this.playlistRefreshKey += 1 // 删除剧集会影响片单数量，需要同步刷新
        })
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.sm, bottom: Spacing.lg })
    .backgroundColor('rgba(255,255,255,0.6)') // 磨砂半透明背景
    .backdropBlur(20)
    .border({ width: { top: 1 }, color: 'rgba(255,182,193,0.2)' })
  }

  // CreatePlaylistDialog - 粉蓝磨砂弹窗优化
  @Builder
  CreatePlaylistDialog() {
    if (this.showCreatePlaylistDialog) {
      Stack() {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(255,182,193,0.2)') // 柔和粉色半透明遮罩
          .onClick(() => this.showCreatePlaylistDialog = false)

        Column() {
          Text('新建片单')
            .fontSize(FontSizes.pageTitle)
            .fontWeight(FontWeightValue.semibold)
            .fontColor('#2D2D3A')
            .margin({ bottom: Spacing.lg })

          TextInput({ text: this.inputPlaylistName, placeholder: '请输入片单名称' })
            .width('100%')
            .height(44)
            .backgroundColor('rgba(255,240,245,0.6)') // 粉蓝磨砂输入框
            .backdropBlur(10)
            .borderRadius(14)
            .border({ width: 1, color: 'rgba(255,182,193,0.3)' })
            .padding({ left: Spacing.md, right: Spacing.md })
            .onChange((val: string) => this.inputPlaylistName = val)
            .margin({ bottom: Spacing.xl })

          Row({ space: Spacing.md }) {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .fontColor('#9A9AA3')
              .backgroundColor('rgba(255,240,245,0.6)') // 粉蓝磨砂取消按钮
              .backdropBlur(10)
              .borderRadius(14)
              .border({ width: 1, color: 'rgba(176,224,230,0.3)' })
              .onClick(() => this.showCreatePlaylistDialog = false)

            Button('确认创建')
              .layoutWeight(1)
              .height(44)
              .fontColor(Color.White)
              .linearGradient({ // 粉蓝渐变确认按钮
                direction: GradientDirection.Right,
                colors: [['#FFB6C1', 0], ['#B0E0E6', 1]]
              })
              .borderRadius(14)
              .onClick(() => {
                const name = this.inputPlaylistName.trim()
                if (name.length === 0) return
                const maxId = mockPlaylists.reduce((max: number, item: Playlist) => item.id > max ? item.id : max, 0)
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
        .backgroundColor('rgba(255,255,255,0.85)') // 磨砂半透明弹窗背景
        .backdropBlur(25)
        .borderRadius(20) // 粉蓝大圆角
        .border({ width: 1, color: 'rgba(255,182,193,0.2)' })
        .shadow({ radius: 15, color: 'rgba(255,182,193,0.15)', offsetX: 0, offsetY: 5 }) // 柔和阴影
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }

  private onDramaClick(drama: Drama): void {
    try {
      const title: string = drama.movie.title
      let url: string = ''

      const videoUrlMap: Record<string, string> = {
        '繁花': 'https://v.qq.com/x/cover/mzc00200whsp9r6/a0047l69jnp.html',
        '庆余年 第二季': 'https://v.qq.com/x/cover/mzc002002kqssyu/q4100dpkd26.html',
        '飞驰人生2': 'https://v.qq.com/x/cover/mzc00200rx67svy/q410050ws4m.html',
        '我的阿勒泰': 'https://www.iqiyi.com/v_al19ckpf80.html?e2=34da212765549d56104655c3840d8101&qyTrace=M0w49LfPEN3A1HS5',
        '狂飙': 'https://www.iqiyi.com/v_xkt6z3z798.html?e2=5aba21b5552e3aa8f1e5d77a4441c53d&qyTrace=ALfGPhHdI9NOWylA',
        '琅琊榜': 'https://w.yangshipin.cn/video?type=0&vid=s0000251n05&channel=txsp_quanwangsou'
      }

      if (videoUrlMap[title]) {
        url = videoUrlMap[title]
      } else {
        const encodedTitle: string = encodeURIComponent(title)
        url = `https://v.qq.com/x/search/?q=${encodedTitle}`
      }

      const param: NavPathParam = {
        url: url,
        title: title
      }
      this.pathStack.pushPath({
        name: 'VideoWebPage',
        param: param
      })
    } catch (err) {
      hilog.error(0, TAG, 'Open video web page failed')
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
    if (status === 'want') return '想看'
    if (status === 'watching') return '在看'
    if (status === 'finished') return '已看'
    return status
  }

  private getStatusColor(status: string): string {
    if (status === 'want') return '#FFB6C1' // 柔和粉色
    if (status === 'watching') return '#B0E0E6' // 柔和浅青蓝
    if (status === 'finished') return '#E8E8F0' // 柔和灰紫
    return '#9A9AA3'
  }
}

export default DramaPage