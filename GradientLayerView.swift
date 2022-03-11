import Descriptors

open class GradientLayerView : UIView {
  
  private let gradientLayer = CAGradientLayer()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    layer.addSublayer(gradientLayer)
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = bounds
  }
  
  open func set(descriptor: LinearGradientDescriptor) {
    descriptor.apply(to: gradientLayer)
  }
}
