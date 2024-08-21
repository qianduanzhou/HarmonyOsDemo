import { encryption } from 'utils/encryption';
import { promptAction, router, font } from '@kit.ArkUI';
import request from "request";
import PageLoading from 'ets/components/PageLoading';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
const options: preferences.Options = { name: 'myStore' };
const dataPreferences: preferences.Preferences = preferences.getPreferencesSync(getContext(), options);

// 顶部标题样式
@Extend(Text) function topTitle() {
  .fontSize(28)
  .fontColor('#141719')
  .fontFamily('DingTalk JinBuTi')
}
// 输入框标题样式
@Extend(Text) function inputTitle() {
  .fontSize(14)
  .fontColor('#44494C')
  .margin({
    bottom: 8
  })
}
// 输入框样式
@Extend(TextInput) function input() {
  .backgroundColor('#FFFFFF')
  .padding(0)
  .fontSize(14)
  .fontColor('#44494C')
  .placeholderColor('#ABAEB2')
  .placeholderFont({
    size: 14
  })
}
// 输入框父元素样式
@Extend(Flex) function inputWrap() {
  .width('100%')
  .height(44)
  .border({
    width: 1,
    color: '#E4EAF6',
    radius: 4
  })
  .padding({
    left: 10
  })
}


@Entry
@Component
struct Login {
  @State username: string = '' // 用户名
  @State password: string = '' // 密码
  @State ver_code: string = '' // 验证码
  @State ver_image: string = '' // 验证码图片
  @State ver_key: string = '' // 验证码key
  @State protocolChecked: boolean = false // 协议查看
  @State isLoading: boolean = false // 是否加载中

  aboutToAppear() {
    font.registerFont({
      familyName: 'DingTalk JinBuTi',
      familySrc: $rawfile('font/DingTalk JinBuTi.ttf')
    })
    this.getCode();
  }

  // 是否展示组件
  @Builder handlePageLoading() {
    if (this.isLoading) PageLoading();
  }

  // 获取验证码
  async getCode() {
    interface R {
      ver_image: string,
      ver_key: string
    }
    let req = await request<R>('getVerCode');
    let err = req.err;
    let res = req.res as R;
    if (err) return
    console.info('getVerCode', res);
    this.ver_image = res.ver_image;
    this.ver_key = res.ver_key;
  }
  // 登录
  async login() {
    if (!this.protocolChecked) {
      promptAction.showToast({
        message: '请先勾选协议！'
      })
      return
    }
    this.isLoading = true;
    interface R {
      access_token: string
    }
    interface Q {
      username: string
      password: string
      ver_key: string
      grant_type: string
      ver_code: string
    }
    let query: Q = {
      username: this.username,
      password: encryption(this.password, '-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDKRXq3p8VoLB4P5H3aeIbwABaXJNDDfAXX/ePpY/kXCnIQbZOaxgxVOP2bYnldDxgQ3j9OiUq2celccy4ohROcGA7JCmkDqKCcLHyRlxYScbFOhO5EDac/DsRytebt03R/H1wSfVloIbIMIjN2tN+58RxUxLUhITyPGwLngPjf+wIDAQAB-----END PUBLIC KEY-----'),
      ver_key: this.ver_key,
      grant_type: 'password',
      ver_code: this.ver_code
    }
    let req = await request<R, Q>('login', query);
    this.isLoading = false;
    let err = req.err;
    if (err) return
    let res = req.res as R;
    let token = 'Bearer ' + res.access_token;

    dataPreferences?.putSync('token', token);

    promptAction.showToast({
      message: '登录成功',
      duration: 1500
    })
    setTimeout(() => {
      router.pushUrl({ url: 'pages/Home' }).then(() => {
        console.info('跳转首页')
      }).catch((err: BusinessError) => {
        console.error('跳转失败:', err)
      })
    }, 1500)
  }
  build() {
    Flex({
      direction: FlexDirection.Column
    }) {
      Stack() {
        Image($r('app.media.ic_login_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Start
        }) {
          Text('欢迎登录')
            .topTitle()
          Text('智清智慧巡检')
            .topTitle()
          Row()
            .width(32)
            .height(4)
            .backgroundColor('#408CFF')
            .borderRadius(20)
            .margin({
              top: 22
            })
        }
        .width('100%')
        .margin({
          top: 80
        })
        .padding({
          left: 45
        })
      }
      .width('100%')
      .height(237)
      Column() {
        Column() {
          Text('用户名')
            .inputTitle()
          Flex({
            alignItems: ItemAlign.Center
          }) {
            TextInput({
              placeholder: '请输入用户名',
              text: this.username
            })
              .input()
              .onChange((value: string) => {
                this.username = value;
              })
            Image($r('app.media.ic_close'))
              .width(20)
              .height(20)
              .onClick(() => {
                this.username = '';
                console.info('this.username', this.username)
              })
          }
          .inputWrap()
          .padding({
            left: 10,
            right: 20
          })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          bottom: 8
        })
        Column() {
          Text('密码')
            .inputTitle()
          Flex({
            alignItems: ItemAlign.Center
          }) {
            TextInput({
              placeholder: '请输入密码',
              text: this.password
            })
              .input()
              .type(InputType.Password)
              .passwordIcon({
                onIconSrc: $r('app.media.ic_close_eye'),
                offIconSrc: $r('app.media.ic_open_eye')
              })
              .onChange((value: string) => {
                this.password = value;
              })
          }
          .inputWrap()
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          bottom: 8
        })

        Column() {
          Text('验证码')
            .inputTitle()
          Flex({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Flex({
              alignItems: ItemAlign.Center
            }) {
              TextInput({
                placeholder: '请输入验证码',
                text: this.ver_code
              })
                .input()
                .onChange((value: string) => {
                  this.ver_code = value;
                })
            }
            .inputWrap()
            .width(150)
            Image(this.ver_image)
              .width(100)
              .height(44)
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                this.getCode()
              })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({
          bottom: 8
        })
        Button('登录', {
          type: ButtonType.Normal
        })
          .width('100%')
          .height(42)
          .margin({
            top: 32
          })
          .fontColor('#fff')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .backgroundColor('#408CFF')
          .borderRadius(30)
          .onClick(() => {
            this.login();
          })
      }
      .padding({
        top: 8,
        left: 45,
        right: 45
      })
      Column() {
        Column() {
          Text($r('app.string.company_zh_name'))
            .fontColor('#BDD7FF')
            .fontSize(14)
          Text($r('app.string.company_en_name'))
            .fontColor('#BDD7FF')
            .fontSize(8)
        }
        .width('100%')
        .position({
          top: 70
        })
        Flex({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Image(this.protocolChecked ? $r('app.media.ic_done_b') : $r('app.media.ic_unCheck'))
            .width(12)
            .height(12)
            .margin({
              right: 5
            })
          Text('登录即代表同意')
            .fontSize(12)
            .fontColor('#868A8F')
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#5297FE')
          Text('《隐私协议》')
            .fontSize(12)
            .fontColor('#5297FE')
        }
        .width('100%')
        .position({
          bottom: 10
        })
        .onClick(() => {
          this.protocolChecked = !this.protocolChecked;
        })
      }
      .height(0)
      .flexGrow(1)
      this.handlePageLoading()
    }
    .width('100%')
    .height('100%')
  }
}