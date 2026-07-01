// Mock数据结构
import { TMDBMedia, TMDBListResponse } from './TMDBTypes'

// 影视数据
export interface Movie {
  id: number
  title: string
  posterUrl: string
  rating: number
  year: number
  category: string
  genre: string[]
  platform: string[]
  description: string
  episodeCount?: number
  videoUrl?: string
}

// 追剧数据
export interface Drama {
  id: number
  movieId: number
  movie: Movie
  status: string
  currentEpisode: number
  totalEpisodes: number
  watchProgress: number
  addedTime: number
  lastWatchTime: number
}

// 今日更新
export interface TodayUpdate {
  id: number
  title: string
  posterUrl: string
  episode: string
  platform: string
}

// 观影房间
export interface TheaterRoom {
  id: string
  name: string
  hostName: string
  memberCount: number
  maxMember: number
  status: string
  movieTitle?: string
  moviePoster?: string
  createdTime: number
}

// 房间成员
export interface RoomMember {
  id: string
  name: string
  avatar: string
  isHost: boolean
  isOnline: boolean
}

// 聊天消息
export interface ChatMessage {
  id: string
  userId: string
  userName: string
  content: string
  timestamp: number
  type: string
}

// 观影笔记
export interface Note {
  id: number
  movieId: number
  movieTitle: string
  episode: number
  timestamp: number
  content: string
  tags: string[]
  screenshot?: string
  createdTime: number
}

// 用户数据
export interface User {
  id: number
  nickname: string
  avatar: string
  totalWatchTime: number
  finishedCount: number
  achievementCount: number
}

// 分类数据
export interface Category {
  id: number
  name: string
  icon: string
}

// 片单数据
export interface Playlist {
  id: number
  name: string
  count: number
}

// ==================== Mock 数据工厂方法 ====================

export function createMovie(
  id: number,
  title: string,
  posterUrl: string,
  rating: number,
  year: number,
  category: string,
  genre: string[],
  platform: string[],
  description: string,
  episodeCount?: number,
  videoUrl?: string
): Movie {
  const m: Movie = {
    id: id,
    title: title,
    posterUrl: posterUrl,
    rating: rating,
    year: year,
    category: category,
    genre: genre,
    platform: platform,
    description: description,
    episodeCount: episodeCount,
    videoUrl: videoUrl
  }
  return m
}

export function createDrama(
  id: number,
  movieId: number,
  movie: Movie,
  status: string,
  currentEpisode: number,
  totalEpisodes: number,
  watchProgress: number,
  addedTime: number,
  lastWatchTime: number
): Drama {
  const d: Drama = {
    id: id,
    movieId: movieId,
    movie: movie,
    status: status,
    currentEpisode: currentEpisode,
    totalEpisodes: totalEpisodes,
    watchProgress: watchProgress,
    addedTime: addedTime,
    lastWatchTime: lastWatchTime
  }
  return d
}

export function createTodayUpdate(
  id: number,
  title: string,
  posterUrl: string,
  episode: string,
  platform: string
): TodayUpdate {
  const t: TodayUpdate = {
    id: id,
    title: title,
    posterUrl: posterUrl,
    episode: episode,
    platform: platform
  }
  return t
}

export function createTheaterRoom(
  id: string,
  name: string,
  hostName: string,
  memberCount: number,
  maxMember: number,
  status: string,
  createdTime: number,
  movieTitle?: string,
  moviePoster?: string
): TheaterRoom {
  const r: TheaterRoom = {
    id: id,
    name: name,
    hostName: hostName,
    memberCount: memberCount,
    maxMember: maxMember,
    status: status,
    movieTitle: movieTitle,
    moviePoster: moviePoster,
    createdTime: createdTime
  }
  return r
}

export function createNote(
  id: number,
  movieId: number,
  movieTitle: string,
  episode: number,
  timestamp: number,
  content: string,
  tags: string[],
  createdTime: number
): Note {
  const n: Note = {
    id: id,
    movieId: movieId,
    movieTitle: movieTitle,
    episode: episode,
    timestamp: timestamp,
    content: content,
    tags: tags,
    createdTime: createdTime
  }
  return n
}

export function createUser(
  id: number,
  nickname: string,
  avatar: string,
  totalWatchTime: number,
  finishedCount: number,
  achievementCount: number
): User {
  const u: User = {
    id: id,
    nickname: nickname,
    avatar: avatar,
    totalWatchTime: totalWatchTime,
    finishedCount: finishedCount,
    achievementCount: achievementCount
  }
  return u
}

export function createCategory(id: number, name: string, icon: string): Category {
  const c: Category = {
    id: id,
    name: name,
    icon: icon
  }
  return c
}

export function createPlaylist(id: number, name: string, count: number): Playlist {
  const p: Playlist = {
    id: id,
    name: name,
    count: count
  }
  return p
}

// ==================== Mock 数据 ====================

// 本地海报资源名（需在 entry/src/main/resources/base/media/ 下放对应图片）
function poster(name: string): string {
  return 'poster_' + name
}

function backdrop(name: string): string {
  return 'backdrop_' + name
}

// 公开可播放的测试视频地址
const VIDEO_URLS: string[] = [
  'https://www.w3schools.com/html/mov_bbb.mp4',
  'https://www.w3schools.com/html/movie.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
]

function getVideoUrl(id: number): string {
  return VIDEO_URLS[id % VIDEO_URLS.length]
}

function getMockMovies(): Movie[] {
  const list: Movie[] = []
  list.push(createMovie(1, '繁花', poster('fanhua'),
    8.7, 2024, 'tv', ['剧情', '爱情'], ['腾讯视频', '央视八套'], '九十年代的上海，阿宝凭借改革开放的春风和自己的努力，成为商界传奇。', 30, getVideoUrl(0)))
  list.push(createMovie(2, '庆余年 第二季', poster('qingyunian'),
    8.5, 2024, 'tv', ['古装', '权谋'], ['腾讯视频'], '范闲历经家族、江湖、庙堂的考验，书写了一段传奇人生。', 36, getVideoUrl(1)))
  list.push(createMovie(3, '我的阿勒泰', poster('aletai'),
    8.9, 2024, 'tv', ['剧情', '治愈'], ['爱奇艺'], '当都市女性回归新疆阿勒泰，与当地牧民共同生活的故事。', 8, getVideoUrl(2)))
  list.push(createMovie(4, '飞驰人生2', poster('feichi'),
    8.0, 2024, 'movie', ['喜剧', '赛车'], ['优酷', '爱奇艺'], '张驰组建了新的车队，再次冲击最后一届巴音布鲁克。', undefined, getVideoUrl(3)))
  list.push(createMovie(5, '种地吧 第二季', poster('zhongdiba'),
    8.6, 2024, 'tv', ['综艺', '真人秀'], ['爱奇艺'], '十个年轻人真实劳作，体验田间生活，见证土地的力量。', 14, getVideoUrl(0)))
  list.push(createMovie(6, '不够善良的我们', poster('bushanliang'),
    8.8, 2024, 'tv', ['剧情', '都市'], ['爱奇艺'], '两个性格迥异的女人，在四十岁的人生节点重新审视自己。', 8, getVideoUrl(1)))
  list.push(createMovie(7, '琅琊榜', poster('langyabang'),
    9.1, 2015, 'tv', ['古装', '权谋'], ['多平台'], '梅长苏以病弱之躯拨开重重迷雾，智博奸佞，昭雪冤案。', 54, getVideoUrl(2)))
  list.push(createMovie(8, '狂飙', poster('kuangbiao'),
    8.5, 2023, 'tv', ['犯罪', '剧情'], ['爱奇艺'], '京海市一线刑警安欣，与黑恶势力展开长达二十年的生死搏斗。', 39, getVideoUrl(3)))
  return list
}

export const mockMovies: Movie[] = getMockMovies()

function getMockTodayUpdates(): TodayUpdate[] {
  const list: TodayUpdate[] = []
  list.push(createTodayUpdate(101, '庆余年 第二季', poster('qingyunian'), '第28集', '腾讯视频'))
  list.push(createTodayUpdate(102, '墨雨云间', poster('moyuyunjian'), '第35集', '优酷'))
  list.push(createTodayUpdate(103, '度华年', poster('duhuanian'), '第18集', '爱奇艺'))
  list.push(createTodayUpdate(104, '颜心记', poster('yanxinji'), '第22集', '爱奇艺'))
  return list
}

export const mockTodayUpdates: TodayUpdate[] = getMockTodayUpdates()

function getMockRecommendations(): Movie[] {
  const list: Movie[] = []
  list.push(createMovie(201, '漫长的季节', poster('manchangdeji'),
    9.1, 2023, 'tv', ['悬疑', '剧情'], ['腾讯视频'], '跨越二十年的悬疑故事，一段关于命运与救赎的传奇。', undefined, getVideoUrl(0)))
  list.push(createMovie(202, '外婆的新世界', poster('waipodexinshijie'),
    8.4, 2023, 'tv', ['剧情', '公路'], ['爱奇艺'], '外婆离家出走，踏上寻找自我和世界和解的旅程。', undefined, getVideoUrl(1)))
  list.push(createMovie(203, '逃出白虎园', poster('taochubaihuyuan'),
    7.8, 2024, 'movie', ['喜剧', '悬疑'], ['院线', '优酷'], '一场意外的逃生，荒诞与现实交织的喜剧故事。', undefined, getVideoUrl(2)))
  list.push(createMovie(204, '玫瑰的故事', poster('meiguidagushi'),
    7.8, 2024, 'tv', ['都市', '爱情'], ['央视八套', '爱奇艺'], '黄亦玫二十年的人生旅程，关于爱情与成长。', undefined, getVideoUrl(3)))
  list.push(createMovie(205, '我的阿勒泰', poster('aletai2'),
    8.9, 2024, 'tv', ['剧情', '治愈'], ['爱奇艺'], '当都市女性回归新疆阿勒泰，体验另一种人生。', undefined, getVideoUrl(0)))
  list.push(createMovie(206, '金庸武侠世界', poster('jinyongwuxia'),
    7.5, 2024, 'tv', ['武侠', '古装'], ['腾讯视频'], '全新视角诠释经典武侠，重塑江湖侠义。', undefined, getVideoUrl(1)))
  return list
}

export const mockRecommendations: Movie[] = getMockRecommendations()

function getMockDramas(): Drama[] {
  const movies: Movie[] = getMockMovies()
  const list: Drama[] = []
  list.push(createDrama(1, 1, movies[0], 'watching', 28, 30, 93,
    Date.now() - 30 * 24 * 60 * 60 * 1000, Date.now() - 2 * 60 * 60 * 1000))
  list.push(createDrama(2, 2, movies[1], 'watching', 15, 36, 42,
    Date.now() - 15 * 24 * 60 * 60 * 1000, Date.now() - 24 * 60 * 60 * 1000))
  list.push(createDrama(3, 3, movies[2], 'finished', 8, 8, 100,
    Date.now() - 60 * 24 * 60 * 60 * 1000, Date.now() - 7 * 24 * 60 * 60 * 1000))
  list.push(createDrama(4, 7, movies[6], 'want', 0, 54, 0,
    Date.now() - 5 * 24 * 60 * 60 * 1000, 0))
  list.push(createDrama(5, 8, movies[7], 'finished', 39, 39, 100,
    Date.now() - 90 * 24 * 60 * 60 * 1000, Date.now() - 30 * 24 * 60 * 60 * 1000))
  list.push(createDrama(6, 4, movies[3], 'watching', 1, 1, 100,
    Date.now() - 3 * 24 * 60 * 60 * 1000, Date.now() - 3 * 24 * 60 * 60 * 1000))
  return list
}

export const mockDramas: Drama[] = getMockDramas()

function getMockPlaylists(): Playlist[] {
  const list: Playlist[] = []
  list.push(createPlaylist(1, '全部', 6))
  list.push(createPlaylist(2, '寒假补番', 3))
  list.push(createPlaylist(3, '悬疑合集', 2))
  list.push(createPlaylist(4, '下饭剧', 2))
  return list
}

export const mockPlaylists: Playlist[] = getMockPlaylists()

function getMockRooms(): TheaterRoom[] {
  const list: TheaterRoom[] = []
  list.push(createTheaterRoom('room001', '庆余年追剧团', '小李', 3, 8, 'waiting',
    Date.now() - 10 * 60 * 1000, '', ''))
  list.push(createTheaterRoom('room002', '繁花观影会', '阿明', 5, 6, 'playing',
    Date.now() - 30 * 60 * 1000, '繁花', poster('fanhua')))
  list.push(createTheaterRoom('room003', '我的阿勒泰治愈局', '小雨', 2, 4, 'waiting',
    Date.now() - 5 * 60 * 1000, '', ''))
  list.push(createTheaterRoom('room004', '狂飙二刷走起', '强哥', 6, 8, 'playing',
    Date.now() - 45 * 60 * 1000, '狂飙', poster('kuangbiao')))
  return list
}

export const mockRooms: TheaterRoom[] = getMockRooms()

function getMockRoomMembers(): RoomMember[] {
  const list: RoomMember[] = []
  list.push({ id: 'u001', name: '阿明', avatar: '', isHost: true, isOnline: true })
  list.push({ id: 'u002', name: '小李', avatar: '', isHost: false, isOnline: true })
  list.push({ id: 'u003', name: '小雨', avatar: '', isHost: false, isOnline: true })
  list.push({ id: 'u004', name: '强哥', avatar: '', isHost: false, isOnline: true })
  list.push({ id: 'u005', name: '追剧少年', avatar: '', isHost: false, isOnline: true })
  list.push({ id: 'u006', name: '电影迷', avatar: '', isHost: false, isOnline: false })
  return list
}

export const mockRoomMembers: RoomMember[] = getMockRoomMembers()

function getMockChatMessages(): ChatMessage[] {
  const list: ChatMessage[] = []
  list.push({ id: 'm001', userId: 'u001', userName: '阿明', content: '大家好，今天我们一起看繁花～', timestamp: Date.now() - 30 * 60 * 1000, type: 'text' })
  list.push({ id: 'm002', userId: 'u002', userName: '小李', content: '来啦来啦！', timestamp: Date.now() - 28 * 60 * 1000, type: 'text' })
  list.push({ id: 'm003', userId: 'u003', userName: '小雨', content: '这个剧我二刷了，超好看', timestamp: Date.now() - 25 * 60 * 1000, type: 'text' })
  list.push({ id: 'm004', userId: 'u001', userName: '阿明', content: '我开始播放啦', timestamp: Date.now() - 20 * 60 * 1000, type: 'system' })
  list.push({ id: 'm005', userId: 'u004', userName: '强哥', content: '这一段演得太好了', timestamp: Date.now() - 10 * 60 * 1000, type: 'text' })
  list.push({ id: 'm006', userId: 'u005', userName: '追剧少年', content: '爷青回！', timestamp: Date.now() - 5 * 60 * 1000, type: 'text' })
  return list
}

export const mockChatMessages: ChatMessage[] = getMockChatMessages()

function getMockCategories(): Category[] {
  const list: Category[] = []
  list.push(createCategory(1, '电影', '🎬'))
  list.push(createCategory(2, '剧集', '📺'))
  list.push(createCategory(3, '悬疑', '🔍'))
  list.push(createCategory(4, '喜剧', '😂'))
  list.push(createCategory(5, '高分', '⭐'))
  list.push(createCategory(6, '冷门', '🌙'))
  return list
}

export const mockCategories: Category[] = getMockCategories()

function getMockNotes(): Note[] {
  const list: Note[] = []
  list.push(createNote(1, 1, '繁花', 28, 1847,
    '范闲下朝后与林相对话，这段台词太精彩了！', ['名场面', '台词'],
    Date.now() - 2 * 60 * 60 * 1000))
  list.push(createNote(2, 2, '狂飙', 1, 320,
    '安欣第一次出场，这个眼神绝了', ['伏笔'],
    Date.now() - 24 * 60 * 60 * 1000))
  return list
}

export const mockNotes: Note[] = getMockNotes()

function getMockUser(): User {
  return createUser(1, '追剧少年', '', 128, 23, 7)
}

export const mockUser: User = getMockUser()

// ==================== TMDB 格式 Mock 数据（用于API失败时降级） ====================

function createMockTMDBMedia(
  id: number,
  title: string,
  posterPath: string,
  voteAverage: number,
  releaseDate: string,
  mediaType: string,
  genreIds: number[],
  trailerUrl?: string | Resource
): TMDBMedia {
  const m: TMDBMedia = {
    id: id,
    title: mediaType === 'movie' ? title : undefined,
    name: mediaType === 'tv' ? title : undefined,
    poster_path: posterPath,
    backdrop_path: posterPath,
    overview: '这是一部精彩的影视作品',
    vote_average: voteAverage,
    vote_count: 1000,
    release_date: mediaType === 'movie' ? releaseDate : undefined,
    first_air_date: mediaType === 'tv' ? releaseDate : undefined,
    genre_ids: genreIds,
    media_type: mediaType,
    popularity: 100,
    adult: false,
    original_language: 'zh',
    original_title: mediaType === 'movie' ? title : undefined,
    original_name: mediaType === 'tv' ? title : undefined,
    trailer_url: trailerUrl
  }
  return m
}

const TRAILER_FANHUA: Resource = $rawfile('trailer_01.mp4')
const TRAILER_QINGYUNIAN: Resource = $rawfile('trailer_02.mp4')
const TRAILER_ALETAI: Resource = $rawfile('trailer_03.mp4')
const TRAILER_FEICHI: Resource = $rawfile('trailer_04.mp4')
const TRAILER_ZHONGDIBA: Resource = $rawfile('trailer_01.mp4')
const TRAILER_BUSHANLIANG: Resource = $rawfile('trailer_02.mp4')
const TRAILER_MANCHANG: Resource = $rawfile('trailer_03.mp4')
const TRAILER_WAIPO: Resource = $rawfile('trailer_04.mp4')
const TRAILER_TAOCHU: Resource = $rawfile('trailer_01.mp4')
const TRAILER_MEIGUI: Resource = $rawfile('trailer_02.mp4')
const TRAILER_JINYONG: Resource = $rawfile('trailer_03.mp4')
const TRAILER_MOYU: Resource = $rawfile('trailer_04.mp4')
const TRAILER_DUHUANIAN: Resource = $rawfile('trailer_01.mp4')
const TRAILER_RELAGUTANG: Resource = $rawfile('trailer_02.mp4')
const TRAILER_DIERSHOUTIAO: Resource = $rawfile('trailer_03.mp4')
const TRAILER_YIQIYAO: Resource = $rawfile('trailer_04.mp4')
const TRAILER_XIONGCHUMO: Resource = $rawfile('trailer_01.mp4')
const TRAILER_HONGTAN: Resource = $rawfile('trailer_02.mp4')
const TRAILER_DAHONGBAO: Resource = $rawfile('trailer_03.mp4')
const TRAILER_SAOHEI: Resource = $rawfile('trailer_04.mp4')

function getMockNowPlaying(): TMDBListResponse {
  const list: TMDBMedia[] = []
  list.push(createMockTMDBMedia(1, '繁花', 'poster_fanhua', 8.7, '2024-01-01', 'tv', [2, 5], TRAILER_FANHUA))
  list.push(createMockTMDBMedia(2, '庆余年 第二季', 'poster_qingyunian', 8.5, '2024-05-16', 'tv', [2, 3, 5], TRAILER_QINGYUNIAN))
  list.push(createMockTMDBMedia(3, '我的阿勒泰', 'poster_aletai', 8.9, '2024-05-01', 'tv', [2, 5], TRAILER_ALETAI))
  list.push(createMockTMDBMedia(4, '飞驰人生2', 'poster_feichi', 8.0, '2024-02-10', 'movie', [1, 4], TRAILER_FEICHI))
  list.push(createMockTMDBMedia(5, '种地吧 第二季', 'poster_zhongdiba', 8.6, '2024-03-01', 'tv', [2, 4, 5], TRAILER_ZHONGDIBA))
  list.push(createMockTMDBMedia(6, '不够善良的我们', 'poster_bushanliang', 8.8, '2024-04-01', 'tv', [2, 5], TRAILER_BUSHANLIANG))
  const res: TMDBListResponse = {
    page: 1,
    results: list,
    total_pages: 1,
    total_results: list.length
  }
  return res
}

export const mockNowPlaying: TMDBListResponse = getMockNowPlaying()

function getMockTrending(): TMDBListResponse {
  const list: TMDBMedia[] = []
  list.push(createMockTMDBMedia(101, '漫长的季节', 'poster_manchangdeji', 9.1, '2023-04-22', 'tv', [2, 3, 5], TRAILER_MANCHANG))
  list.push(createMockTMDBMedia(102, '外婆的新世界', 'poster_waipodexinshijie', 8.4, '2023-05-01', 'tv', [2, 4, 5], TRAILER_WAIPO))
  list.push(createMockTMDBMedia(103, '逃出白虎园', 'poster_taochubaihuyuan', 7.8, '2024-01-15', 'movie', [1, 3], TRAILER_TAOCHU))
  list.push(createMockTMDBMedia(104, '玫瑰的故事', 'poster_meiguidagushi', 7.8, '2024-06-01', 'tv', [2, 5], TRAILER_MEIGUI))
  list.push(createMockTMDBMedia(105, '我的阿勒泰', 'poster_aletai2', 8.9, '2024-05-01', 'tv', [2, 5], TRAILER_ALETAI))
  list.push(createMockTMDBMedia(106, '金庸武侠世界', 'poster_jinyongwuxia', 7.5, '2024-06-17', 'tv', [2, 3], TRAILER_JINYONG))
  list.push(createMockTMDBMedia(107, '墨雨云间', 'poster_moyuyunjian', 7.9, '2024-04-30', 'tv', [2, 3, 5], TRAILER_MOYU))
  list.push(createMockTMDBMedia(108, '度华年', 'poster_duhuanian', 7.6, '2024-06-28', 'tv', [2], TRAILER_DUHUANIAN))
  const res: TMDBListResponse = {
    page: 1,
    results: list,
    total_pages: 1,
    total_results: list.length
  }
  return res
}

export const mockTrending: TMDBListResponse = getMockTrending()

function getMockPopularMovies(): TMDBListResponse {
  const list: TMDBMedia[] = []
  list.push(createMockTMDBMedia(201, '飞驰人生2', 'poster_feichi', 8.0, '2024-02-10', 'movie', [1, 4], TRAILER_FEICHI))
  list.push(createMockTMDBMedia(202, '热辣滚烫', 'poster_relaguangtang', 7.5, '2024-02-10', 'movie', [1, 4, 5], TRAILER_RELAGUTANG))
  list.push(createMockTMDBMedia(203, '第二十条', 'poster_diershitiao', 7.8, '2024-02-10', 'movie', [1, 5], TRAILER_DIERSHOUTIAO))
  list.push(createMockTMDBMedia(204, '我们一起摇太阳', 'poster_womenyiqi', 7.7, '2024-02-10', 'movie', [1, 5], TRAILER_YIQIYAO))
  list.push(createMockTMDBMedia(205, '熊出没·逆转时空', 'poster_xiongchumo', 7.6, '2024-02-10', 'movie', [1, 4], TRAILER_XIONGCHUMO))
  list.push(createMockTMDBMedia(206, '红毯先生', 'poster_hongtanxiansheng', 7.2, '2024-02-10', 'movie', [1, 4], TRAILER_HONGTAN))
  list.push(createMockTMDBMedia(207, '大红包', 'poster_dahongbao', 6.5, '2024-01-01', 'movie', [1, 4], TRAILER_DAHONGBAO))
  list.push(createMockTMDBMedia(208, '扫黑·决不放弃', 'poster_saohei', 6.8, '2024-03-02', 'movie', [1, 3], TRAILER_SAOHEI))
  const res: TMDBListResponse = {
    page: 1,
    results: list,
    total_pages: 1,
    total_results: list.length
  }
  return res
}

export const mockPopularMovies: TMDBListResponse = getMockPopularMovies()

function getMockOnAirTv(): TMDBListResponse {
  const list: TMDBMedia[] = []
  list.push(createMockTMDBMedia(301, '度华年', 'poster_duhuanian', 7.6, '2024-06-28', 'tv', [2], TRAILER_DUHUANIAN))
  list.push(createMockTMDBMedia(302, '金庸武侠世界', 'poster_jinyongwuxia', 7.5, '2024-06-17', 'tv', [2, 3], TRAILER_JINYONG))
  list.push(createMockTMDBMedia(303, '墨雨云间', 'poster_moyuyunjian', 7.9, '2024-04-30', 'tv', [2, 3, 5], TRAILER_MOYU))
  list.push(createMockTMDBMedia(304, '玫瑰的故事', 'poster_meiguidagushi', 7.8, '2024-06-01', 'tv', [2, 5], TRAILER_MEIGUI))
  list.push(createMockTMDBMedia(305, '我的阿勒泰', 'poster_aletai', 8.9, '2024-05-01', 'tv', [2, 5], TRAILER_ALETAI))
  list.push(createMockTMDBMedia(306, '庆余年 第二季', 'poster_qingyunian', 8.5, '2024-05-16', 'tv', [2, 3, 5], TRAILER_QINGYUNIAN))
  list.push(createMockTMDBMedia(307, '繁花', 'poster_fanhua', 8.7, '2024-01-01', 'tv', [2, 5], TRAILER_FANHUA))
  list.push(createMockTMDBMedia(308, '不够善良的我们', 'poster_bushanliang', 8.8, '2024-04-01', 'tv', [2, 5], TRAILER_BUSHANLIANG))
  const res: TMDBListResponse = {
    page: 1,
    results: list,
    total_pages: 1,
    total_results: list.length
  }
  return res
}

export const mockOnAirTv: TMDBListResponse = getMockOnAirTv()

function getMockAllMedia(): TMDBMedia[] {
  const set: Set<number> = new Set()
  const result: TMDBMedia[] = []

  const addUnique = (list: TMDBMedia[]): void => {
    for (let i = 0; i < list.length; i++) {
      const item = list[i]
      if (!set.has(item.id)) {
        set.add(item.id)
        result.push(item)
      }
    }
  }

  addUnique(mockNowPlaying.results)
  addUnique(mockTrending.results)
  addUnique(mockPopularMovies.results)
  addUnique(mockOnAirTv.results)

  const extraNames: string[] = [
    '狂飙', '琅琊榜', '延禧攻略', '隐秘的角落', '沉默的真相',
    '都挺好', '小欢喜', '三十而已', '流金岁月', '知否',
    '流浪地球', '满江红', '你好李焕英', '长津湖', '战狼',
    '消失的她', '孤注一掷', '封神第一部', '长安三万里', '八角笼中',
    '去有风的地方', '爱情而已', '长相思', '莲花楼', '云之羽',
    '一念关山', '与凤行', '灼灼韶华', '惜花芷', '墨白'
  ]
  const extraPosters: string[] = [
    'poster_kuangbiao', 'poster_langyabang', 'poster_yanxinji', 'poster_fanhua', 'poster_manchangdeji',
    'poster_duhuanian', 'poster_moyuyunjian', 'poster_meiguidagushi', 'poster_jinyongwuxia', 'poster_bushanliang',
    'poster_feichi', 'poster_relaguangtang', 'poster_womenyiqi', 'poster_saohei', 'poster_diershitiao',
    'poster_taochubaihuyuan', 'poster_hongtanxiansheng', 'poster_dahongbao', 'poster_xiongchumo', 'poster_zhongdiba',
    'poster_aletai', 'poster_qingyunian', 'poster_fanhua', 'poster_manchangdeji', 'poster_moyuyunjian',
    'poster_duhuanian', 'poster_jinyongwuxia', 'poster_meiguidagushi', 'poster_bushanliang', 'poster_waipodexinshijie'
  ]
  const extraGenres: number[][] = [
    [2, 3, 5], [2, 3, 5], [2, 5], [2, 3, 5], [2, 3, 5],
    [2, 5], [2, 4], [2, 5], [2, 5], [2, 5],
    [1, 5], [1, 4, 5], [1, 4], [1, 5], [1, 5],
    [1, 3, 5], [1, 3], [1, 5], [1, 4], [1, 5],
    [2, 5], [2, 4], [2, 5], [2, 3, 5], [2, 3],
    [2, 3], [2, 5], [2, 5], [2, 5], [2, 4]
  ]
  const extraTypes: string[] = [
    'tv', 'tv', 'tv', 'tv', 'tv',
    'tv', 'tv', 'tv', 'tv', 'tv',
    'movie', 'movie', 'movie', 'movie', 'movie',
    'movie', 'movie', 'movie', 'movie', 'movie',
    'tv', 'tv', 'tv', 'tv', 'tv',
    'tv', 'tv', 'tv', 'tv', 'tv'
  ]
  const extraYears: string[] = [
    '2023', '2015', '2018', '2020', '2020',
    '2019', '2019', '2020', '2021', '2018',
    '2023', '2023', '2021', '2021', '2017',
    '2023', '2023', '2023', '2023', '2023',
    '2023', '2023', '2023', '2023', '2023',
    '2023', '2024', '2024', '2024', '2022'
  ]
  const extraRatings: number[] = [
    8.5, 9.4, 7.2, 8.8, 9.0,
    7.7, 8.2, 6.8, 7.3, 7.9,
    7.9, 7.0, 7.8, 7.4, 7.1,
    6.5, 6.9, 7.8, 8.3, 7.5,
    8.1, 8.2, 7.8, 8.5, 7.6,
    7.4, 7.3, 7.2, 7.0, 6.9
  ]

  for (let i = 0; i < extraNames.length; i++) {
    const id = 1000 + i
    if (!set.has(id)) {
      const media: TMDBMedia = createMockTMDBMedia(
        id,
        extraNames[i],
        extraPosters[i],
        extraRatings[i],
        extraYears[i] + '-01-01',
        extraTypes[i],
        extraGenres[i]
      )
      result.push(media)
      set.add(id)
    }
  }

  return result
}

export const mockAllMedia: TMDBMedia[] = getMockAllMedia()
