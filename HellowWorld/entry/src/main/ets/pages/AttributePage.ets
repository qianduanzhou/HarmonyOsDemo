import { AttributeUpdater } from '@ohos.arkui.modifier'

class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  // 可以实现一个Modifier，定义私有的成员变量，外部可动态修改
  isDark: boolean = false

  // 通过构造函数，创建时传参
  constructor(dark?: boolean) {
    this.isDark = dark ? dark : false
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    // instance为Button的属性对象，可以通过instance对象对属性进行修改
    if (this.isDark) { // 支持业务逻辑的编写
      // 属性变化触发apply函数时，变化前已设置并且变化后未设置的属性会恢复为默认值
      instance.backgroundColor(Color.Black)
    } else {
      // 支持属性的链式调用
      instance.backgroundColor(Color.Red)
        .borderColor(Color.Black)
        .borderWidth(2)
    }
  }
}

class MyButtonModifier2 extends AttributeUpdater<ButtonAttribute> {
  initializeModifier(instance: ButtonAttribute): void {
    instance.backgroundColor('#2787D9')
      .width('50%')
      .height(30)
  }
}

class MyTextModifier extends AttributeUpdater<TextAttribute, TextInterface> {
  initializeModifier(instance: TextAttribute): void {
  }
}

@Entry
@Component
struct AttributePage {
  // 支持用状态装饰器修饰，行为和普通的对象一致
  @State modifier: MyButtonModifier = new MyButtonModifier(true);
  @State modifier2: MyButtonModifier2 = new MyButtonModifier2();
  @State modifier3: MyTextModifier = new MyTextModifier();

  build() {
    Column() {
      Row() {
        Button("Button")
          .attributeModifier(this.modifier)
          .onClick(() => {
            // 对象的一层属性被修改时，会触发UI刷新，重新执行applyNormalAttribute
            this.modifier.isDark = !this.modifier.isDark
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        bottom: 20
      })
      Row() {
        Button("Button")
          .attributeModifier(this.modifier2)
          .onClick(() => {
            this.modifier2.attribute?.backgroundColor('#17A98D').width('30%')
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        bottom: 20
      })
      Row() {
        Text("Text")
          .attributeModifier(this.modifier3)
          .fontColor(Color.White)
          .fontSize(14)
          .border({ width: 1 })
          .textAlign(TextAlign.Center)
          .lineHeight(20)
          .width(200)
          .height(50)
          .backgroundColor('#2787D9')
          .onClick(() => {
            this.modifier3.updateConstructorParams('Update');
          })
        .width('100%')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}