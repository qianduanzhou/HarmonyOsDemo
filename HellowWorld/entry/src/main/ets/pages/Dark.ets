import { ConfigurationConstant } from '@kit.AbilityKit'
import { common } from '@kit.AbilityKit';

let context = getContext(this) as common.UIAbilityContext;

@Entry
@Component
struct Dark {
  @StorageProp('currentColorMode') @Watch('onColorModeChange') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;

  aboutToAppear(): void {
    if (this.currentMode == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      //当前为浅色模式，资源初始化逻辑
      console.log('浅色模式')
    }else {
      //当前为深色模式，资源初始化逻辑
      console.log('深色模式')
    }
  }

  onColorModeChange() {
    console.log('颜色切换')
  }


  build() {
    Column() {
      Text('使用系统定义配色')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({
          bottom: 20
        })
      Image($r('app.media.person'))
        .width(50)
        .height(50)
        .margin({
          bottom: 20
        })
      Button('切换深浅模式').onClick(() => {
        let colorMode = context.config.colorMode
        if (colorMode) context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
        else context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
      })
    }.width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.start_window_background'))
  }
}