import { AMap, MapsInitializer, MapView, MapViewComponent, MapViewManager, CameraUpdateFactory, LatLng,
  MyLocationStyle, LocationSource, OnLocationChangedListener, MarkerOptions,BitmapDescriptorFactory, Marker,
  OnMarkerDragListener, PolylineOptions, CircleOptions, CircleHoleOptions,
  PolygonOptions,
  PolygonHoleOptions} from '@amap/amap_lbs_map3d';
import {MapType} from '@amap/amap_lbs_map3d';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { common } from '@kit.AbilityKit';
import { ArrayList } from '@kit.ArkTS';

const globalContext = getContext(this) as common.UIAbilityContext;

MapsInitializer.setApiKey("9ace9dce2230f92c80cbf69b7a56561a");
MapViewManager.getInstance().registerMapViewCreatedCallback((mapview?: MapView, mapViewName?: string) => {
  if (!mapview) {
    return;
  }
  let mapView = mapview;
  mapView.onCreate();
  mapView.getMapAsync((map) => {
    map.setMapType(MapType.MAP_TYPE_SATELLITE)  //设置地图类型为卫星图
    let aMap: AMap = map;
    local(aMap)
    // createPoint(aMap)
    // createLine(aMap)
    createArea(aMap)
    registerEvent(aMap)
  })
})

/**
 * 定位
 * @param aMap
 */
function local(aMap: AMap) {
  aMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(23.179043, 113.422301), 13)); //设置地图中心点以及缩放级别
  let locationStyle: MyLocationStyle = new MyLocationStyle(); //定位样式构造函数
  //设置我的位置展示模式
  locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW); //定位、且将视角移动到地图中心点，定位点跟随设备移动
  aMap.setMyLocationStyle(locationStyle); //设置定位图层的样式
  //定义了一个定位源，为地图提供定位数据
  let locationSource: LocationSource = {
    activate(listener: OnLocationChangedListener): void {
      let location: geoLocationManager.Location = {
        accuracy: 1000,
        altitude: 0,
        direction: 0,
        latitude: 23.179043,
        longitude: 113.422301,
        speed: 0,
        timeSinceBoot: 123587419434256,
        timeStamp: 0,
        altitudeAccuracy: 0,
        speedAccuracy: 0,
        directionAccuracy: 0,
        uncertaintyOfTimeSinceBoot: 0,
        sourceType: 1
      }
      try {
        listener.onLocationChanged(location);
      } catch (e) {
        console.info((e as BusinessError).message);
      }
    },
    deactivate() {
    }
  };

  aMap?.setLocationSource(locationSource); //设置定位源

  aMap?.setMyLocationEnabled(true); //打开定位图层
}

/**
 * 创建点Marker
 * @param aMap
 */
async function createPoint(aMap: AMap) {
  // 默认
  // let options: MarkerOptions = new MarkerOptions();
  // options.setPosition(new LatLng(23.179043, 113.422301));
  // let marker = aMap.addMarker(options);
  // 自定义
  let options: MarkerOptions = new MarkerOptions();

  let bitmapDes = await BitmapDescriptorFactory.fromRawfilePath(globalContext, "img/button_pressed.png");
  if (bitmapDes) {
    options.setIcon(bitmapDes);
  }
  options.setTitle('标记'); //设置标记的标题
  options.setSnippet('详细信息') //设置标记的文字描述
  options.setPosition(new LatLng(23.179043, 113.422301));
  let marker = aMap.addMarker(options);

  // 点击事件
  aMap.setOnMarkerClickListener((marker: Marker): boolean => {
    // marker 被点击的 marker 对象
    // 返回true表示已处理点击事件，不再继续传递；返回false则继续传递
    console.log(marker.getId());
    return true
  })

  // 拖拽事件
  //当 marker 开始被拖动时回调此方法, 这个 marker 的位置可以通过 getPosition() 方法返回。
  // 这个位置可能与拖动的之前的 marker 位置不一样。
  // marker 被拖动的 marker 对象。
  const onMarkerDragStart = (marker: Marker): void => {
    // 处理拖动开始
    // marker 被拖动的 marker 对象
    // marker 的位置可以通过 getPosition() 方法返回
  }
  const onMarkerDrag = (marker: Marker): void => {
    // 处理拖动中
    // marker 被拖动的 marker 对象
    // marker 的位置可以通过 getPosition() 方法返回
  }
  const onMarkerDragEnd = (marker: Marker): void => {
    // 处理拖动结束
    // marker 被拖动的 marker 对象
    // marker 的位置可以通过 getPosition() 方法返回
  }

  // marker 拖动事件监听接口实例
  const dragListener: OnMarkerDragListener = new OnMarkerDragListener(onMarkerDragStart, onMarkerDrag, onMarkerDragEnd);

  //给 aMap 设置标记拖动监听器
  aMap.setOnMarkerDragListener(dragListener)

  // 移除Marker
  setTimeout(() => {
    if (marker?.getId()) aMap.removeOverlay(marker.getId());
  }, 5000)
}

/**
 * 创建线Marker
 * @param aMap
 */
function createLine(aMap: AMap) {
  let options: PolylineOptions = new PolylineOptions();
  // options.add(new LatLng(23.15450657839196, 113.39688777923608)); //追加一个点到线段的坐标集合
  // options.add(new LatLng(23.15252377807959, 113.4190106391909));
  // options.add(new LatLng(23.148686334927792, 113.43744277954127));

  let polylineOptionsList :ArrayList<LatLng> = new ArrayList<LatLng>()
  polylineOptionsList.add(new LatLng(23.15450657839196, 113.39688777923608))
  polylineOptionsList.add(new LatLng(23.15252377807959, 113.4190106391909))
  polylineOptionsList.add(new LatLng(23.148686334927792, 113.43744277954127))
  options.addAll(polylineOptionsList)

  aMap.addPolyline(options.setColor(0xFF008610).setWidth(20));
}

/**
 * 创建线Marker
 * @param aMap
 */
function createArea(aMap: AMap) {
  // 绘制圆
  let circleOptions: CircleOptions = new CircleOptions();
  circleOptions.setRadius(1500); //设置圆的半径，单位:米
  circleOptions.setCenter(new LatLng(23.15450657839196, 113.39688777923608)); //设置圆心经纬度坐标
  circleOptions.setFillColor(0xffff0000); //设置圆的填充颜色
  circleOptions.setStrokeColor(0xff00ff00); //设置圆的边框颜色

  let circleHoleOptions: CircleHoleOptions = new CircleHoleOptions();
  circleHoleOptions.setRadius(500);
  circleHoleOptions.setCenter(new LatLng(23.15450657839196, 113.39688777923608));
  circleOptions.addHoles(circleHoleOptions); //添加空心洞的配置项
  aMap.addCircle(circleOptions)

  // 绘制多边形
  let polygonOptions: PolygonOptions = new PolygonOptions();
  polygonOptions.add(new LatLng(23.156282195556834, 113.43950271606471));
  polygonOptions.add(new LatLng(23.156864198284044, 113.46514463424707));
  polygonOptions.add(new LatLng(23.133799172453944, 113.46338510513328));
  polygonOptions.add(new LatLng(23.130415047434717, 113.43868732452417));
  polygonOptions.setFillColor(0xFFFF0000);

  let polygonHoleOptions: PolygonHoleOptions = new PolygonHoleOptions;
  polygonHoleOptions.add(new LatLng(23.156282195556834 - 0.02, 113.43950271606471 + 0.02));
  polygonHoleOptions.add(new LatLng(23.156864198284044 - 0.02, 113.46514463424707 - 0.02));
  polygonHoleOptions.add(new LatLng(23.133799172453944 + 0.02, 113.46338510513328 - 0.02));
  polygonHoleOptions.add(new LatLng(23.130415047434717 + 0.02, 113.43868732452417 + 0.02));
  let list: ArrayList<PolygonHoleOptions> = new ArrayList();
  list.add(polygonHoleOptions);
  polygonOptions.setHoleOptions(list);
  aMap.addPolygon(polygonOptions);
}

/**
 * 注册事件
 * @param aMap
 */
function registerEvent(aMap: AMap) {
  aMap.setOnMapClickListener((latLng: LatLng) => {
    // latLng 是点击位置的经纬度
    console.log('地图被点击，位置：', latLng.latitude, latLng.longitude);
  })
}

@Entry
@Component
struct AMapPage {

  aboutToAppear() {

  }


  build() {
    Row() {
      MapViewComponent()
        .width('100%')
        .height('100%')
    }
  }
}