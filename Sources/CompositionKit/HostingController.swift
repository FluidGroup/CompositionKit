import SwiftUI

@_spi(Internal)
public protocol _HostingControllerType: UIViewController {
  var onViewDidLayoutSubviews: (UIViewController) -> Void { get set }
  func sizeThatFits(in size: CGSize) -> CGSize
}

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content>, _HostingControllerType {

  var onViewDidLayoutSubviews: (UIViewController) -> Void = { _ in }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    onViewDidLayoutSubviews(self)
  }
}

///
/// https://stackoverflow.com/a/62421114
/// https://twitter.com/b3ll/status/1193747288302075906
@available(iOS 13, *)
final class FixedSafeAreaHostingController<Content: View>: UIHostingController<FixedSafeArea<Content>>, _HostingControllerType {
  
  var onViewDidLayoutSubviews: (UIViewController) -> Void = { _ in }
  
  init(rootView: Content) {
    super.init(rootView: .init(content: rootView))
    
    fixApplied()
  }
  
  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    onViewDidLayoutSubviews(self)
  }
  
  @discardableResult
  private func fixApplied() -> Self {
    self.fixSafeAreaInsets()
    return self
  }
  
  private func fixSafeAreaInsets() {
    guard let _class = view?.classForCoder else {
      assertionFailure()
      return
    }
    
    let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = {
      (sself: AnyObject!) -> UIEdgeInsets in
      return .zero
    }
    
    guard let method = class_getInstanceMethod(_class.self, #selector(getter:UIView.safeAreaInsets))
    else {
      return
    }
    
    class_replaceMethod(
      _class,
      #selector(getter:UIView.safeAreaInsets),
      imp_implementationWithBlock(safeAreaInsets),
      method_getTypeEncoding(method)
    )
    
    let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = {
      (sself: AnyObject!) -> UILayoutGuide? in return nil
    }
    
    guard
      let method2 = class_getInstanceMethod(
        _class.self,
        #selector(getter:UIView.safeAreaLayoutGuide)
      )
    else {
      return
    }
    
    class_replaceMethod(
      _class,
      #selector(getter:UIView.safeAreaLayoutGuide),
      imp_implementationWithBlock(safeAreaLayoutGuide),
      method_getTypeEncoding(method2)
    )
    
  }
  
  override var prefersStatusBarHidden: Bool {
    return false
  }
  
}

@available(iOS 13, *)
public struct FixedSafeArea<Content: View>: View {
  
  let content: Content
  
  public var body: some View {
    content
  }
}
