@Component
export default struct Home {
  @Consume('NavPathStack') pageStack: NavPathStack;
  build() {
    Column() {
      Text('Home')
      Button('打开弹框页面')
        .onClick(() => {
          this.pageStack.pushPathByName('NavDestinationDialog', '');
        })
        .margin({
          bottom: 30,
          top: 30
        })
      Button('打开页面')
        .onClick(() => {
          this.pageStack.pushPathByName('NavDestinationPage', '');
        })
    }
  }
}