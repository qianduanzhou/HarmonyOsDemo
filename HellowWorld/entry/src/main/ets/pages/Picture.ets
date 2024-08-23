import ImageUploadDialog from '../components/ImageUploadDialog'
import { promptAction } from '@kit.ArkUI'
interface Data {
  url: string
}
interface Res {
  data: Array<Data>
}
@Entry
@Component
struct Picture {
  @State uri :string = ''
  @State dialogController: CustomDialogController | null = null //选择上传类型弹窗控制器
  aboutToAppear(): void {
    this.dialogController = new CustomDialogController({
      builder: ImageUploadDialog({
        apiName: 'uploadBatch',//上传地址
        success: e => {//上传成功回调，e上传成功接口返回数据
          let res = JSON.parse(e.body) as Res //接口上传成功返回数据
          console.log('上传成功', JSON.stringify(res))
          this.uri = res.data[0].url;
        },
        fail: e => {//上传失败回调
          console.log(JSON.stringify(e))
          promptAction.showToast({message:'上传失败'})
        },
        complete: e => {//上传完成回调
          console.log('complete', JSON.stringify(e))
        }
      }),
      alignment: DialogAlignment.Bottom,//弹窗居于底部
      customStyle: true,//自定义样式
    })
  }
  build() {
    Column(){
      Button('上传').onClick(()=>{
        this.dialogController?.open()
      })
        .margin({
          top: 20,
          bottom: 20
        })
      Image(this.uri)
        .width(200)
        .height(200)
    }.width('100%')
  }
}