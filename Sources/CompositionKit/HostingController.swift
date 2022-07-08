import SwiftUI

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {
  
  var onViewDidLayoutSubviews: () -> Void = {}
    
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    onViewDidLayoutSubviews()
  }
  
}
