import { AbilityStage, Want, AbilityConstant } from '@kit.AbilityKit';

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    // 应用的HAP在首次加载的时，为该Module初始化操作
    console.log('AbilityStage onCreate')
  }

  onAcceptWant(want: Want): string {
    // 仅specified模式下触发
    return 'MyAbilityStage';
  }

  onMemoryLevel(level: AbilityConstant.MemoryLevel): void {
    // 根据系统可用内存的变化情况，释放不必要的内存
  }
}