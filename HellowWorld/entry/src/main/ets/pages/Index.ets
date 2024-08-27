import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ENV } from 'entry/config';
import { common, Want, EnvironmentCallback, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[CollaborateAbility]';
const DOMAIN_NUMBER: number = 0xFF00;

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private context = getContext(this) as common.UIAbilityContext; // UIAbilityContext
  private callbackId: number = 0; // 注册订阅系统环境变化的ID

  // 订阅环境变化
  subscribeConfigurationUpdate(): void {
    let systemLanguage: string | undefined = this.context.config.language; // 获取系统当前语言

    // 1.获取ApplicationContext
    let applicationContext = this.context.getApplicationContext();

    // 2.通过applicationContext订阅环境变量变化
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated(newConfig: Configuration) {
        hilog.info(DOMAIN_NUMBER, TAG, `onConfigurationUpdated systemLanguage is ${systemLanguage}, newConfig: ${JSON.stringify(newConfig)}`);
        if (this.systemLanguage !== newConfig.language) {
          hilog.info(DOMAIN_NUMBER, TAG, `systemLanguage from ${systemLanguage} changed to ${newConfig.language}`);
          systemLanguage = newConfig.language; // 将变化之后的系统语言保存，作为下一次变化前的系统语言
        }
      },
      onMemoryLevel(level) {
        hilog.info(DOMAIN_NUMBER, TAG, `onMemoryLevel level: ${level}`);
      }
    }
    try {
      this.callbackId = applicationContext.on('environment', environmentCallback);
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      hilog.error(DOMAIN_NUMBER, TAG, `Failed to register applicationContext. Code is ${code}, message is ${message}`);
    }
  }

  // 取消环境变化订阅
  unsubscribeConfigurationUpdate() {
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.off('environment', this.callbackId);
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      hilog.error(DOMAIN_NUMBER, TAG, `Failed to unregister applicationContext. Code is ${code}, message is ${message}`);
    }
  }


  // 公用跳转页面按钮
  @Builder
  jumpPageBtn(path: string, text: string, info: string) {
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

  // 公用跳转按钮
  @Builder
  jumpAbilityBtn(abilityName: string, text: string) {
    Button() {
      Text(text).fontColor('#ffffff').fontSize(16).fontWeight(FontWeight.Bold)
    }
    .type(ButtonType.Capsule)
    .commonBtnStyle()
    .onClick(() => {
      let want: Want = {
        bundleName: 'com.example.myapplication',
        abilityName
      };

      this.context.startAbility(want, (err: BusinessError) => {
        if (err.code) {
          // 显式拉起Ability，通过bundleName、abilityName和moduleName可以唯一确定一个Ability
          console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
        }
      });
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
        this.jumpPageBtn('pages/Login', 'To Login', '跳转登录页')
        this.jumpPageBtn('pages/Picture', 'To Picture', '跳转选择图片页')
        this.jumpPageBtn('pages/CurCamera', 'To Camera', '跳转相机页')
        this.jumpPageBtn('pages/Animatable', 'To Animatable', '跳转动画页')
        this.jumpPageBtn('pages/Library', 'To Library', '跳转引用HAR页')
        this.jumpPageBtn('pages/Library2', 'To Library2', '跳转引用HSP页')
        this.jumpAbilityBtn('SingletonAbility', 'SingletonAbility')
      }
      .width('100%')
    }
    .height('100%')
  }
}