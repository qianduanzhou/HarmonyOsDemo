@Component
export default struct PageLoading {
  build() {
    Column() {
      LoadingProgress()
        .color(Color.White)
        .width(80).height(80)
      Text('努力加载中..')
        .fontSize(16)
        .fontColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#40000000')
    .justifyContent(FlexAlign.Center)
    .position({
      top: 0
    })
  }
}