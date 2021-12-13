
import UIKit

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
