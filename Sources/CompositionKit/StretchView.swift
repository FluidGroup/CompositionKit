import UIKit

open class StretchView: CodeBasedView {

  public let contentView: UIView

  public var originalSize: CGSize {
    didSet {
      setNeedsDisplay()
    }
  }
  
  private var observation: NSKeyValueObservation?

  public init(contentView: UIView) {
    self.contentView = contentView
    self.originalSize = contentView.bounds.size
    super.init(frame: .null)
    
    clipsToBounds = true

    addSubview(contentView)
    
    observation = contentView.observe(\.bounds) { [weak self] contentView, _ in
      guard let self = self else { return }
      self.invalidateIntrinsicContentSize()
      self.originalSize = contentView.bounds.size
    }
  }
  
  deinit {
    observation?.invalidate()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    
    guard
      bounds.size.width > 0,
      bounds.size.height > 0,
      originalSize.width > 0,
      originalSize.height > 0
    else {
      return
    }
            
    let transform = CGAffineTransform(
      scaleX: bounds.size.width / originalSize.width,
      y: bounds.size.height / originalSize.height
    )

    contentView.transform = transform
    contentView.frame.origin = .zero
  }

  open override var intrinsicContentSize: CGSize {
    contentView.bounds.size
  }

  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    contentView.sizeThatFits(size)
  }

}
