// TMDB API 响应数据类型定义

// 电影/剧集基础信息
export interface TMDBMedia {
  id: number
  title?: string
  name?: string
  poster_path: string
  backdrop_path?: string
  overview: string
  vote_average: number
  vote_count: number
  release_date?: string
  first_air_date?: string
  genre_ids: number[]
  media_type?: string
  popularity: number
  adult?: boolean
  original_language?: string
  original_title?: string
  original_name?: string
  trailer_url?: string | Resource
}

// 分页响应
export interface TMDBListResponse {
  page: number
  results: TMDBMedia[]
  total_pages: number
  total_results: number
}

// 电影详情
export interface TMDBMovieDetail {
  id: number
  title: string
  original_title: string
  overview: string
  poster_path: string
  backdrop_path: string
  release_date: string
  runtime: number
  vote_average: number
  vote_count: number
  status: string
  tagline?: string
  genres: TMDBGenre[]
  budget: number
  revenue: number
  homepage?: string
  imdb_id?: string
  popularity: number
}

// 剧集详情
export interface TMDBTvDetail {
  id: number
  name: string
  original_name: string
  overview: string
  poster_path: string
  backdrop_path: string
  first_air_date: string
  last_air_date: string
  number_of_seasons: number
  number_of_episodes: number
  vote_average: number
  vote_count: number
  status: string
  type: string
  genres: TMDBGenre[]
  popularity: number
  in_production: boolean
}

// 类型
export interface TMDBGenre {
  id: number
  name: string
}

// 演员信息
export interface TMDBCast {
  id: number
  name: string
  character: string
  profile_path: string
  order: number
  known_for_department: string
}

// 演职人员响应
export interface TMDBCreditsResponse {
  id: number
  cast: TMDBCast[]
  crew: TMDBCrew[]
}

// 工作人员
export interface TMDBCrew {
  id: number
  name: string
  job: string
  department: string
  profile_path: string
}

// 视频/预告片
export interface TMDBVideo {
  id: string
  key: string
  name: string
  site: string
  type: string
  size: number
  official: boolean
  published_at: string
}

// 视频响应
export interface TMDBVideosResponse {
  id: number
  results: TMDBVideo[]
}

// 搜索结果
export interface TMDBSearchResponse {
  page: number
  results: TMDBMedia[]
  total_pages: number
  total_results: number
}

// 辅助方法：获取标题
export function getMediaTitle(media: TMDBMedia): string {
  return media.title || media.name || '未知'
}

// 辅助方法：获取日期
export function getMediaDate(media: TMDBMedia): string {
  return media.release_date || media.first_air_date || ''
}

// 辅助方法：获取年份
export function getMediaYear(media: TMDBMedia): string {
  const date = getMediaDate(media)
  return date ? date.substring(0, 4) : ''
}

// 辅助方法：拼接完整图片URL（使用picsum稳定图片服务）
export function getImageUrl(path: string, size: string = 'w500'): string {
  if (!path) {
    return ''
  }
  // 从 path 中提取 seed（去掉前导斜杠和扩展名）
  let seed: string = path.replace(/^\//, '').replace(/\.[^.]+$/, '')
  if (!seed) {
    seed = 'default'
  }
  // 根据尺寸参数确定宽高
  let w: number = 500
  let h: number = 750
  if (size === 'w200') {
    w = 200
    h = 300
  } else if (size === 'w300') {
    w = 300
    h = 450
  } else if (size === 'w400') {
    w = 400
    h = 600
  } else if (size === 'original') {
    w = 800
    h = 1200
  }
  return `https://picsum.photos/seed/${seed}/${w}/${h}`
}

// 公开测试视频列表（可正常播放）
const TEST_VIDEO_URLS: string[] = [
  'https://www.w3schools.com/html/mov_bbb.mp4',
  'https://www.w3schools.com/html/movie.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
]

// 根据媒体ID获取测试视频地址
export function getTestVideoUrl(mediaId: number): string {
  return TEST_VIDEO_URLS[mediaId % TEST_VIDEO_URLS.length]
}
