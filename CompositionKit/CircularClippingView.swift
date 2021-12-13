
import UIKit
import MondrianLayout

open class CircularClippingView<Body: UIView>: WrapperView<Body> {
  
  public override init(_ wrappedView: Body) {
    super.init(wrappedView)
    mondrian.layout
      .width(.to(self).height)
      .activate()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    layer.masksToBounds = true
    layer.cornerRadius = bounds.width / 2
  }
}
