import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import requestApi from 'request';
import { dataSharePredicates } from '@kit.ArkData';
import File from '@system.file';
import fileIO from '@ohos.fileio';

const context = getContext(this);
const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
photoSelectOptions.maxSelectNumber = 5; // 选择媒体文件的最大数目

let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);

class MediaDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {
  onDataPrepared(data: ArrayBuffer) {
    if (data === undefined) {
      console.error('Error occurred when preparing data');
      return;
    }
    console.info('on image data prepared');
    // 应用自定义对资源数据的处理逻辑
  }
}


@Extend(Button) function BtnStyle() {
  .width(200)
  .margin({
    bottom: 20
  })
}

@Entry
@Component
struct Picture {
  @State uri :string = ''

  build() {
    Row(){
      Column(){
        Button('选择图片')
          .onClick(async ()=>{
            let uris: Array<string> = [];
            const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
            photoViewPicker.select(photoSelectOptions).then(async (photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
              uris = photoSelectResult.photoUris;
              let uri = uris.toString()
              this.uri = uri;
              console.info('photoViewPicker.select to file succeed and uris are:' + uris);
              let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
              console.info('file fd: ' + file.fd);
              console.info('file name: ' + file.name);
              console.info('file path: ' + file.path);
              fileIo.closeSync(file.fd)
              let filenameSplit = file.name.split('.');
              interface T {

              }
              /* 保存 */
              type Q = Array<request.File>
              let query: Q = [{
                filename: filenameSplit[0],
                name: 'files',
                uri,
                type: filenameSplit[1]
              }];

              let req = await requestApi<T, Q>('uploadBatch', query);
              let err = req.err;
              let res = req.res;
              console.info('uploadBatch', res);
              console.info('uploadBatchErr', err?.message);

              // let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
              // predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri.toString());
              // let fetchOptions: photoAccessHelper.FetchOptions = {
              //   fetchColumns: [photoAccessHelper.PhotoKeys.TITLE],
              //   predicates: predicates
              // };

              // try {
              //   let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await phAccessHelper.getAssets(fetchOptions);
              //   let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
              //   console.info('getAssets photoAsset.uri : ' + photoAsset.uri);
              //   // 获取属性值，以标题为例；对于非默认查询的属性，get前需要在fetchColumns中添加对应列名
              //   console.info('title : ' + photoAsset.get(photoAccessHelper.PhotoKeys.TITLE));
              //   // 请求图片资源数据
              //   let requestOptions: photoAccessHelper.RequestOptions = {
              //     deliveryMode: photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE,
              //   }
              //   await photoAccessHelper.MediaAssetManager.requestImageData(context, photoAsset, requestOptions, new MediaDataHandler());
              //   console.info('requestImageData successfully');
              //   fetchResult.close();
              // } catch (err) {
              //   console.error('getAssets failed with err: ' + err);
              // }
            }).catch((err: BusinessError) => {
              console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
            })
          }).BtnStyle()
        Image(this.uri).size({width:200, height: 200})
      }
      .width("100%")
    }
    .height("100%")
  }
}