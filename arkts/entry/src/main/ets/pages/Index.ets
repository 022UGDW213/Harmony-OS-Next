import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  @State apiStatus: string = 'Checking API…'
  @State kernelStatus: string = 'Unknown'

  aboutToAppear(): void {
    this.checkHealth()
  }

  async checkHealth(): Promise<void> {
    try {
      const response = await fetch('http://localhost:3003/health')
      const body = await response.json()
      this.apiStatus = body.status === 'online' ? 'Online' : 'Limited'
      this.kernelStatus = body.aiCapabilities?.reasoning ? 'Reasoning ready' : 'Fallback mode'
    } catch (_) {
      this.apiStatus = 'Offline'
      this.kernelStatus = 'API unavailable'
    }
  }

  build() {
    Column({ space: 18 }) {
      Text('Harmony OS Next')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#00D68F')

      Text('ArkUI full-stack control surface')
        .fontSize(16)
        .fontColor('#A8B5B0')

      Column({ space: 10 }) {
        Text(`Reasoning API: ${this.apiStatus}`)
        Text(`System status: ${this.kernelStatus}`)
      }
      .width('100%')
      .padding(18)
      .borderRadius(16)
      .backgroundColor('#15201D')

      Button('Refresh status')
        .onClick(() => this.checkHealth())
        .backgroundColor('#00D68F')
        .fontColor('#07110D')
        .width('100%')

      Button('Open web control plane')
        .onClick(() => router.pushUrl({ url: 'pages/WebControl' }))
        .backgroundColor('#203B5C')
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(24)
    .backgroundColor('#09110F')
  }
}
