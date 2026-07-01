import { DistributedConstants } from './DistributedConstants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { distributedDeviceManager } from '@kit.DistributedServiceKit'

const TAG = 'DeviceManagerService'

export interface DeviceInfo {
  deviceId: string
  deviceName: string
  deviceType: number
  isOnline: boolean
}

// 发现成功回调参数结构
interface DiscoverSuccessParam {
  device: distributedDeviceManager.DeviceBasicInfo
}

// 发现失败回调参数结构
interface DiscoverFailureParam {
  reason: number
}

// 设备状态变化回调参数结构
interface DeviceStateChangeParam {
  action: distributedDeviceManager.DeviceStateChange
  device: distributedDeviceManager.DeviceBasicInfo
}

export class DeviceManagerService {
  private static instance: DeviceManagerService | null = null
  private discoveredDevices: DeviceInfo[] = []
  private localDeviceInfo: DeviceInfo | null = null
  private onDeviceFoundCallback: (devices: DeviceInfo[]) => void = () => {}
  private onDeviceOnlineCallback: (device: DeviceInfo) => void = () => {}
  private onDeviceOfflineCallback: (device: DeviceInfo) => void = () => {}
  private isDiscovering: boolean = false
  private dmInstance: distributedDeviceManager.DeviceManager | null = null
  private discoverTimer: number | null = null

  private constructor() {}

  static getInstance(): DeviceManagerService {
    if (!DeviceManagerService.instance) {
      DeviceManagerService.instance = new DeviceManagerService()
    }
    return DeviceManagerService.instance
  }

  async init(): Promise<void> {
    try {
      // 创建 DeviceManager 实例（传入应用 bundleName）
      this.dmInstance = distributedDeviceManager.createDeviceManager('yingban_theater')
      hilog.info(0, TAG, 'DeviceManagerService initialized')

      // 获取本地设备信息
      try {
        const localId: string = this.dmInstance.getLocalDeviceId()
        const localName: string = this.dmInstance.getLocalDeviceName()
        const localType: number = this.dmInstance.getLocalDeviceType()
        this.localDeviceInfo = {
          deviceId: localId,
          deviceName: localName || '本机设备',
          deviceType: localType,
          isOnline: true
        }
        hilog.info(0, TAG, `Local device: ${this.localDeviceInfo.deviceName}`)
      } catch (err) {
        hilog.warn(0, TAG, 'Failed to get local device info')
        this.localDeviceInfo = {
          deviceId: 'local_device',
          deviceName: '本机设备',
          deviceType: 1,
          isOnline: true
        }
      }
    } catch (err) {
      hilog.error(0, TAG, `Failed to init DeviceManager: ${JSON.stringify(err)}`)
      // 初始化失败时保留基础信息，发现功能将不可用
      this.localDeviceInfo = {
        deviceId: 'local_device',
        deviceName: '本机设备',
        deviceType: 1,
        isOnline: true
      }
    }
  }

  async startDeviceDiscovery(): Promise<DeviceInfo[]> {
    return new Promise((resolve: (devices: DeviceInfo[]) => void) => {
      if (this.isDiscovering) {
        resolve(this.discoveredDevices)
        return
      }

      this.isDiscovering = true
      this.discoveredDevices = []

      if (!this.dmInstance) {
        hilog.warn(0, TAG, 'DeviceManager not initialized, no devices found')
        this.isDiscovering = false
        resolve([])
        return
      }

      try {
        // 注册设备发现成功监听
        this.dmInstance.on('discoverSuccess', (param: DiscoverSuccessParam) => {
          const device = param.device
          hilog.info(0, TAG, `Device discovered: ${device.deviceName}`)
          const devInfo: DeviceInfo = {
            deviceId: device.deviceId,
            deviceName: device.deviceName || '附近设备',
            deviceType: this.parseDeviceType(device.deviceType),
            isOnline: true
          }
          const exists = this.discoveredDevices.some((d: DeviceInfo) => d.deviceId === devInfo.deviceId)
          if (!exists) {
            this.discoveredDevices.push(devInfo)
            if (this.onDeviceFoundCallback) {
              this.onDeviceFoundCallback(this.discoveredDevices)
            }
          }
        })

        // 注册设备发现失败监听
        this.dmInstance.on('discoverFailure', (param: DiscoverFailureParam) => {
          hilog.warn(0, TAG, `Discovery failed: ${param.reason}`)
        })

        // 注册设备状态变化监听
        this.dmInstance.on('deviceStateChange', (param: DeviceStateChangeParam) => {
          const device = param.device
          // action: UNKNOWN=0, AVAILABLE=1(上线), UNAVAILABLE=2(下线)
          if (param.action === distributedDeviceManager.DeviceStateChange.AVAILABLE) {
            hilog.info(0, TAG, `Device online: ${device.deviceName}`)
            const devInfo: DeviceInfo = {
              deviceId: device.deviceId,
              deviceName: device.deviceName || '附近设备',
              deviceType: this.parseDeviceType(device.deviceType),
              isOnline: true
            }
            const exists = this.discoveredDevices.some((d: DeviceInfo) => d.deviceId === devInfo.deviceId)
            if (!exists) {
              this.discoveredDevices.push(devInfo)
              if (this.onDeviceOnlineCallback) {
                this.onDeviceOnlineCallback(devInfo)
              }
              if (this.onDeviceFoundCallback) {
                this.onDeviceFoundCallback(this.discoveredDevices)
              }
            }
          } else if (param.action === distributedDeviceManager.DeviceStateChange.UNAVAILABLE) {
            hilog.info(0, TAG, `Device offline: ${device.deviceName}`)
            this.discoveredDevices = this.discoveredDevices.filter((d: DeviceInfo) => d.deviceId !== device.deviceId)
            if (this.onDeviceOfflineCallback) {
              const devInfo: DeviceInfo = {
                deviceId: device.deviceId,
                deviceName: device.deviceName || '附近设备',
                deviceType: this.parseDeviceType(device.deviceType),
                isOnline: false
              }
              this.onDeviceOfflineCallback(devInfo)
            }
            if (this.onDeviceFoundCallback) {
              this.onDeviceFoundCallback(this.discoveredDevices)
            }
          }
        })

        // 开始发现设备：discoverTargetType=1 表示发现设备类型
        const discoverParam: Record<string, Object> = {
          'discoverTargetType': 1
        }
        const filterOptions: Record<string, Object> = {
          'availableStatus': 1
        }
        this.dmInstance.startDiscovering(discoverParam, filterOptions)
        hilog.info(0, TAG, 'Device discovery started')

        // 设置超时，超时后停止发现并返回当前已发现的设备
        if (this.discoverTimer !== null) {
          clearTimeout(this.discoverTimer)
        }
        this.discoverTimer = setTimeout(() => {
          this.isDiscovering = false
          this.stopDiscoveryInternal()
          hilog.info(0, TAG, `Discovery timeout, found ${this.discoveredDevices.length} devices`)
          if (this.onDeviceFoundCallback) {
            this.onDeviceFoundCallback(this.discoveredDevices)
          }
          resolve(this.discoveredDevices)
        }, DistributedConstants.SCAN_TIMEOUT_MS)

      } catch (err) {
        hilog.error(0, TAG, `Device discovery failed: ${JSON.stringify(err)}`)
        this.isDiscovering = false
        resolve([])
      }
    })
  }

  // 解析设备类型字符串为数字（1=手机, 2=平板, 3=TV, 4=PC）
  private parseDeviceType(typeStr: string): number {
    if (typeStr === 'phone') return 1
    if (typeStr === 'tablet') return 2
    if (typeStr === 'tv') return 3
    if (typeStr === 'pc') return 4
    return 1
  }

  // 内部停止发现，不重置状态
  private stopDiscoveryInternal(): void {
    if (this.dmInstance) {
      try {
        this.dmInstance.stopDiscovering()
        this.dmInstance.off('discoverSuccess')
        this.dmInstance.off('discoverFailure')
        this.dmInstance.off('deviceStateChange')
      } catch (err) {
        hilog.warn(0, TAG, `Stop discovery internal failed: ${JSON.stringify(err)}`)
      }
    }
  }

  stopDeviceDiscovery(): void {
    if (this.discoverTimer !== null) {
      clearTimeout(this.discoverTimer)
      this.discoverTimer = null
    }
    this.stopDiscoveryInternal()
    this.isDiscovering = false
    this.discoveredDevices = []
    hilog.info(0, TAG, 'Device discovery stopped')
  }

  getDiscoveredDevices(): DeviceInfo[] {
    return this.discoveredDevices
  }

  getLocalDevice(): DeviceInfo | null {
    return this.localDeviceInfo
  }

  setOnDeviceFoundCallback(callback: (devices: DeviceInfo[]) => void): void {
    this.onDeviceFoundCallback = callback
  }

  setOnDeviceOnlineCallback(callback: (device: DeviceInfo) => void): void {
    this.onDeviceOnlineCallback = callback
  }

  setOnDeviceOfflineCallback(callback: (device: DeviceInfo) => void): void {
    this.onDeviceOfflineCallback = callback
  }

  release(): void {
    this.stopDeviceDiscovery()
    this.discoveredDevices = []
    this.localDeviceInfo = null
    this.dmInstance = null
  }
}

export default DeviceManagerService
