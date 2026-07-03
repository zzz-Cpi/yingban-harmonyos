// 应用常量定义

// 颜色常量 - 粉蓝梦幻柔和主题
export class Colors {
  static readonly primary: string = '#F992A5'
  static readonly secondary: string = '#A0C8D8'
  static readonly accent: string = '#FFE66D'

  static readonly background: string = '#FFFAF5'
  static readonly cardBackground: string = 'rgba(255,240,245,0.72)'
  static readonly darkBackground: string = '#1A1A1A'

  static readonly textPrimary: string = '#2D2D3A'
  static readonly textSecondary: string = '#8E8E93'
  static readonly textTertiary: string = '#AEAEB2'

  static readonly success: string = '#00C853'
  static readonly warning: string = '#FF9500'
  static readonly error: string = '#FF3B30'
}

// 字体大小常量
export class FontSizes {
  static readonly largeTitle: number = 24
  static readonly pageTitle: number = 20
  static readonly sectionTitle: number = 18
  static readonly body: number = 16
  static readonly caption: number = 14
  static readonly helper: number = 12
}

// 间距常量
export class Spacing {
  static readonly xs: number = 4
  static readonly sm: number = 8
  static readonly md: number = 12
  static readonly lg: number = 16
  static readonly xl: number = 24
  static readonly xxl: number = 32
}

// 圆角常量
export class BorderRadius {
  static readonly small: number = 8
  static readonly medium: number = 12
  static readonly large: number = 16
  static readonly button: number = 28
  static readonly tab: number = 24
}

// 状态标签
export class StatusLabels {
  static readonly want: string = '想看'
  static readonly watching: string = '在看'
  static readonly finished: string = '已看'
}

// 字体权重
export class FontWeightValue {
  static readonly regular: number = 400
  static readonly medium: number = 500
  static readonly semibold: number = 600
  static readonly bold: number = 700
}

// 阴影常量
export interface ShadowConfig {
  radius: number
  color: string
  offsetX: number
  offsetY: number
}

export class Shadows {
  static readonly card: ShadowConfig = {
    radius: 8,
    color: 'rgba(0,0,0,0.08)',
    offsetX: 0,
    offsetY: 2
  }
  static readonly floating: ShadowConfig = {
    radius: 16,
    color: 'rgba(255,107,107,0.3)',
    offsetX: 0,
    offsetY: 4
  }
}
