@Component
export default struct NavDestinationPage {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text("页面内容")
            .fontSize(20)
            .margin({ bottom: 100 })
          Button("关闭").onClick(() => {
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
    .title('页面标题')
    .mode(NavDestinationMode.STANDARD)
  }
}