import UIKit
import MondrianLayout

@available(*, deprecated, renamed: "AnyUIView", message: "To avoid confliting with SwiftUI.AnyView")
public typealias AnyView = AnyUIView

open class AnyUIView: UIView {

  private var _onDeinit: (() -> Void)?

  public init(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    @EntrypointBuilder build: (AnyUIView) -> [EntrypointBuilder.Either]
  ) {

    super.init(frame: .null)

#if DEBUG
    let file = URL(string: file.description)?.deletingPathExtension().lastPathComponent ?? "unknown"
    self.accessibilityIdentifier = [
      name,
      file,
      function.description,
      line.description
    ]
      .joined(separator: ".")
#endif
    
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
