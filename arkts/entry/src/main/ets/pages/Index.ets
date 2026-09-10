@Entry
@Component
struct Index {
  @State apiStatus: string = 'Checking…'

  async aboutToAppear(): Promise<void> {
    try {
      const response = await fetch('http://localhost:3003/health')
      const body = await response.json()
      this.apiStatus = body.status
    } catch (_) {
      this.apiStatus = 'offline'
    }
  }

  build() {
    Column({ space: 18 }) {
      Text('Harmony OS Next').fontSize(30).fontWeight(FontWeight.Bold).fontColor('#00D68F')
      Text('Native ArkUI client').fontSize(16).fontColor('#A8B5B0')
      Text(`API: ${this.apiStatus}`).width('100%').padding(18).backgroundColor('#15201D').borderRadius(16)
      Button('Refresh').onClick(() => this.aboutToAppear()).backgroundColor('#00D68F').fontColor('#07110D').width('100%')
    }.width('100%').height('100%').justifyContent(FlexAlign.Center).padding(24).backgroundColor('#09110F')
  }
}
