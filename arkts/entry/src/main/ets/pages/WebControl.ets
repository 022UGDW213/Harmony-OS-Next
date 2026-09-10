@Entry
@Component
struct WebControl {
  build() {
    Column({ space: 16 }) {
      Text('Web Control Plane')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#00D68F')

      Text('The ArkUI client can share the same reasoning and kernel APIs as the React development surface.')
        .fontSize(15)
        .fontColor('#A8B5B0')

      Text('API contract: GET /health, GET /capabilities, GET /api/kernel/status, POST /chat')
        .fontSize(14)
        .fontColor('#DCE7E2')
        .width('100%')
        .padding(16)
        .backgroundColor('#15201D')
        .borderRadius(14)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(24)
    .backgroundColor('#09110F')
  }
}
