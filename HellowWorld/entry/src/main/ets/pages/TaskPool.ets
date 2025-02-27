import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

// taskpool测试 ↓↓↓↓↓↓↓↓↓↓
@Concurrent
function add(num1: number, num2: number): number {
  return num1 + num2;
}

async function ConcurrentFunc(): Promise<void> {
  try {
    let task: taskpool.Task = new taskpool.Task(add, 1, 2);
    console.info("taskpool res is：" + await taskpool.execute(task));
  } catch (e) {
    console.error("taskpool execute error is：" + e);
  }
}
// taskpool测试 ↑↑↑↑↑↑↑↑↑

// promise测试 ↓↓↓↓↓↓↓↓↓↓
@Concurrent
function testPromise1(args1: number, args2: number): Promise<number> {
  return new Promise<number>((testFuncA, testFuncB)=>{
    testFuncA(args1 + args2);
  });
}

@Concurrent
async function testPromise2(args1: number, args2: number): Promise<number> {
  return new Promise<number>((testFuncA, testFuncB)=>{
    testFuncA(args1 + args2);
  });
}

@Concurrent
async function testPromise3(args1: number, args2: number): Promise<number> {
  return await new Promise<number>((testFuncA, testFuncB)=>{
    testFuncA(args1 + args2);
  });
}

@Concurrent
function testPromise4() {
  return Promise.resolve(1);
}

@Concurrent
async function testPromise5(): Promise<number> {
  return 1;
}

@Concurrent
async function testPromise6(): Promise<string> {
  return await new Promise((resolve) => {
    setTimeout(()=>{
      resolve("Promise setTimeout after resolve");
    }, 1000)
  });
}

async function testConcurrentFunc() {
  let task1: taskpool.Task = new taskpool.Task(testPromise1, 1, 2);
  let task2: taskpool.Task = new taskpool.Task(testPromise2, 1, 2);
  let task3: taskpool.Task = new taskpool.Task(testPromise3, 1, 2);
  let task4: taskpool.Task = new taskpool.Task(testPromise4);
  let task5: taskpool.Task = new taskpool.Task(testPromise5);
  let task6: taskpool.Task = new taskpool.Task(testPromise6);

  taskpool.execute(task1).then((d:object)=>{
    console.info("task1 res is: " + d);
  }).catch((e:object)=>{
    console.info("task1 catch e: " + e);
  })
  taskpool.execute(task2).then((d:object)=>{
    console.info("task2 res is: " + d);
  }).catch((e:object)=>{
    console.info("task2 catch e: " + e);
  })
  taskpool.execute(task3).then((d:object)=>{
    console.info("task3 res is: " + d);
  }).catch((e:object)=>{
    console.info("task3 catch e: " + e);
  })
  taskpool.execute(task4).then((d:object)=>{
    console.info("task4 res is: " + d);
  }).catch((e:object)=>{
    console.info("task4 catch e: " + e);
  })
  taskpool.execute(task5).then((d:object)=>{
    console.info("task5 res is: " + d);
  }).catch((e:object)=>{
    console.info("task5 catch e: " + e);
  })
  taskpool.execute(task6).then((d:object)=>{
    console.info("task6 res is: " + d);
  }).catch((e:object)=>{
    console.info("task6 catch e: " + e);
  })
}
// promise测试 ↑↑↑↑↑↑↑↑↑

// 普通对象通信 ↓↓↓↓↓↓↓↓↓
class ClassA {
  name: string = 'ClassA'
  constructor(name: string) {
    this.name = name;
  }
}
@Concurrent
async function testClass(arg: ClassA) {
  console.info("ClassA name is: " + arg.name);
}
async function testClassConcurrentFunc() {
  // 1. 创建Test实例objA
  let objA = new ClassA("TestA");
  // 2. 创建任务task，将objA传递给该任务，objA非sendable对象，通过序列化传递给子线程
  let task = new taskpool.Task(testClass, objA);
  // 3. 执行任务
  taskpool.execute(task).then(() => {
    console.info("taskpool: execute task success!");
  }).catch((e: BusinessError) => {
    console.error(`taskpool: execute task: Code: ${e.code}, message: ${e.message}`);
  })
}
// 普通对象通信 ↑↑↑↑↑↑↑↑↑

// ArrayBuffer对象通信 ↓↓↓↓↓↓↓↓↓
@Concurrent
function adjustImageValue(arrayBuffer: ArrayBuffer): ArrayBuffer {
  // 对arrayBuffer进行操作
  return arrayBuffer;  // 返回值默认转移
}

function createImageTask(arrayBuffer: ArrayBuffer, isParamsByTransfer: boolean): taskpool.Task {
  let task: taskpool.Task = new taskpool.Task(adjustImageValue, arrayBuffer);
  if (!isParamsByTransfer) { // 是否使用转移方式
    // 传递空数组[]，全部arrayBuffer参数传递均采用拷贝方式
    task.setTransferList([]);
  }
  return task;
}

async function testArrayBufferConcurrentFunc() {
  let taskNum = 4;
  let arrayBuffer = new ArrayBuffer(1024 * 1024);
  let taskPoolGroup = new taskpool.TaskGroup();
  // 创建taskNum个Task
  for (let i: number = 0; i < taskNum; i++) {
    let arrayBufferSlice: ArrayBuffer = arrayBuffer.slice(arrayBuffer.byteLength / taskNum * i, arrayBuffer.byteLength / taskNum * (i + 1));
    // 使用拷贝方式传入ArrayBuffer，所以isParamsByTransfer为false
    taskPoolGroup.addTask(createImageTask(arrayBufferSlice, false));
  }
  // 执行Task
  taskpool.execute(taskPoolGroup).then((data) => {
    // 返回结果，对数组拼接，获得最终结果
    console.log("data", data)
  }).catch((e: BusinessError) => {
    console.error(e.message);
  })
}
// ArrayBuffer对象通信 ↑↑↑↑↑↑↑↑↑

// SharedArrayBuffer对象通信 ↓↓↓↓↓↓↓↓↓
@Concurrent
function transferAtomics(arg1: Int32Array) {
  console.info("wait begin::");
  // 使用Atomics进行操作
  let res = Atomics.wait(arg1, 0, 0, 3000);
  return res;
}

async function testSharedArrayBufferConcurrentFunc() {
  // 定义可共享对象
  let sab: SharedArrayBuffer = new SharedArrayBuffer(20);
  let int32 = new Int32Array(sab);
  let task: taskpool.Task = new taskpool.Task(transferAtomics, int32);
  taskpool.execute(task).then((res) => {
    console.info("this res is: " + res);
  });
  setTimeout(() => {
    Atomics.notify(int32, 0, 1);
  }, 1000);
}
// SharedArrayBuffer对象通信 ↑↑↑↑↑↑↑↑↑

// Transferable对象（NativeBinding对象）通信 ↓↓↓↓↓↓↓↓↓
let pixelMap: PixelMap | undefined = undefined;
@Concurrent
async function loadPixelMap(rawFileDescriptor: number): Promise<PixelMap> {
  // 创建imageSource。
  const imageSource = image.createImageSource(rawFileDescriptor);
  // 创建pixelMap。
  const pixelMap = imageSource.createPixelMapSync();
  // 释放imageSource。
  imageSource.release();
  // 使pixelMap在跨线程传输完成后，断开原线程的引用。
  pixelMap.setTransferDetached(true);
  // 返回pixelMap给主线程。
  return pixelMap;
}
// Transferable对象（NativeBinding对象）通信 ↑↑↑↑↑↑↑↑↑

@Component
@Entry
struct TaskPool {
  @State pixelMap: PixelMap | undefined = undefined;

  // Transferable对象（NativeBinding对象）通信
  private loadImageFromThread(): void {
    const resourceMgr = getContext(this).resourceManager;
    // 此处‘startIcon.png’为media下复制到rawfile文件夹中，请开发者自行替换，否则imageSource创建失败会导致后续无法正常执行。
    resourceMgr.getRawFd('img/button_pressed.png').then(rawFileDescriptor => {
      taskpool.execute(loadPixelMap, rawFileDescriptor).then(pixelMap => {
        if (pixelMap) {
          this.pixelMap = pixelMap as PixelMap;
          console.log('Succeeded in creating pixelMap.');
          // 主线程释放pixelMap。由于子线程返回pixelMap时已调用setTransferDetached，所以此处能够立即释放pixelMap。
          this.pixelMap.release();
        } else {
          console.error('Failed to create pixelMap.');
        }
      }).catch((e: BusinessError) => {
        console.error('taskpool execute loadPixelMap failed. Code: ' + e.code + ', message: ' + e.message);
      });
    });
  }

  build() {
    Column() {
      Row() {
        Button("执行相加").fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          ConcurrentFunc();
        })
      }.margin({
        bottom: 10
      })
      Row() {
        Button("执行Promise").fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          testConcurrentFunc();
        })
      }.margin({
        bottom: 10
      })
      Row() {
        Button("执行普通对象通信").fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          testClassConcurrentFunc();
        })
      }.margin({
        bottom: 10
      })
      Row() {
        Button("执行ArrayBuffer对象通信").fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          testArrayBufferConcurrentFunc();
        })
      }.margin({
        bottom: 10
      })
      Row() {
        Button("执行SharedArrayBuffer对象通信").fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          testSharedArrayBufferConcurrentFunc();
        })
      }.margin({
        bottom: 10
      })
      Row() {
        Button("执行Transferable对象通信").fontSize(16).fontWeight(FontWeight.Bold).onClick(() => {
          this.loadImageFromThread();
        })
      }.margin({
        bottom: 10
      })
    }.width('100%')
    .height('100%').justifyContent(FlexAlign.Center)
  }
}