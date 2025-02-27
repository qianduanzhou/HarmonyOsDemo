import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ENV } from 'entry/config';
import { common, Want, EnvironmentCallback, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { bundleManager } from '@kit.AbilityKit';

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
    ListItem() {
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
    }.width('100%')
  }

  // 公用跳转按钮
  @Builder
  jumpAbilityBtn(abilityName: string, text: string) {
    ListItem() {
      Button() {
        Text(text).fontColor('#ffffff').fontSize(16).fontWeight(FontWeight.Bold)
      }
      .type(ButtonType.Capsule)
      .commonBtnStyle()
      .onClick(() => {
        let want: Want = {
          bundleName: 'com.example.myapplicationzhb',
          abilityName
        };

        this.context.startAbility(want, (err: BusinessError) => {
          if (err.code) {
            // 显式拉起Ability，通过bundleName、abilityName和moduleName可以唯一确定一个Ability
            console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
          }
        });
      })
    }.width('100%')
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
    let flag = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO;
    let bundleInfo = bundleManager.getBundleInfoForSelfSync(flag)
    let appId = bundleInfo.signatureInfo.appId;
    console.log("appId", appId);
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
        List() {
          this.jumpPageBtn('pages/Login', 'To Login', '跳转登录页')
          this.jumpPageBtn('pages/Picture', 'To Picture', '跳转选择图片页')
          this.jumpPageBtn('pages/CurCamera', 'To Camera', '跳转相机页')
          this.jumpPageBtn('pages/Animatable', 'To Animatable', '跳转动画页')
          this.jumpPageBtn('pages/Library', 'To Library', '跳转引用HAR页')
          this.jumpPageBtn('pages/Library2', 'To Library2', '跳转引用HSP页')
          this.jumpPageBtn('pages/windowInWindow/Index', 'To WindowInWindow', '跳转画中画页')
          this.jumpPageBtn('pages/Webview', 'To Webview', '跳转webview页')
          this.jumpPageBtn('pages/Map', 'To Map', '跳转地图页')
          this.jumpPageBtn('pages/AMapPage', 'To AMap', '跳转高德地图页')
          this.jumpPageBtn('pages/TaskPool', 'To TaskPool', '跳转TaskPool地图页')
          this.jumpPageBtn('pages/Worker', 'To Worker', '跳转Worker地图页')
          this.jumpPageBtn('pages/BindSheet', 'To BindSheet', '跳转半模态转场地图页')
          this.jumpAbilityBtn('BindSheet', 'SingletonAbility')
        }
        .width('100%')
        .height('90%')
        .padding({top: 10, bottom: 10})
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
  }
}