@Component
export default struct Profile {
  build() {
    NavDestination() {
      Column() {
        Text('Profile')
      }
    }.mode(NavDestinationMode.STANDARD)
    .hideTitleBar(true)
  }
}