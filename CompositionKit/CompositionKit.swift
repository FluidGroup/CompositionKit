
import UIKit
import MondrianLayout

public final class ScrollableContainerView: UIScrollView {

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

public final class InteractiveView: UIControl {

  public var onTap: () -> Void = {}

  public init(content: UIView) {

    super.init(frame: .zero)

    addSubview(content)

    content.mondrian.layout.edges(.toSuperview).activate()
    content.isUserInteractionEnabled = false

    self.addTarget(self, action: #selector(_onTap), for: .touchUpInside)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func _onTap() {
    onTap()
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
