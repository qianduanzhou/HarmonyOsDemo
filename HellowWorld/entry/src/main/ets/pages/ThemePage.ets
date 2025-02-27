import { CustomColors, CustomTheme, Theme, ThemeControl } from '@kit.ArkUI'

class AppColors implements CustomColors {
  //自定义品牌色
  brand: ResourceColor = '#FF75D9';
  fontPrimary: ResourceColor = $r('app.color.brand')
  backgroundEmphasize: ResourceColor = $r('app.color.brand')
}


class AppColorsSec implements CustomColors {
  //自定义品牌色
  brand: ResourceColor = '#510CAA';
  fontPrimary: ResourceColor = $r('app.color.brand_purple');
  backgroundEmphasize: ResourceColor = $r('app.color.brand_purple');
}

class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
}

class AppThemeSec implements CustomTheme {
  public colors: AppColors = new AppColorsSec()
}

let gAppTheme: CustomTheme = new AppTheme()

//在页面build前执行ThemeControl
ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct ThemePage {
  @State menuItemColor: ResourceColor = $r('sys.color.background_primary')
  @State customTheme: CustomTheme = new AppTheme()
  @State message: string = '设置应用局部页面自定义主题风格'
  count = 0;

  onWillApplyTheme(theme: Theme) {
    this.menuItemColor = theme.colors.backgroundPrimary;
  }

  build() {
    Column() {
      List({ space: 10 }) {
        ListItem() {
          Column({ space: '5vp' }) {
            Text('Color mode')
              .margin({ top: '5vp', left: '14fp' })
              .width('100%')
            Row() {
              Column() {
                Text('Light')
                  .fontSize('16fp')
                  .textAlign(TextAlign.Start)
                  .alignSelf(ItemAlign.Center)
                Radio({ group: 'light or dark', value: 'light' })
                  .checked(true)
              }
              .width('50%')

              Column() {
                Text('Dark')
                  .fontSize('16fp')
                  .textAlign(TextAlign.Start)
                  .alignSelf(ItemAlign.Center)
                Radio({ group: 'light or dark', value: 'dark' })
              }
              .width('50%')
            }
          }
          .width('100%')
          .height('90vp')
          .borderRadius('10vp')
          .backgroundColor(this.menuItemColor)
        }

        ListItem() {
          Column() {
            Text('Brightness')
              .width('100%')
              .margin({ top: '5vp', left: '14fp' })
            Slider({ value: 40, max: 100 })
          }
          .width('100%')
          .height('70vp')
          .borderRadius('10vp')
          .backgroundColor(this.menuItemColor)
        }

        ListItem() {
          Column() {
            Row() {
              Column({ space: '5vp' }) {
                Text('Touch sensitivity')
                  .fontSize('16fp')
                  .textAlign(TextAlign.Start)
                  .width('100%')
                Text('Increase the touch sensitivity of your screen' +
                  ' for use with screen protectors')
                  .fontSize('12fp')
                  .fontColor(Color.Blue)
                  .textAlign(TextAlign.Start)
                  .width('100%')
              }
              .alignSelf(ItemAlign.Center)
              .margin({ left: '14fp' })
              .width('75%')

              Toggle({ type: ToggleType.Switch, isOn: true })
                .margin({ right: '14fp' })
                .alignSelf(ItemAlign.Center)
            }
            .width('100%')
            .height('80vp')
          }
          .width('100%')
          .borderRadius('10vp')
          .backgroundColor(this.menuItemColor)
        }
      }
      WithTheme({ theme: this.customTheme }) {
        Row(){
          Column() {
            Text('WithTheme')
              .fontSize(30)
              .margin({bottom: 10})
            Text(this.message)
              .margin({bottom: 10})
            Button('change theme').onClick(() => {
              this.count++;
              if (this.count > 1) {
                this.count = 0;
              }
              switch (this.count) {
                case 0:
                  this.customTheme = new AppTheme();
                  break;
                case 1:
                  this.customTheme = new AppThemeSec();
                  break;
              }
            })
          }
          .width('100%')
        }
        .height('100%')
        .width('100%')
      }
    }
    .padding('10vp')
    .backgroundColor('#dcdcdc')
    .width('100%')
    .height('100%')
  }
}