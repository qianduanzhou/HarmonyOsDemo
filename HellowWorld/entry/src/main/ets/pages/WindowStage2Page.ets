/**
 * 子窗口
 */
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

let context = getContext(this) as common.UIAbilityContext;
// 1.获取应用主窗口。
let windowClass: window.Window | undefined = undefined;

@Entry
@Component
struct WindowStage2Page {
  @State message: string = '悬浮窗口';
  private CreateWindow() {
    let config: window.Configuration = {
      name: "floatWindow", windowType: window.WindowType.TYPE_FLOAT, ctx: context
    };
    window.createWindow(config, (err: BusinessError, data) => {
      let errCode: number = err.code;
      if (errCode) {
        console.error('Failed to create the floatWindow. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in creating the floatWindow. Data: ' + JSON.stringify(data));
      windowClass = data;
      // 2.悬浮窗窗口创建成功后，设置悬浮窗的位置、大小及相关属性等。
      windowClass.moveWindowTo(300, 300, (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          console.error('Failed to move the window. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in moving the window.');
      });
      windowClass.resize(500, 500, (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          console.error('Failed to change the window size. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in changing the window size.');
      });
      // 3.为悬浮窗加载对应的目标页面。
      windowClass.setUIContent("pages/SubWindow", (err: BusinessError) => {
        let errCode: number = err.code;
        if (errCode) {
          console.error('Failed to load the content. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in loading the content.');
        // 3.显示悬浮窗。
        (windowClass as window.Window).showWindow((err: BusinessError) => {
          let errCode: number = err.code;
          if (errCode) {
            console.error('Failed to show the window. Cause: ' + JSON.stringify(err));
            return;
          }
          console.info('Succeeded in showing the window.');
        });
      });
    })
  }
  private destroyWindow() {
    // 4.销毁悬浮窗。当不再需要悬浮窗时，可根据具体实现逻辑，使用destroy对其进行销毁。
    (windowClass as window.Window).destroyWindow((err: BusinessError) => {
      let errCode: number = err.code;
      if (errCode) {
        console.error('Failed to destroy the window. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in destroying the window.');
    });
  }
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button(){
          Text('CreateWindow')
            .fontSize(24)
            .fontWeight(FontWeight.Normal)
        }.width(220).height(68)
        .margin({left:10, top:60})
        .onClick(() => {
          this.CreateWindow()
        })
        Button(){
          Text('destroyWindow')
            .fontSize(24)
            .fontWeight(FontWeight.Normal)
        }.width(220).height(68)
        .margin({left:10, top:60})
        .onClick(() => {
          this.destroyWindow()
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}