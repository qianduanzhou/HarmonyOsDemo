import picker from '@ohos.file.picker';
import { checkPermissions, applyPermission, copyFileToCache } from 'entry/utils';
import { request } from '@kit.BasicServicesKit';
import { Permissions } from '@ohos.abilityAccessCtrl';
import camera from '@ohos.multimedia.camera';
import camerapicker from '@ohos.multimedia.cameraPicker';
import { BusinessError } from '@ohos.base';
import { common } from '@kit.AbilityKit';
import requestApi from 'request';

//上传回调数据类型
interface ReceiveRes {
  body: string
  headers: object
}


@Extend(Text)
function custText() {
  .width('100%')
  .height('48')
  .fontColor('#39364D')
  .textAlign(TextAlign.Center)
}

@CustomDialog
export default struct ImageUploadDialog {
  dialogController: CustomDialogController
  @Prop apiName:string = '';//上传接口名称
  private context = getContext(this) as common.UIAbilityContext; //UIAbilityContext
  private success: (res: ReceiveRes) => void = () => {} //上传成功回调
  private fail: (res: request.TaskState[]) => void = () => {} //上传失败回调
  private complete: (res: request.TaskState[]) => void = () => {} //上传完成回调

  //检查权限
  async checkAppPermission(): Promise<boolean> {
    try {
      const READ_MEDIA_PERMISSION: Permissions = 'ohos.permission.READ_MEDIA' //媒体读取权限
      const WRITE_MEDIA_PERMISSION: Permissions = 'ohos.permission.WRITE_MEDIA' //媒体写入权限
      let permissionList: Permissions[] = []; //需要申请选项列表
      let readPermission = await checkPermissions(READ_MEDIA_PERMISSION)//检查是否有媒体读取权限
      !readPermission && permissionList.push(READ_MEDIA_PERMISSION)
      let writePermission = await checkPermissions(WRITE_MEDIA_PERMISSION)//检查是否有媒体写入权限
      !writePermission && permissionList.push(READ_MEDIA_PERMISSION)

      if (permissionList.length) {
        //申请权限
        let res: boolean = await applyPermission(this.context, permissionList)
        if (!res) {//用户未同意授权
          AlertDialog.show({
            title: "提示",
            message: "无权限读写用户外部存储中的媒体文件信息，请前往系统设置开启",
            alignment: DialogAlignment.Center,
            secondaryButton: {
              value: '关闭',
              action: () => {
              }
            }
          })
        }
        return res
      }
      return true
    } catch (e) {
      return Promise.reject(e)
    }
  }

  //开始上传图片 path：图片路径后缀（图片名称）
  async uploadImage(path: string) {
    let uri = `internal://cache/${path}`; //上传图片全路径
    let filenameSplit = uri.split('.');
    type R = request.UploadTask
    /* 保存 */
    type Q = Array<request.File>
    let query: Q = [{
      filename: filenameSplit[0],
      name: 'files',
      uri,
      type: filenameSplit[1]
    }];
    let req = await requestApi<R, Q>(this.apiName, query);
    let err = req.err;
    if (err) return
    let uploadTask = req.res as R;
    //上传中回调
    uploadTask.on('progress', (size,total)  => {
      console.log(size.toString(),total.toString(),'上传进度')
    })

    //每上传一张图片成功回调
    uploadTask.on('headerReceive', (data: object) => {
      let res = data as ReceiveRes
      this.success && this.success(res)
    })

    //所有上传完成回调
    uploadTask.on('complete', (taskStates: request.TaskState[]) => {
      console.info("upOnComplete complete taskState:" + JSON.stringify(taskStates));
      this.complete && this.complete(taskStates)
    })
    //上传失败回调
    uploadTask.on('fail', (taskStates: request.TaskState[]) => {
      console.info("upOnComplete fail taskState:" + JSON.stringify(taskStates));
      this.fail && this.fail(taskStates)
    })
  }


  build() {
    Column() {
      //拍照
      Text('拍照').custText().onClick(async() => {
        //检查是否有读写外部媒体权限
        let res: boolean = await this.checkAppPermission()
        //无权限返回
        if (!res) return
        try {
          let pickerProfile: camerapicker.PickerProfile = {
            cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
          };
          let pickerResult: camerapicker.PickerResult = await camerapicker.pick(this.context,
            [camerapicker.PickerMediaType.PHOTO, camerapicker.PickerMediaType.PHOTO], pickerProfile);
          if(pickerResult?.resultUri){
            //关闭弹窗
            this.dialogController.close()
            //复制图片到缓存目录（缓存目录才有读写权限）
            let filePath = await copyFileToCache(pickerResult.resultUri, this.context)
            if (filePath) {
              //上传头像并设置
              this.uploadImage(filePath)
            }

          }
        } catch (error) {
          let err = error as BusinessError;
          console.error(`the pick call failed. error code: ${err.code}`);
        }

      })
      Divider().color('#F7F9FA').width('100%').strokeWidth(1)
      //从手机相册选择
      Text('从手机相册选择').custText().onClick(async () => {
        //检查是否有读写外部媒体权限
        let res: boolean = await this.checkAppPermission()
        //无权限返回
        if (!res) return
        //关闭弹窗
        this.dialogController.close()
        //从相册选择
        let PhotoSelectOptions = new picker.PhotoSelectOptions();
        PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
        PhotoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new picker.PhotoViewPicker();
        photoPicker.select(PhotoSelectOptions).then(async (PhotoSelectResult) => {
          if (PhotoSelectResult.photoUris.length) {
            //复制图片到缓存目录（缓存目录才有读写权限）
            let filePath = await copyFileToCache(PhotoSelectResult.photoUris[0],this.context)
            if (filePath) {
              this.uploadImage(filePath)
            }
          }
        })
      })
      Button('取消', { type: ButtonType.Capsule })
        .backgroundColor('#F7F7F7')
        .fontSize('16fp')
        .fontColor('#333333')
        .width('100%')
        .margin({ top: '30' })
        .onClick(() => {
          this.dialogController.close()
        })
    }.width('100%').padding({ left: '16', top: '11', right: '16', bottom: '16' })
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: '24',
      topRight: '24'
    })
  }
}
