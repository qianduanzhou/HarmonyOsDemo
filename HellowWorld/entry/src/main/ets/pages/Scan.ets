@Component
export default struct Scan {
  build() {
    NavDestination() {
      Column() {
        Text('Scan')
      }
    }.mode(NavDestinationMode.STANDARD)
    .hideTitleBar(true)
  }
}