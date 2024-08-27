@Entry
@Component
struct Singleton {
  aboutToAppear() {

  }

  build() {
    Column() {
      Text('Singleton')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
  }
}