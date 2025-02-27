import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { promptAction } from '@kit.ArkUI';
import { abilityAccessCtrl, common, bundleManager, Permissions } from '@kit.AbilityKit';

// 确认是否有权限
async function checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

  // 获取应用程序的accessTokenID
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
  }

  // 校验应用是否被授予权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
  }

  return grantStatus;
}

// 申请权限
const permissions: Array<Permissions> = ['ohos.permission.LOCATION','ohos.permission.APPROXIMATELY_LOCATION'];
// 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext, mapController: map.MapComponentController): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
      } else {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        return;
      }
    }
    // 授权成功

    // 启用我的位置图层
    mapController.setMyLocationEnabled(true);
    // 启用我的位置按钮
    mapController.setMyLocationControlsEnabled(true);
  }).catch((err: BusinessError) => {
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}

@Entry
@Component
struct Map {
  private TAG = "HuaweiMapDemo";
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  aboutToAppear(): void {
    // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

    // 地图初始化参数，设置地图中心点坐标及层级
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.9,
          longitude: 116.4
        },
        zoom: 10
      },
      mapType: mapCommon.MapType.STANDARD
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        reqPermissionsFromUser(permissions, context, this.mapController);
        let callback = () => {
          console.info(this.TAG, `on-mapLoad`);
        }
        this.mapEventManager.on("mapLoad", callback);
      }
    };
  }

  // 页面每次显示时触发一次，包括路由过程、应用进入前台等场景，仅@Entry装饰的自定义组件生效
  onPageShow(): void {
    // 将地图切换到前台
    if (this.mapController) {
      this.mapController.show();
    }
  }

  // 页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景，仅@Entry装饰的自定义组件生效
  onPageHide(): void {
    // 将地图切换到后台
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  // 点击定位按钮
  async local(mapController: map.MapComponentController | undefined) {
    let grantStatus1: boolean = await checkPermissionGrant('ohos.permission.LOCATION') === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;// 获取精确定位权限状态
    let grantStatus2: boolean = await checkPermissionGrant('ohos.permission.APPROXIMATELY_LOCATION') === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;// 获取模糊定位权限状态
    // 精确定位权限只能跟模糊定位权限一起申请，或者已经有模糊定位权限才能申请精确定位权限
    if (grantStatus2 && !grantStatus1) {
      // 申请精确定位权限
    } else if (!grantStatus1 && !grantStatus2) {
      // 申请模糊定位权限与精确定位权限或单独申请模糊定位权限
    } else {
      // 已经授权，可以继续访问目标操作
      try {
        let locationEnabled = geoLocationManager.isLocationEnabled();
        if (!locationEnabled) {
          promptAction.showToast({"message": "定位权限未打开"});
          return
        }
        try {
          // 判断是否有缓存
          let location = geoLocationManager.getLastLocation();
          console.log("locationCache", JSON.stringify(location));
          this.mapLocal(location, mapController)
        } catch (err) {
          console.error("errCode:" + JSON.stringify(err));
          // 获取当前位置
          let request: geoLocationManager.SingleLocationRequest = {
            'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
            'locatingTimeoutMs': 10000
          }
          try {
            geoLocationManager.getCurrentLocation(request).then((result) => { // 调用getCurrentLocation获取当前设备位置，通过promise接收上报的位置
              console.log('current location: ' + JSON.stringify(result));
              this.mapLocal(result, mapController)
            }).catch((error: BusinessError) => { // 接收上报的错误码
              console.error('promise, getCurrentLocation: error=' + JSON.stringify(error));
            });
          } catch (err) {
            console.error("errCode:" + JSON.stringify(err));
          }
        }
      } catch (err) {
        console.error("err:" + err);
      }
    }
  }

  // 地图定位方法
  mapLocal(location: geoLocationManager.Location, mapController: map.MapComponentController | undefined) {
    // 创建CameraUpdate对象
    let cameraPosition: mapCommon.CameraPosition = {
      target: {
        latitude: location.latitude,
        longitude: location.longitude
      },
      zoom: 15,
      tilt: 0,
      bearing: 0
    };
    let cameraUpdate = map.newCameraPosition(cameraPosition);
    // 以非动画方式移动地图相机
    // mapController?.moveCamera(cameraUpdate);
    // 以动画方式移动地图相机
    mapController?.animateCamera(cameraUpdate, 1000);
  }

  // 点击locationButton按钮
  locationButtonClick(event: ClickEvent, result: LocationButtonOnClickResult, mapController: map.MapComponentController | undefined) {
    if (result === LocationButtonOnClickResult.SUCCESS) {
      try {
        // 免去权限申请和权限请求等环节，获得临时授权，获取位置信息授权
        const requestInfo: geoLocationManager.LocationRequest = {
          'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
          'scenario': geoLocationManager.LocationRequestScenario.UNSET,
          'timeInterval': 1,
          'distanceInterval': 0,
          'maxAccuracy': 0
        };

        // 获取当前位置，使用Promise方式异步返回结果。
        geoLocationManager.getCurrentLocation(requestInfo)
          .then((location: geoLocationManager.Location) => {
            this.mapLocal(location, mapController)
            const latitude = location.latitude
            const longitude = location.longitude
            let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest =
              { latitude, longitude, "maxItems": 1 };
            try {
              // 调用逆地理编码服务，将坐标转换为地理描述，使用Promise异步回调
              geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest)
                .then((data) => {
                  // Logger.info('getAddressesFromLocation: ' + JSON.stringify(data));
                  let address = data[0].placeName!
                  console.log('address', address)
                })
                .catch((error: BusinessError) => {
                  console.error('promise, getAddressesFromLocation: error=' + JSON.stringify(error));
                });
            } catch (err) {
              console.error("errCode:" + JSON.stringify(err));
            }
          })
          .catch((err: BusinessError) => {
            console.error(`Failed to get current location. Code is ${err.code}, message is ${err.message}`);
          });
      } catch (e) {     // 错误处理
        if (e.code === '3301100') {
          promptAction.showToast({
            message: '请开启定位开关~'
          })
        }
      }

    } else {
      promptAction.showToast({ message: '获取位置信息失败！' })
    }
  }

  build() {
    Stack() {
      // 调用MapComponent组件初始化地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback }).width('100%').height('100%');
      Button("定位").width(100).height(50).margin({bottom: 100}).onClick(() => this.local(this.mapController))
      Column(){
        LocationButton().onClick((event: ClickEvent, result: LocationButtonOnClickResult) => this.locationButtonClick(event, result, this.mapController))
      }.margin({bottom: 30})
    }.height('100%').align(Alignment.Bottom)
  }
}