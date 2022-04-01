import Descriptors
import UIKit

open class GradientLayerView : UIView {
  
  open override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }
  
  open override var layer: CAGradientLayer {
    super.layer as! CAGradientLayer
  }
  
  open func set(descriptor: LinearGradientDescriptor) {
    descriptor.apply(to: layer)
  }
}
