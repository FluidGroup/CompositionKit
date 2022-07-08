import SwiftUI

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {
  
  var onViewDidLayoutSubviews: (HostingController<Content>) -> Void = { _ in }
    
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    onViewDidLayoutSubviews(self)
  }
  
}
