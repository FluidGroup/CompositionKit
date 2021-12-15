import UIKit
import MondrianLayout

open class AnyView: UIView {

  private var _onDeinit: (() -> Void)?

  public init(build: (AnyView) -> LayoutContainer) {
    super.init(frame: .zero)
    mondrian.buildSubviews {
      build(self)
    }
  }

  public init<Block: _LayoutBlockType>(build: (AnyView) -> Block) {
    super.init(frame: .zero)
    mondrian.buildSubviews {
      build(self)
    }
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    _onDeinit?()
  }

  @discardableResult
  public func setOnDeinit(_ closure: @escaping () -> Void) -> Self {
    _onDeinit = closure
    return self
  }

}