import { ErrorEvent, MessageEvents, worker } from '@kit.ArkTS'

@Component
@Entry
struct Worker {
  build() {
    Column() {
      Row() {
        Button('测试').fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          // 创建Worker对象
          let workerInstance = new worker.ThreadWorker('entry/ets/workers/worker.ets');

          // 注册onmessage回调，当宿主线程接收到来自其创建的Worker通过workerPort.postMessage接口发送的消息时被调用，在宿主线程执行
          workerInstance.onmessage = (e: MessageEvents) => {
            let data: string = e.data;
            console.info("workerInstance onmessage is: ", data);
          }

          // 注册onerror回调，当Worker在执行过程中发生异常时被调用，在宿主线程执行
          workerInstance.onerror = (err: ErrorEvent) => {
            console.info("workerInstance onerror message is: " + err.message);
          }

          // 注册onmessageerror回调，当Worker对象接收到一条无法被序列化的消息时被调用，在宿主线程执行
          workerInstance.onmessageerror = () => {
            console.info('workerInstance onmessageerror');
          }

          // 注册onexit回调，当Worker销毁时被调用，在宿主线程执行
          workerInstance.onexit = (e: number) => {
            // 当Worker正常退出时code为0，异常退出时code为1
            console.info("workerInstance onexit code is: ", e);
          }

          // 向Worker线程发送消息
          workerInstance.postMessage('1');
        })
      }
    }.width('100%')
    .height('100%').justifyContent(FlexAlign.Center)
  }
}