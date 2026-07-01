// 追剧页 - 多平台追剧管理
import { Colors, Spacing, BorderRadius, FontSizes, FontWeightValue } from '../utils/Constants'
import { mockDramas, mockPlaylists, Drama, Playlist, createPlaylist } from '../model/MockData'

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

  private statusTabs: string[] = ['想看', '在看', '已看']

  // 辅助获取当前状态的 key
  private getCurrentStatusKey(): string {
    const statusMap: string[] = ['want', 'watching', 'finished']
    return statusMap[this.currentTab]
  }

  build() {
    Column() {
      // 顶部状态切换栏
      this.StatusTabBar()

      // 片单筛选横栏（横向滚动正常保留）
      this.PlaylistBar()

      // 追剧卡片网格滚动区
      this.DramaGrid()

      // 根据是否为管理模式，切换底部按钮
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
    .backgroundColor(Colors.background)
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
              if (this.isManageMode) return // 管理模式下禁用切换 Tab
              this.currentTab = index
            })
          })
        }
        .layoutWeight(1)

        // ========== 修改：将“共X部”改为“管理/完成”按钮 ==========
        Text(this.isManageMode ? '完成' : '管理')
          .fontSize(FontSizes.body)
          .fontColor(this.isManageMode ? Colors.primary : Colors.textSecondary)
          .padding({ left: 10, top: 4, bottom: 4 }) // 增加点击热区
          .onClick(() => {
            this.isManageMode = !this.isManageMode
            // 退出管理模式时，清空选中状态
            if (!this.isManageMode) {
              this.selectedDramas = []
            }
          })
      }
      .width('100%')
      .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.md })
      .backgroundColor(Color.White)
    }
  }

  @Builder
  PlaylistBar() {
    Column() {
      Scroll() {
        Row({ space: Spacing.md }) {
          // ========== 【全部】特殊标签 ==========
          Row() {
            Text('全部')
              .fontSize(FontSizes.caption)
              .fontColor(this.currentPlaylist === 1 ? Colors.primary : Colors.textSecondary)

            // 统计全部剧集总数 (修复了原代码未传 statusKey 的问题)
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
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.currentPlaylist === 1 ? '#FFF0F0' : '#F5F5F5')
          .borderRadius(BorderRadius.small)
          .onClick(() => {
            if (!this.isManageMode) this.currentPlaylist = 1
          })

          // ========== 自定义片单循环渲染 ==========
          ForEach(mockPlaylists, (playlist: Playlist) => {
            Row() {
              Text(playlist.name)
                .fontSize(FontSizes.caption)
                .fontColor(this.currentPlaylist === playlist.id ? Colors.primary : Colors.textSecondary)

              // ========== 修改：管理模式下显示删除小叉，非管理模式显示数量 ==========
              if (this.isManageMode) {
                Text('×')
                  .fontSize(12)
                  .fontWeight(FontWeightValue.bold)
                  .fontColor(Color.White)
                  .backgroundColor('#FF4D4F') // 红色删除按钮
                  .borderRadius(10)
                  .width(16)
                  .height(16)
                  .textAlign(TextAlign.Center)
                  .margin({ left: 6 })
                  .onClick(() => {
                    // 删除片单逻辑
                    const index = mockPlaylists.findIndex(p => p.id === playlist.id)
                    if (index > -1) {
                      mockPlaylists.splice(index, 1)
                      // 如果删除的是当前选中的片单，回退到“全部”
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
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.currentPlaylist === playlist.id ? '#FFF0F0' : '#F5F5F5')
            .borderRadius(BorderRadius.small)
            .onClick(() => {
              if (!this.isManageMode) this.currentPlaylist = playlist.id
            })
          }, (item: Playlist) => item.id.toString() + this.playlistRefreshKey.toString())

          // 新建片单按钮 (管理模式下隐藏)
          if (!this.isManageMode) {
            Row() {
              Text('+')
                .fontSize(FontSizes.body)
                .fontColor(Colors.textSecondary)

              Text('新建')
                .fontSize(FontSizes.caption)
                .fontColor(Colors.textSecondary)
                .margin({ left: 2 })
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
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
    }
    .width('100%')
    .padding({ left: Spacing.lg, right: Spacing.lg, top: Spacing.md })
    .backgroundColor(Color.White)
  }

  private getPlaylistTotal(targetId: number, statusKey: string): number {
    let list = mockDramas.filter(item => item.status === statusKey)
    if(targetId === 0){
      return list.length
    }
    return list.filter(item => item.playlistId === targetId).length
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
            topLeft: BorderRadius.large,
            topRight: BorderRadius.large,
            bottomLeft: 0,
            bottomRight: 0
          })
          .objectFit(ImageFit.Cover)
          // 【附加优化】：如果海报太长被截断，加这行能让画面从“顶部”开始裁剪，防止人物切头
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
          .margin(8) // 稍微加大一点 margin，因为现在紧贴边缘了
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

      // 2. 文字和进度条区域（单独包裹并加上内边距）
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
    .backgroundColor(Color.White)
    .borderRadius(BorderRadius.large)
    // .padding(Spacing.sm) <--- 【修改点】：删掉了这里的全局 padding，让图片能碰到边缘
    .onClick(() => {
      if (this.isManageMode) {
        const isSelected = this.selectedDramas.includes(drama)
        if (isSelected) {
          this.selectedDramas = this.selectedDramas.filter(d => d !== drama)
        } else {
          this.selectedDramas.push(drama)
        }
      } else {
        // 非管理模式：原有的跳转详情逻辑预留
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
        .onClick(() => {
          // 添加追剧逻辑预留
        })
    }
    .position({ x: '85%', y: '80%' })
  }

  // ========== 新增：底部的删除操作栏 ==========
  @Builder
  DeleteBottomBar() {
    Row() {
      Button(`删除 (${this.selectedDramas.length})`)
        .width('100%')
        .height(44)
        .fontSize(FontSizes.body)
        .backgroundColor(this.selectedDramas.length > 0 ? '#FF4D4F' : '#FFAAAB') // 选中时变亮红色，未选中暗红色
        .fontColor(Color.White)
        .borderRadius(BorderRadius.large)
        .enabled(this.selectedDramas.length > 0)
        .onClick(() => {
          if (this.selectedDramas.length === 0) return

          // 执行多选删除逻辑
          this.selectedDramas.forEach(selectedDrama => {
            const index = mockDramas.findIndex(d => d === selectedDrama)
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
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#EEEEEE' })
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
    if (status === 'want') return Colors.warning
    if (status === 'watching') return Colors.primary
    if (status === 'finished') return Colors.success
    return Colors.textSecondary
  }
}

export default DramaPage