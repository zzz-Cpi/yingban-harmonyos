// TMDB API 服务封装
import http from '@ohos.net.http'
import {
  TMDBListResponse,
  TMDBMovieDetail,
  TMDBTvDetail,
  TMDBCreditsResponse,
  TMDBVideosResponse,
  TMDBVideo,
  TMDBSearchResponse
} from './TMDBTypes'

// TMDB 错误响应
interface TMDBErrorResponse {
  status_code: number
  status_message: string
  success: boolean
}

// TMDB API 配置
const API_KEY: string = 'f8b0582660e61ee94a0ba88e46bcae7a'
const BASE_URL: string = 'https://api.themoviedb.org/3'
const LANGUAGE: string = 'zh-CN'
const REGION: string = 'CN'

// 请求超时时间（毫秒）- 增加到 15 秒
const TIMEOUT: number = 15000

// TMDB 服务类
export class TMDBService {
  private httpRequest: http.HttpRequest

  constructor() {
    this.httpRequest = http.createHttp()
  }

  // 通用 GET 请求
  private async get(path: string, params: string[]): Promise<string> {
    let url: string = `${BASE_URL}${path}?api_key=${API_KEY}&language=${LANGUAGE}`

    for (let i: number = 0; i < params.length; i += 2) {
      const key: string = params[i]
      const value: string = params[i + 1]
      url += `&${key}=${encodeURIComponent(value)}`
    }

    console.info('TMDB request: ' + url)

    try {
      const response: http.HttpResponse = await this.httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Accept': 'application/json',
          'User-Agent': 'YingBanApp/1.0'
        },
        connectTimeout: TIMEOUT,
        readTimeout: TIMEOUT
      })

      console.info('TMDB response code: ' + response.responseCode)

      if (response.responseCode === 200 && response.result) {
        return response.result as string
      } else {
        let errMsg: string = `HTTP ${response.responseCode}`
        if (response.result) {
          try {
            const errBody: TMDBErrorResponse = JSON.parse(response.result as string) as TMDBErrorResponse
            if (errBody.status_message) {
              errMsg = errBody.status_message
            }
          } catch (parseErr) {
            // 忽略解析错误
          }
        }
        throw new Error(errMsg)
      }
    } catch (e) {
      const err = e as Error
      console.error('TMDB request error: ' + JSON.stringify(err))
      console.error('TMDB error name: ' + err.name)
      console.error('TMDB error message: ' + err.message)
      let errorMsg: string = err.message || '网络请求失败'
      if (errorMsg === 'Unknown Other Error') {
        errorMsg = '网络连接失败，请检查网络或稍后重试'
      }
      throw new Error(errorMsg)
    }
  }

  // ==================== 首页数据 ====================

  // 热门电影
  async getPopularMovies(page: number): Promise<TMDBListResponse> {
    const result: string = await this.get('/movie/popular',
      ['page', page.toString(), 'region', REGION])
    return JSON.parse(result) as TMDBListResponse
  }

  // 热播剧集
  async getOnTheAirTv(page: number): Promise<TMDBListResponse> {
    const result: string = await this.get('/tv/on_the_air',
      ['page', page.toString()])
    return JSON.parse(result) as TMDBListResponse
  }

  // 正在上映的电影（用于今日更新）
  async getNowPlayingMovies(page: number): Promise<TMDBListResponse> {
    const result: string = await this.get('/movie/now_playing',
      ['page', page.toString(), 'region', REGION])
    return JSON.parse(result) as TMDBListResponse
  }

  // 本周热门（用于推荐）
  async getTrending(page: number): Promise<TMDBListResponse> {
    const result: string = await this.get('/trending/all/week',
      ['page', page.toString()])
    return JSON.parse(result) as TMDBListResponse
  }

  // ==================== 详情页 ====================

  // 电影详情
  async getMovieDetail(movieId: number): Promise<TMDBMovieDetail> {
    const result: string = await this.get(`/movie/${movieId}`, [])
    return JSON.parse(result) as TMDBMovieDetail
  }

  // 剧集详情
  async getTvDetail(tvId: number): Promise<TMDBTvDetail> {
    const result: string = await this.get(`/tv/${tvId}`, [])
    return JSON.parse(result) as TMDBTvDetail
  }

  // 电影演员表
  async getMovieCredits(movieId: number): Promise<TMDBCreditsResponse> {
    const result: string = await this.get(`/movie/${movieId}/credits`, [])
    return JSON.parse(result) as TMDBCreditsResponse
  }

  // 剧集演员表
  async getTvCredits(tvId: number): Promise<TMDBCreditsResponse> {
    const result: string = await this.get(`/tv/${tvId}/credits`, [])
    return JSON.parse(result) as TMDBCreditsResponse
  }

  // 电影预告片
  async getMovieVideos(movieId: number): Promise<TMDBVideosResponse> {
    const result: string = await this.get(`/movie/${movieId}/videos`, [])
    return JSON.parse(result) as TMDBVideosResponse
  }

  // 剧集预告片
  async getTvVideos(tvId: number): Promise<TMDBVideosResponse> {
    const result: string = await this.get(`/tv/${tvId}/videos`, [])
    return JSON.parse(result) as TMDBVideosResponse
  }

  // 获取预告片URL（优先官方YouTube预告片）
  async getTrailerUrl(mediaId: number, mediaType: string): Promise<string> {
    let videosRes: TMDBVideosResponse
    if (mediaType === 'movie') {
      videosRes = await this.getMovieVideos(mediaId)
    } else {
      videosRes = await this.getTvVideos(mediaId)
    }

    const videos: TMDBVideo[] = videosRes.results
    if (!videos || videos.length === 0) {
      throw new Error('没有找到预告片')
    }

    let bestVideo: TMDBVideo | null = null
    for (let i: number = 0; i < videos.length; i++) {
      const v: TMDBVideo = videos[i]
      if (v.site === 'YouTube' && v.type === 'Trailer' && v.official) {
        bestVideo = v
        break
      }
    }

    if (!bestVideo) {
      for (let i: number = 0; i < videos.length; i++) {
        const v: TMDBVideo = videos[i]
        if (v.site === 'YouTube' && v.type === 'Trailer') {
          bestVideo = v
          break
        }
      }
    }

    if (!bestVideo) {
      for (let i: number = 0; i < videos.length; i++) {
        const v: TMDBVideo = videos[i]
        if (v.site === 'YouTube') {
          bestVideo = v
          break
        }
      }
    }

    if (!bestVideo) {
      throw new Error('没有找到可用的预告片')
    }

    return `https://www.youtube.com/watch?v=${bestVideo.key}`
  }

  // ==================== 搜索 ====================

  // 综合搜索
  async searchMulti(query: string, page: number): Promise<TMDBSearchResponse> {
    const result: string = await this.get('/search/multi',
      ['query', query, 'page', page.toString(), 'include_adult', 'false'])
    return JSON.parse(result) as TMDBSearchResponse
  }

  // 搜索电影
  async searchMovie(query: string, page: number): Promise<TMDBListResponse> {
    const result: string = await this.get('/search/movie',
      ['query', query, 'page', page.toString(), 'include_adult', 'false'])
    return JSON.parse(result) as TMDBListResponse
  }

  // 搜索剧集
  async searchTv(query: string, page: number): Promise<TMDBListResponse> {
    const result: string = await this.get('/search/tv',
      ['query', query, 'page', page.toString(), 'include_adult', 'false'])
    return JSON.parse(result) as TMDBListResponse
  }

  // ==================== 分类筛选 ====================

  // 发现电影
  async discoverMovies(page: number, sortBy: string): Promise<TMDBListResponse> {
    const result: string = await this.get('/discover/movie',
      ['page', page.toString(), 'sort_by', sortBy, 'include_adult', 'false'])
    return JSON.parse(result) as TMDBListResponse
  }

  // 发现剧集
  async discoverTv(page: number, sortBy: string): Promise<TMDBListResponse> {
    const result: string = await this.get('/discover/tv',
      ['page', page.toString(), 'sort_by', sortBy, 'include_adult', 'false'])
    return JSON.parse(result) as TMDBListResponse
  }

  // 销毁连接
  destroy(): void {
    this.httpRequest.destroy()
  }
}

// 单例实例
let tmdbService: TMDBService | null = null

export function getTMDBService(): TMDBService {
  if (!tmdbService) {
    tmdbService = new TMDBService()
  }
  return tmdbService
}
