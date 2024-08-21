@Component
export default struct NavDestinationPage {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text("Page NavDestination")
            .fontSize(20)
            .margin({ bottom: 100 })
          Button("Close").onClick(() => {
            this.pageStack.pop()
          }).width('30%')
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .height('100%')
        .width('100%')
      }.height("100%").width('100%')
    }
    .title('Page NavDestination')
    .mode(NavDestinationMode.STANDARD)
  }
}