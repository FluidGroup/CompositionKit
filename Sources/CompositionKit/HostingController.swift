import SwiftUI

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {
  
  private var _intrinsicContentSize: CGSize?
  
  var onInvalidated: () -> Void = {}

  override func viewDidLoad() {
    super.viewDidLoad()            
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    do {
      if _intrinsicContentSize != view.intrinsicContentSize {
        defer {
          _intrinsicContentSize = view.intrinsicContentSize
        }
        view.invalidateIntrinsicContentSize()
        onInvalidated()
      }
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
}
