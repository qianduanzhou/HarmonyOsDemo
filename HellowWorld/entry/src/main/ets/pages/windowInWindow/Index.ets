// Index.ets
// 该页面用于展示Navigation在画中画场景的使用。如果UIAbility是单页面，则无需使用Navigation
import { Page1 } from './Page1'

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private navId: string = 'navId';
  @Builder
  PageMap(name: string) {
    if (name === 'pageOne') {
      Page1({navId: this.navId});
    }
  }
  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button('pushPath', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin(20)
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'pageOne' }) // 将name指定的NavDestination页面信息入栈
          })
          .stateStyles({
            pressed: {
              .backgroundColor(Color.Red);
            },
            normal: {
              .backgroundColor(Color.Blue);
            }
          })
      }
    }.title('NavIndex').navDestination(this.PageMap)
    .id(this.navId) // 设置Navigation组件的id属性
  }
}