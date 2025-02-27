import { BusinessError } from "@kit.BasicServicesKit";

@Component
export default struct Home {
  @Consume('NavPathStack') pageStack: NavPathStack;
  build() {
    NavDestination() {
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
            this.pageStack.pushDestinationByName('NavDestinationPage', '', (popInfo) => {
              console.log('Pop page name is: ' + popInfo.info.name + ', result: ' + JSON.stringify(popInfo.result))
            }).catch((error: BusinessError) => {
              console.error(`Push destination failed, error code = ${error.code}, error.message = ${error.message}.`)
            }).then(() => {
              console.info('Push destination succeed.')
            })
          })
      }
    }.mode(NavDestinationMode.STANDARD)
    .hideTitleBar(true)
  }
}