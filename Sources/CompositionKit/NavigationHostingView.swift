import UIKit

import MondrianLayout

/**
 A view based navigation bar.
 You may add contents in `contentView`.
 */
open class NavigationHostingView : UIView {

  // MARK: - Properties

  /**
   a view that hosts the content.

   - Warning: DO NOT work with this directly.
   */
  public final let contentView = UIView()

  public var preferredHeight: CGFloat {
    get {
      return contentViewHeight.constant
    }
    set {
      contentViewHeight.constant = newValue
    }
  }

  public var isAttachedToTop: Bool = true {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  /// a view that attaches to the top of the display.
  private let backDropView: UIView = .init()

  private var contentViewHeight: NSLayoutConstraint!

  open override var backgroundColor: UIColor? {
    get {
      return backDropView.backgroundColor
    }
    set {
      backDropView.backgroundColor = newValue
    }
  }

  public var isTouchThrough: Bool = false

  // MARK: - Initializers

  public convenience init() {
    self.init(frame: .zero)
  }

  public override init(frame: CGRect) {

    super.init(frame: frame)

    /// Needs to visible backdrop-view
    clipsToBounds = false

    backgroundColor = .clear

    addSubview(backDropView)
    addSubview(contentView)

    contentView.mondrian.layout
      .edges(.toSuperview)
      .activate()

    contentViewHeight = contentView.heightAnchor.constraint(equalToConstant: 44)
    contentViewHeight.isActive = true

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override var center: CGPoint {
    didSet {
      guard oldValue != center else { return }
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  // MARK: - Functions

  open override func layoutSubviews() {
    super.layoutSubviews()

    if isAttachedToTop {
      if let ownerView = superview {
        // Maybe it needs find view of ViewController

        let convertedFrame = self.convert(self.bounds, to: ownerView)

        var backdropFrame = convertedFrame
        backdropFrame.size.height += max(0, convertedFrame.origin.y)
        backdropFrame.origin.y = -max(0, convertedFrame.origin.y)
        backdropFrame.origin.x = 0

        backDropView.frame = backdropFrame
      }
    } else {
      backDropView.frame = contentView.frame
    }
  }

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

    let view = super.hitTest(point, with: event)

    if isTouchThrough {

      if view == self || view == backDropView || view == contentView {

        return nil
      }
      return view

    } else {

      return view
    }
  }

}

extension NavigationHostingView {

  /**
   Sets a content view with cleanup current content view.
   */
  public func setContent(_ content: UIView) {

    contentView.subviews.forEach {
      $0.removeFromSuperview()
    }

    contentView.addSubview(content)

    Mondrian.layout {
      content.mondrian.layout.edges(.toSuperview)
    }

  }

  /**
   Attaches this to view of the view controller with setting additional safe area insets.
   */
  public func setup(on viewController: UIViewController) {

    viewController.view.addSubview(self)
    viewController.additionalSafeAreaInsets.top = preferredHeight

    Mondrian.layout {
      mondrian.layout
        .horizontal(.toSuperview)
        .bottom(.to(viewController.view.safeAreaLayoutGuide).top)
    }

  }

}
