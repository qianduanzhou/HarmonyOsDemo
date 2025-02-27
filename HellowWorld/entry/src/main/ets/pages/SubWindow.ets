// subWindow.ets
@Entry
@Component
struct SubWindow {
  @State message: string = 'Hello subWindow';
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
      }
      .width('100%')
    }
    .height('100%')
    .backgroundColor('#000000')
  }
}