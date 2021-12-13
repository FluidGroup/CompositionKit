
import UIKit
import MondrianLayout

public final class ScrollableContainerView: UIScrollView {

  public init() {
    super.init(frame: .zero)
    delaysContentTouches = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setContent(_ view: UIView) {

    subviews.forEach {
      $0.removeFromSuperview()
    }

    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      view.leftAnchor.constraint(equalTo: frameLayoutGuide.leftAnchor),
      view.rightAnchor.constraint(equalTo: frameLayoutGuide.rightAnchor),
      view.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor),
      view.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor),
      view.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
      view.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
    ])

  }

}

/// Composition
///
/// - Author: muukii
open class AnyWrapperView : UIView {

  public unowned let wrapped: UIView

  public init<T: UIView>(_ wrappedView: T) {
    self.wrapped = wrappedView
    super.init(frame: .zero)
    addSubview(wrappedView)
    wrappedView.mondrian.layout.edges(.toSuperview).activate()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/// Composition
///
/// - Author: muukii
open class WrapperView<T: UIView> : UIView {

  public unowned let wrapped: T

  public init(_ wrappedView: T) {
    self.wrapped = wrappedView
    super.init(frame: .zero)
    addSubview(wrappedView)
    wrappedView.mondrian.layout.edges(.toSuperview).activate()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
