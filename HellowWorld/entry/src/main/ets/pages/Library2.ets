import { ResManager, MyTitleBar } from 'library2';
@Entry
@Component
struct Library2 {
  build() {
    Column() {
      MyTitleBar()
      Image(ResManager.getPic())
        .width(50)
        .height(50)
      Text(ResManager.getDesc())
    }
    .width('100%')
    .height('100%')
  }
}