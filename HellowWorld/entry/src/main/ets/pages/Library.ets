import { MainPage } from 'library';
@Entry
@Component
struct Library {
  build() {
    Column() {
      MainPage()
    }
    .width('100%')
    .height('100%')
  }
}