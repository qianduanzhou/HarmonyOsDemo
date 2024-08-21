@AnimatableExtend(Text)
function animatableWidth(width: number) {
  .width(width)
}

@Entry
@Component
struct Animatable {
  @State textWidth: number = 80;
  build() {
    Column() {
      Text("AnimatableProperty")
        .animatableWidth(this.textWidth)
        .animation({ duration: 2000, curve: Curve.Ease })
      Button("Play")
        .onClick(() => {
          this.textWidth = this.textWidth == 80 ? 160 : 80;
        })
    }.width("100%")
    .padding(10)
  }
}