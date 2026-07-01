import { DistributedConstants } from './DistributedConstants'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'DeviceManagerService'

export interface DeviceInfo {
  deviceId: string
  deviceName: string
  deviceType: number
  isOnline: boolean
}

interface SubscribeInfo {
  subscribeId: number
}

export class DeviceManagerService {
  private static instance: DeviceManagerService | null = null
  private discoveredDevices: DeviceInfo[] = []
  private localDeviceInfo: DeviceInfo | null = null
  private onDeviceFoundCallback: (devices: DeviceInfo[]) => void = () => {}
  private onDeviceOnlineCallback: (device: DeviceInfo) => void = () => {}
  private onDeviceOfflineCallback: (device: DeviceInfo) => void = () => {}
  private isDiscovering: boolean = false
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
      this.localDeviceInfo = {
        deviceId: 'local_device',
        deviceName: '本机设备',
        deviceType: 1,
        isOnline: true
      }
      hilog.info(0, TAG, 'DeviceManagerService initialized')
    } catch (err) {
      hilog.error(0, TAG, 'Failed to init DeviceManager')
      throw err as Error
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

      try {
        this.tryRealDiscovery(resolve)
      } catch (err) {
        hilog.warn(0, TAG, 'Device discovery setup failed, using mock')
        this.startMockDiscovery(resolve)
      }
    })
  }

  private tryRealDiscovery(resolve: (devices: DeviceInfo[]) => void): void {
    hilog.info(0, TAG, 'Trying real device discovery')
    this.startMockDiscovery(resolve)
  }

  private startMockDiscovery(resolve: (devices: DeviceInfo[]) => void): void {
    hilog.info(0, TAG, 'Using mock device discovery')

    const mockDevices: DeviceInfo[] = [
      {
        deviceId: 'mock_device_1',
        deviceName: '华为Mate60 Pro',
        deviceType: 1,
        isOnline: true
      },
      {
        deviceId: 'mock_device_2',
        deviceName: '华为MatePad Pro',
        deviceType: 2,
        isOnline: true
      }
    ]

    if (this.discoverTimer !== null) {
      clearTimeout(this.discoverTimer)
    }
    this.discoverTimer = setTimeout(() => {
      this.discoveredDevices = mockDevices
      this.isDiscovering = false
      if (this.onDeviceFoundCallback) {
        this.onDeviceFoundCallback(this.discoveredDevices)
      }
      resolve(mockDevices)
    }, 2000)
  }

  stopDeviceDiscovery(): void {
    if (this.discoverTimer !== null) {
      clearTimeout(this.discoverTimer)
      this.discoverTimer = null
    }
    this.isDiscovering = false
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
  }
}

export default DeviceManagerService
