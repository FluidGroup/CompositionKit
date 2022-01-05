import UIKit

public final class MaskingView: UIView {

  private let _maskView: UIView

  public init(
    debug: Bool = false,
    maskedContent: UIView,
    mask: UIView
  ) {
    self._maskView = mask

    super.init(frame: .zero)

    addSubview(maskedContent)
    maskedContent.mondrian.layout.edges(.toSuperview).activate()

#if DEBUG
    if debug {
      layer.addSublayer(mask.layer)
    } else {
      layer.mask = mask.layer
    }
#else
    layer.mask = mask.layer
#endif
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {

    super.layoutSubviews()

    CATransaction.begin()
    CATransaction.setDisableActions(true)

    _maskView.frame = bounds

    CATransaction.commit()

  }

}


