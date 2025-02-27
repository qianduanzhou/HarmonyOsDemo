import { webview } from '@kit.ArkWeb';

webview.once("webInited", () => {
  console.log("configCookieSync");
  webview.WebCookieManager.configCookieSync("https://www.example.com", "a=b");
})

@Entry
@Component
struct Webview {
  controller: webview.WebviewController = new webview.WebviewController();
  @State mode: CacheMode = CacheMode.None;
  build() {
    Column() {
      Web({ src: 'http://172.16.124.98:5173', controller: this.controller }).domStorageAccess(true)
    }
  }
}