import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ENV } from 'entry/config';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @Builder
  jumpBtn(path: string, text: string, info: string) {
    Button() {
      Text(text).fontColor('#ffffff').fontSize(16).fontWeight(FontWeight.Bold)
    }
    .type(ButtonType.Capsule)
    .commonBtnStyle()
    .onClick(() => {
      router.pushUrl({ url: path }).then(() => {
        console.info(info)
      }).catch((err: BusinessError) => {
        console.error('跳转失败:', err)
      })
    })
  }
  @Styles
  commonBtnStyle() {
    .width(200)
    .height(50)
    .margin({
      top: 10
    })
  }


  onPageShow() {

  }

  onPageHide() {

  }

  onBackPress() {

  }

  aboutToAppear() {

  }

  onDidBuild() {

  }

  aboutToDisappear() {

  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Text(`当前环境:${ENV}`)
          .fontSize(30)
        this.jumpBtn('pages/Login', 'To Login', '跳转登录页')
        this.jumpBtn('pages/Picture', 'To Picture', '跳转选择图片页')
        this.jumpBtn('pages/CurCamera', 'To Camera', '跳转相机页')
        this.jumpBtn('pages/Animatable', 'To Animatable', '跳转动画页')
      }
      .width('100%')
    }
    .height('100%')
  }
}