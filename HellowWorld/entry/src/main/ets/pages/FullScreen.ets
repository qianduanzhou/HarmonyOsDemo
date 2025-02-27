
@Entry
struct FullScreen {
  build() {
    Column(){
      Text('沉浸式')
        .textAlign(TextAlign.Center)
        .fontColor('#ffffff')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .justifyContent(FlexAlign.Center)
  }
}