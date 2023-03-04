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
    _ = _once_
    view._fixing_safeArea = true
    return self
  }

  override var prefersStatusBarHidden: Bool {
    return false
  }
  
}

private let _once_: Void = {
  UIView.replace()
}()

private var _key: Void?

extension UIView {

  fileprivate static func replace() {

    method_exchangeImplementations(
      class_getInstanceMethod(self, #selector(getter:UIView.safeAreaInsets))!,
      class_getInstanceMethod(self, #selector(getter:UIView._hosting_safeAreaInsets))!
    )

    method_exchangeImplementations(
      class_getInstanceMethod(self, #selector(getter:UIView.safeAreaLayoutGuide))!,
      class_getInstanceMethod(self, #selector(getter:UIView._hosting_safeAreaLayoutGuide))!
    )

  }

  fileprivate var _fixing_safeArea: Bool {
    get {
      (objc_getAssociatedObject(self, &_key) as? Bool) ?? false
    }
    set {
      objc_setAssociatedObject(self, &_key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }

  @objc dynamic var _hosting_safeAreaInsets: UIEdgeInsets {
    if _fixing_safeArea {
      return .zero
    } else {
      return self._hosting_safeAreaInsets
    }
  }

  @objc dynamic var _hosting_safeAreaLayoutGuide: UILayoutGuide? {
    if _fixing_safeArea {
      return nil
    } else {
     return self._hosting_safeAreaLayoutGuide
    }
  }

}

@available(iOS 13, *)
public struct FixedSafeArea<Content: View>: View {
  
  let content: Content
  
  public var body: some View {
    content
  }
}
