import SwiftUI

/// Light-weight backported implementation from `UIHostingConfiguration`.
@available(iOS 13, *)
open class HostingCell: UICollectionViewCell {
  
  public struct State {

    public var isSelected: Bool
    public var isHighlighted: Bool
    
    public init(isSelected: Bool = false, isHighlighted: Bool = false) {
      self.isSelected = isSelected
      self.isHighlighted = isHighlighted
    }
  }
  
  private var hostingController: HostingController<RootView<State>>!
  
  private let proxy: Proxy<State> = .init(state: .init())
    
  open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    hostingController.view.invalidateIntrinsicContentSize()
    let proposed = super.preferredLayoutAttributesFitting(layoutAttributes)
    return proposed
  }
  
  public final override var isSelected: Bool {
    didSet {
      if proxy.state.isSelected != isSelected {
        proxy.state.isSelected = isSelected
      }
    }
  }

  public final override var isHighlighted: Bool {
    didSet {
      if proxy.state.isHighlighted != isHighlighted {
        proxy.state.isHighlighted = isHighlighted
      }
    }
  }

  public override init(frame: CGRect) {

    super.init(frame: frame)

    self.hostingController = HostingController(
      rootView: RootView(proxy: proxy)
    )
  
#if swift(>=5.7)
    if #available(iOS 16.0, *) {
      self.hostingController.sizingOptions = .intrinsicContentSize
    }
#endif
    
    contentView.addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      hostingController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
    ])

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView
  
  open override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    UIView.performWithoutAnimation {
      contentView.layoutIfNeeded()
    }
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
  }

  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    hostingController.sizeThatFits(in: size)
  }

  open override var intrinsicContentSize: CGSize {
    hostingController.view.intrinsicContentSize
  }

  open override func didMoveToWindow() {

    super.didMoveToWindow()

    // https://muukii.notion.site/Why-we-need-to-add-UIHostingController-to-view-controller-chain-14de20041c99499d803f5a877c9a1dd1

    if let _ = window {
      if let parentViewController = self.findNearestViewController() {
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
      } else {
        assertionFailure()
      }
    } else {
      hostingController.willMove(toParent: nil)
      hostingController.removeFromParent()
    }

  }
  
  public final func setContent<Content: SwiftUI.View>(
    @ViewBuilder content: @escaping (State) -> Content
  ) {
    
    proxy.content = { state in
      return SwiftUI.AnyView(content(state))
    }

  }

  public func invalidateSelfSizing() {
    
    guard let collectionView = (superview as? UICollectionView) else {
      return
    }
    
    hostingController.view.invalidateIntrinsicContentSize()

    let context = InvalidationContext(invalidateEverything: false)
    
    guard let indexPath = collectionView.indexPath(for: self) else {
      return
    }
    
    context.invalidateItems(at: [indexPath])

    collectionView.collectionViewLayout.invalidateLayout(with: context)
    collectionView.layoutIfNeeded()
   
  }
  
  open override func prepareForReuse() {
    super.prepareForReuse()
    
    proxy.state = .init(isSelected: false, isHighlighted: false)
    proxy.content = { _ in
      SwiftUI.AnyView(SwiftUI.EmptyView())
    }
    
  }

}

@available(iOS 13, *)
extension HostingCell {
  final class InvalidationContext: UICollectionViewLayoutInvalidationContext {
    override var invalidateEverything: Bool {
      return _invalidateEverything
    }
    
    private var _invalidateEverything: Bool
    
    init(invalidateEverything: Bool) {
      self._invalidateEverything = invalidateEverything
    }
  }
}
