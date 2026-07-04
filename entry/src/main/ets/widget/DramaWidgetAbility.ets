// 追剧日历卡片 - FormExtensionAbility 生命周期管理
import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG: string = 'DramaWidgetAbility'
const DOMAIN_NUMBER: number = 0xFF00

// 剧集更新数据结构
interface DramaUpdate {
  title: string
  episode: string
  platform: string
}

export default class DramaWidgetAbility extends FormExtensionAbility {
  /**
   * 卡片创建时触发，返回初始数据
   */
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(DOMAIN_NUMBER, TAG, '[onAddForm] 追剧日历卡片创建')

    const initData = this.getCardData()
    return formBindingData.createFormBindingData(initData)
  }

  /**
   * 临时卡片转常态卡片
   */
  onCastToNormalForm(formId: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, `[onCastToNormalForm] ${formId}`)
  }

  /**
   * 卡片定时刷新时触发
   */
  onUpdateForm(formId: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, `[onUpdateForm] 卡片刷新: ${formId}`)

    const updateData = this.getCardData()
    const formData = formBindingData.createFormBindingData(updateData)

    formProvider.updateForm(formId, formData)
      .catch((error: BusinessError) => {
        hilog.error(DOMAIN_NUMBER, TAG, `刷新失败: ${JSON.stringify(error)}`)
      })
  }

  /**
   * 卡片可见性变化
   */
  onChangeFormVisibility(newStatus: Record<string, number>): void {
    hilog.info(DOMAIN_NUMBER, TAG, `[onChangeFormVisibility] ${JSON.stringify(newStatus)}`)
  }

  /**
   * 卡片触发事件（动态卡片交互）
   */
  onFormEvent(formId: string, message: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, `[onFormEvent] ${formId}, 消息: ${message}`)
    if (message === 'refresh') {
      this.onUpdateForm(formId)
    }
  }

  /**
   * 卡片删除
   */
  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, `[onRemoveForm] 卡片删除: ${formId}`)
  }

  /**
   * 查询卡片状态
   */
  onAcquireFormState(want: Want): formInfo.FormState {
    hilog.info(DOMAIN_NUMBER, TAG, '[onAcquireFormState] 查询卡片状态')
    return formInfo.FormState.READY
  }

  /**
   * 获取卡片展示数据（模拟追剧更新数据）
   */
  private getCardData(): Record<string, Object> {
    const now = new Date()
    const month = now.getMonth() + 1
    const day = now.getDate()
    const weekDays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const weekDay = weekDays[now.getDay()]

    // 模拟今日更新的剧集数据
    const updates: DramaUpdate[] = [
      { title: '庆余年 第二季', episode: '第28集', platform: '腾讯视频' },
      { title: '墨雨云间', episode: '第35集', platform: '优酷' },
      { title: '度华年', episode: '第18集', platform: '爱奇艺' }
    ]

    // 根据日期轮换数据，让每次刷新有变化感
    const dayOffset = day % updates.length
    const item1: DramaUpdate = updates[dayOffset % updates.length]
    const item2: DramaUpdate = updates[(dayOffset + 1) % updates.length]
    const item3: DramaUpdate = updates[(dayOffset + 2) % updates.length]

    const result: Record<string, Object> = {
      'dateStr': `${month}月${day}日`,
      'weekDay': weekDay,
      'dramaCount': 3,
      'update1Title': item1.title,
      'update1Episode': item1.episode,
      'update1Platform': item1.platform,
      'update2Title': item2.title,
      'update2Episode': item2.episode,
      'update2Platform': item2.platform,
      'update3Title': item3.title,
      'update3Episode': item3.episode,
      'update3Platform': item3.platform
    }
    return result
  }
}
