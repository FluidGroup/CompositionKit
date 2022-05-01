@_exported import Descriptors
import MondrianLayout
import UIKit

/// ScrollView based that wraps a content
public final class ScrollableContainerView: UIScrollView {

  public typealias ScrollDirection = UICollectionView.ScrollDirection

  public let scrollDirection: ScrollDirection

  public init(scrollDirection: ScrollDirection = .vertical) {
    self.scrollDirection = scrollDirection
    super.init(frame: .zero)
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

    switch scrollDirection {
    case .vertical:

      NSLayoutConstraint.activate([
        view.leftAnchor.constraint(equalTo: frameLayoutGuide.leftAnchor),
        view.rightAnchor.constraint(equalTo: frameLayoutGuide.rightAnchor),

        view.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor),
        view.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor),
        view.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
        view.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
      ])
    case .horizontal:
      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: frameLayoutGuide.topAnchor),
        view.bottomAnchor.constraint(equalTo: frameLayoutGuide.bottomAnchor),

        view.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor),
        view.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor),
        view.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
        view.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
      ])
    @unknown default:
      assertionFailure()
    }

  }

}

/// Composition
///
/// - Author: muukii
open class AnyWrapperView: UIView {

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
open class WrapperView<T: UIView>: UIView {

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
