import { FrameNode, NodeController, Size, BuilderNode,  UIContext } from '@kit.ArkUI'
class Params {
  text: string = "this is a text"
}

let buttonNode: BuilderNode<[Params]> | null = null;

@Builder
function buttonBuilder(params: Params) {
  Column() {
    Button(params.text)
      .fontSize(12)
      .borderRadius(8)
      .borderWidth(2)
      .backgroundColor(Color.Orange)
  }
}

function createNode(uiContext: UIContext) {
  buttonNode = new BuilderNode<[Params]>(uiContext);
  buttonNode.build(wrapBuilder(buttonBuilder), { text: "This is a Button" });
  return buttonNode;
}

function getOrCreateNode(uiContext: UIContext): BuilderNode<[Params]> | null {
  if (buttonNode?.getFrameNode() && buttonNode?.getFrameNode()?.getUniqueId() != -1) {
    return buttonNode;
  } else {
    return createNode(uiContext);
  }
}

class MyNodeController extends NodeController {
  private isShow: boolean = false;

  constructor(isShow: boolean) {
    super();
    this.isShow = isShow;
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (!this.isShow) {
      return null;
    }
    let frameNode = getOrCreateNode(uiContext)?.getFrameNode();
    return frameNode ? frameNode : null;
  }

  aboutToResize(size: Size) {
    console.log("aboutToResize width : " + size.width + " height : " + size.height)
  }

  aboutToAppear() {
    console.log("aboutToAppear")
  }

  aboutToDisappear() {
    console.log("aboutToDisappear");
  }

  onTouchEvent(event: TouchEvent) {
    console.log("onTouchEvent");
  }

  toShow() {
    this.isShow = true;
    this.rebuild();
  }

  toHide() {
    this.isShow = false;
    this.rebuild();
  }
}

@Entry
@Component
struct NodeContainerPage {
  private myNodeController1: MyNodeController = new MyNodeController(true);
  private myNodeController2: MyNodeController = new MyNodeController(false);

  build() {
    Column() {
      NodeContainer(this.myNodeController1)
        .width("100%")
        .height("40%")
        .backgroundColor(Color.Brown)
      NodeContainer(this.myNodeController2)
        .width("100%")
        .height("40%")
        .backgroundColor(Color.Gray)
      Button("Change the place of button")
        .onClick(() => {
          // 先在原始占位节点中下树
          // 后在新的占位节点中上树
          // 保证自定义节点仅作为一个节点的子节点存在
          this.myNodeController1.toHide();
          this.myNodeController2.toShow();
        })
    }
    .padding({ left: 35, right: 35, top: 35 })
    .width("100%")
    .height("100%")
  }
}