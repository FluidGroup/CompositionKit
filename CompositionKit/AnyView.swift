import UIKit
import MondrianLayout

open class AnyView: UIView {

  private var _onDeinit: (() -> Void)?

  public init(@EntrypointBuilder build: (AnyView) -> [EntrypointBuilder.Either]) {

    super.init(frame: .null)

    let _b: () -> [EntrypointBuilder.Either] = {
      build(self)
    }

    Mondrian.buildSubviews(on: self, _b)

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
