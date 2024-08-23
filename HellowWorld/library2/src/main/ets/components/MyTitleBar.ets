@Component
export struct MyTitleBar {
  build() {
    Row() {
      Text('HSP')
        .id('library')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize(32)
        .fontColor('#000')
    }
    .width('100%')
  }
}