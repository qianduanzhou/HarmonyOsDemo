@Component
export default struct NavDestinationDialog {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text("Dialog NavDestination")
            .fontSize(20)
            .margin({ bottom: 100 })
          Button("Close").onClick(() => {
            this.pageStack.pop()
          }).width('30%')
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .height('30%')
        .width('80%')
      }.height("100%").width('100%')
    }
    .backgroundColor('rgba(0,0,0,0.5)')
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
  }
}