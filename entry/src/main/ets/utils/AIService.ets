import { mockAllMedia } from '../model/MockData'
import { TMDBMedia, getMediaTitle, getMediaYear } from '../model/TMDBTypes'
import http from '@ohos.net.http'

export interface AIMessage {
  id: number
  role: 'user' | 'ai'
  content: string
  timestamp: number
  type: 'text' | 'recommend'
  recommendList?: TMDBMedia[]
}

// ========== 通义千问API配置 ==========
// 使用说明：将下方 API_KEY 替换为你的通义千问API Key即可
// 获取地址：https://dashscope.console.aliyun.com/apiKey
const QWEN_API_KEY: string = 'sk-8f4589a64a8041fba5379bbc4f3f9b6a' // ← 已填入通义千问API Key
const QWEN_API_URL: string = 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions'
const QWEN_MODEL: string = 'qwen-turbo' // 免费模型，速度快

class AIService {
  private messageId: number = 0
  // 对话历史，用于多轮对话上下文
  private chatHistory: ChatMsg[] = []

  /**
   * 生成AI回复（主入口）
   * 优先调用通义千问API，失败时降级到本地推荐
   */
  async generateReply(userMessage: string): Promise<AIMessage> {
    this.messageId++
    const msg = userMessage.trim()

    // 如果配置了API Key，走通义千问
    if (QWEN_API_KEY.length > 0) {
      try {
        const aiText = await this.callQwenAPI(msg)
        // 尝试从回复中匹配本地影视资源
        const matched = this.matchLocalMedia(aiText)
        // 如果AI回复中没有匹配到本地影片，根据用户查询关键词从本地库获取推荐
        const recommendList = matched.length > 0 ? matched : this.getRecommendByUserQuery(msg)
        // 始终返回推荐卡片，确保有海报和播放链接
        if (recommendList.length > 0) {
          return this.buildRecommendReply(recommendList, aiText)
        }
        return this.buildTextReply(aiText)
      } catch (e) {
        // API调用失败，降级到本地
        console.error('通义千问调用失败，降级本地:', JSON.stringify(e))
        return this.localReply(msg)
      }
    }

    // 未配置API Key，使用本地推荐
    return this.localReply(msg)
  }

  /**
   * 调用通义千问API
   */
  private async callQwenAPI(userMessage: string): Promise<string> {
    // 构建系统提示词，让AI扮演追剧助手
    const systemPrompt: string =
      '你是"小艺"，影伴APP的智能追剧助手。你的职责是帮用户推荐影视剧、解答追剧相关问题。' +
      '回复要求：1.语气亲切自然，适当使用emoji；2.推荐时简要说明推荐理由；3.回复控制在150字以内；4.如果用户问的与影视无关，友好引导回追剧话题。'

    // 添加用户消息到历史
    this.chatHistory.push({ role: 'user', content: userMessage })

    // 构建请求体（OpenAI兼容格式）
    const messages: ChatMsg[] = [
      { role: 'system', content: systemPrompt }
    ]
    // 保留最近6轮对话
    const recentHistory: ChatMsg[] = this.chatHistory.slice(-6)
    for (let i = 0; i < recentHistory.length; i++) {
      messages.push(recentHistory[i])
    }

    const requestBody: QwenRequest = {
      model: QWEN_MODEL,
      messages: messages,
      temperature: 0.8,
      max_tokens: 300
    }

    const httpRequest = http.createHttp()

    try {
      const response = await httpRequest.request(QWEN_API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${QWEN_API_KEY}`
        },
        extraData: JSON.stringify(requestBody),
        connectTimeout: 10000,
        readTimeout: 15000
      })

      if (response.responseCode === 200) {
        const result: QwenResponse = JSON.parse(response.result as string)
        const aiContent: string = result.choices[0].message.content

        // 添加AI回复到历史
        this.chatHistory.push({ role: 'assistant', content: aiContent })

        return aiContent
      } else {
        throw new Error(`API返回码: ${response.responseCode}, ${response.result}`)
      }
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 从AI回复文本中匹配本地影视库资源
   * 如果AI提到了库中的剧名，则附带推荐卡片
   */
  private matchLocalMedia(aiText: string): TMDBMedia[] {
    const result: TMDBMedia[] = []
    for (let i = 0; i < mockAllMedia.length; i++) {
      const title = getMediaTitle(mockAllMedia[i])
      if (aiText.includes(title)) {
        result.push(mockAllMedia[i])
      }
      if (result.length >= 6) break
    }
    return result
  }

  private getRecommendByUserQuery(userMessage: string): TMDBMedia[] {
    const msg = userMessage.toLowerCase()
    if (this.containsKeywords(msg, ['古装', '武侠', '权谋', '宫廷'])) {
      return this.filterByKeyword(['古装', '权谋', '武侠', '庆余年', '琅琊榜', '度华年', '墨雨云间', '延禧', '长相思', '莲花楼', '一念关山', '与凤行', '云之羽'])
    }
    if (this.containsKeywords(msg, ['悬疑', '犯罪', '破案', '推理'])) {
      return this.filterByKeyword(['狂飙', '漫长的季节', '沉默的真相', '隐秘的角落', '扫黑', '悬疑'])
    }
    if (this.containsKeywords(msg, ['喜剧', '搞笑', '轻松', '欢乐'])) {
      return this.filterByKeyword(['热辣滚烫', '飞驰', '喜剧', '大红包', '第二十条'])
    }
    if (this.containsKeywords(msg, ['治愈', '温暖', '生活', '文艺', '阿勒泰'])) {
      return this.filterByKeyword(['阿勒泰', '去有风', '治愈', '我的阿勒泰'])
    }
    if (this.containsKeywords(msg, ['高分', '经典', '口碑', 'top', '排行'])) {
      return [...mockAllMedia].sort((a, b) => b.vote_average - a.vote_average).slice(0, 6)
    }
    const directMatch = this.searchDirect(userMessage)
    if (directMatch.length > 0) return directMatch
    return this.getRandomRecommend(6)
  }

  /**
   * 清空对话历史（退出聊天时调用）
   */
  clearHistory(): void {
    this.chatHistory = []
  }

  // ========== 本地降级方案（API不可用时使用） ==========

  private localReply(userMessage: string): AIMessage {
    const msg = userMessage.trim().toLowerCase()

    if (this.containsKeywords(msg, ['推荐', '好看', '有什么', '看什么', '剧荒', '推荐点'])) {
      return this.buildRecommendReply(this.getRandomRecommend(6), '根据你的喜好，为你精选以下几部佳作：')
    }

    if (this.containsKeywords(msg, ['古装', '武侠', '权谋'])) {
      const list = this.filterByKeyword(['古装', '权谋', '武侠', '庆余年', '琅琊榜', '度华年', '墨雨云间'])
      return this.buildRecommendReply(list, '为你找到这些古装权谋佳作：')
    }

    if (this.containsKeywords(msg, ['悬疑', '犯罪', '破案', '推理'])) {
      const list = this.filterByKeyword(['狂飙', '漫长的季节', '扫黑', '悬疑'])
      return this.buildRecommendReply(list, '烧脑悬疑推荐，全程高能：')
    }

    if (this.containsKeywords(msg, ['喜剧', '搞笑', '轻松', '欢乐'])) {
      const list = this.filterByKeyword(['热辣滚烫', '飞驰', '喜剧', '大红包', '第二十条'])
      return this.buildRecommendReply(list, '轻松解压必备，笑到停不下来：')
    }

    if (this.containsKeywords(msg, ['治愈', '温暖', '生活', '文艺'])) {
      const list = this.filterByKeyword(['阿勒泰', '去有风', '治愈', '我的阿勒泰'])
      return this.buildRecommendReply(list, '慢节奏治愈系作品，温暖人心：')
    }

    if (this.containsKeywords(msg, ['高分', '经典', '口碑', 'top', '排行'])) {
      const sorted = [...mockAllMedia].sort((a, b) => b.vote_average - a.vote_average).slice(0, 6)
      return this.buildRecommendReply(sorted, '高分经典口碑榜，部部精品：')
    }

    if (this.containsKeywords(msg, ['你好', '在吗', 'hi', 'hello', '嗨'])) {
      return this.buildTextReply('你好呀！我是小艺AI 🤖\n我可以帮你：\n\n🎬 推荐好看的影视剧\n🔍 按类型找剧（古装/悬疑/喜剧...）\n⭐ 高分口碑榜\n\n有什么想看的，直接告诉我吧！')
    }

    if (this.containsKeywords(msg, ['你是谁', '介绍', '自我介绍'])) {
      return this.buildTextReply('我是影伴APP的智能助手「小艺」🤖\n\n基于大语言模型，懂你追剧口味～\n\n可以这样问我：\n• "推荐点好看的剧"\n• "有什么悬疑片"\n• "高分经典有哪些"\n\n快来试试吧！')
    }

    if (this.containsKeywords(msg, ['谢谢', '感谢', 'thx', 'thanks'])) {
      return this.buildTextReply('不客气～ 追剧愉快！🍿\n有需要随时找我哦～')
    }

    const directMatch = this.searchDirect(userMessage)
    if (directMatch.length > 0) {
      return this.buildRecommendReply(directMatch, `找到了和"${userMessage}"相关的内容：`)
    }

    return this.buildTextReply('小艺没太听懂呢 🤔\n\n你可以试试这样问：\n\n🎬 "推荐几部好看的剧"\n🏯 "古装权谋推荐"\n🔍 "有什么悬疑片"\n⭐ "高分经典有哪些"\n\n或者直接输入剧名搜索哦～')
  }

  private containsKeywords(msg: string, keywords: string[]): boolean {
    for (let i = 0; i < keywords.length; i++) {
      if (msg.includes(keywords[i])) {
        return true
      }
    }
    return false
  }

  private filterByKeyword(keywords: string[]): TMDBMedia[] {
    const result: TMDBMedia[] = []
    for (let i = 0; i < mockAllMedia.length; i++) {
      const item = mockAllMedia[i]
      const title = getMediaTitle(item)
      for (let j = 0; j < keywords.length; j++) {
        if (title.includes(keywords[j])) {
          result.push(item)
          break
        }
      }
      if (result.length >= 6) break
    }
    return result
  }

  private getRandomRecommend(count: number): TMDBMedia[] {
    const shuffled = [...mockAllMedia].sort(() => Math.random() - 0.5)
    return shuffled.slice(0, count)
  }

  private searchDirect(keyword: string): TMDBMedia[] {
    const result: TMDBMedia[] = []
    const kw = keyword.toLowerCase()
    for (let i = 0; i < mockAllMedia.length; i++) {
      const item = mockAllMedia[i]
      if (getMediaTitle(item).toLowerCase().includes(kw)) {
        result.push(item)
      }
      if (result.length >= 6) break
    }
    return result
  }

  private buildTextReply(content: string): AIMessage {
    return {
      id: this.messageId,
      role: 'ai',
      content: content,
      timestamp: Date.now(),
      type: 'text'
    }
  }

  private buildRecommendReply(list: TMDBMedia[], intro: string): AIMessage {
    return {
      id: this.messageId,
      role: 'ai',
      content: intro,
      timestamp: Date.now(),
      type: 'recommend',
      recommendList: list
    }
  }

  getWelcomeMessage(): AIMessage {
    this.messageId++
    return {
      id: this.messageId,
      role: 'ai',
      content: '你好呀！我是小艺AI 🤖\n你的专属追剧小助手～\n\n可以这样跟我说：\n🎬 "推荐点好看的剧"\n🏯 "古装权谋推荐"\n⭐ "高分经典有哪些"',
      timestamp: Date.now(),
      type: 'text'
    }
  }
}

// ========== 通义千问API类型定义 ==========

interface ChatMsg {
  role: 'user' | 'assistant' | 'system'
  content: string
}

interface QwenRequest {
  model: string
  messages: ChatMsg[]
  temperature: number
  max_tokens: number
}

interface QwenResponse {
  choices: QwenChoice[]
}

interface QwenChoice {
  message: ChatMsg
  finish_reason: string
}

export const aiService = new AIService()
