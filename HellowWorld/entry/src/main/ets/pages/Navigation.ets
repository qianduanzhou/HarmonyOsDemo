import Home from './Home';
import Scan from './Scan';
import Profile from './Profile';
import NavDestinationDialog from './NavDestinationDialog';
import NavDestinationPage from './NavDestinationPage';

interface ToolBar {
  name: string
  path: string
  value: string
  icon: Resource
  activeIcon: Resource
}
let toolBars: Array<ToolBar> = [{
  name: '首页',
  path: 'Home',
  value: 'Home',
  icon: $r('app.media.home'),
  activeIcon: $r('app.media.home_active'),
}, {
  name: '扫一扫',
  path: 'Scan',
  value: 'Scan',
  icon: $r('app.media.scanning'),
  activeIcon: $r('app.media.scanning_active'),
}, {
  name: '我',
  path: 'Profile',
  value: 'Profile',
  icon: $r('app.media.profile'),
  activeIcon: $r('app.media.profile_active'),
}]

@Entry
@Component
struct NavigationPage {
  // 创建一个页面栈对象并传入Navigation
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()
  @Provide('ChildNavPathStack') childPageStack: NavPathStack = new NavPathStack()
  @State activeTool: string = 'Home';

  aboutToAppear() {
    this.childPageStack.replacePathByName('Home', '')
  }

  @Builder
  toolBarsBuilder() {
    Row() {
      ForEach(toolBars, (item: ToolBar) => {
        Column() {
          Image(this.activeTool === item.value ? item.activeIcon : item.icon).width(24).aspectRatio(1)
          Text(item.name)
        }.onClick(() => {
          this.activeTool = item.value
          this.childPageStack.replacePathByName(item.value, '')
        })
      })
    }.width('100%').justifyContent(FlexAlign.SpaceAround)
  }
  // 跳转外部页面
  @Builder navDestination(name: string) {
    if (name === 'NavDestinationDialog') {
      NavDestinationDialog();
    } else if (name === 'NavDestinationPage') {
      NavDestinationPage();
    }
  }
  // 子页面跳转
  @Builder childNavDestination(name: string) {
    if (name === 'Home') {
      Home();
    } else if (name === 'Scan') {
      Scan()
    } else if (name === 'Profile') {
      Profile()
    }
  }
  build() {
    Navigation(this.pageStack) {
      Navigation(this.childPageStack) {
      }.mode(NavigationMode.Auto)
      .hideTitleBar(true)
      .hideToolBar(true)
      .navDestination(this.childNavDestination)
    }.mode(NavigationMode.Auto)
    .toolbarConfiguration(this.toolBarsBuilder)
    .hideTitleBar(true)
    .navDestination(this.navDestination)
  }
}