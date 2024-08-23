
import fs from '@ohos.file.fs';
import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Context, Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common'

/**
 * 复制文件到缓存目录下
 * @param path :文件路径
 * @param context :Context
 * @returns Promise<string> 移动后文件路径
 */
export async function copyFileToCache(path: string,context:Context): Promise<string> {
  try {

    let file =  fs.openSync(path, fs.OpenMode.READ_WRITE)
    if (file) {
      let fileDir: string = `${context.cacheDir}` //临时文件目录
      //时间戳生成随机文件名
      let newPath: string =  `${new Date().getTime()}_${path.split("/")[path.split("/").length-1]}`
      let targetPath: string = `${fileDir}/${newPath}`
      fs.copyFileSync(file.fd, targetPath)
      return  newPath
    }
    else {
      return ''
    }

  } catch (e) {
    return Promise.resolve('')
  }
}

//校验应用是否授予权限
//@params permissions:权限名称数组
//@return permissionabilityAccessCtrl:权限名称
async function checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let atManager = abilityAccessCtrl.createAtManager();
  let grantStatus: abilityAccessCtrl.GrantStatus = 0;

  // 获取应用程序的accessTokenID
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (err) {
    console.error(`getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
  }

  // 校验应用是否被授予权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
  } catch (err) {
    console.error(`checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
  }

  return grantStatus;
}


//检查用户权限
//@params permissions:权限名称数组
export  async function checkPermissions(permissions: Permissions): Promise<boolean> {
  try {
    let grantStatus: abilityAccessCtrl.GrantStatus = await checkAccessToken(permissions);
    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
  }
  catch (e) {
    return Promise.reject(e)
  }
}

interface rejectObj {
  code: number
  message: string
}
/**
 * 申请权限
 * @params context:AblitiyContext
 * @params permissions:权限名称数组
 * @returns  Promise<boolean>：是否授权成功
 */
export async function applyPermission(context: common.UIAbilityContext, permissions: Array<Permissions>): Promise<boolean> {
  let atManager = abilityAccessCtrl.createAtManager();
  return new Promise((resolve: (res: boolean) => void, reject: (e: rejectObj) => void) => {
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      resolve(grantStatus.every(item => item === 0))
    }).catch((err: rejectObj) => {
      reject(err)
    })
  })
}
