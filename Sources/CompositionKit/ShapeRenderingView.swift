
import UIKit
import MondrianLayout
import Descriptors

public final class ShapeRenderingView: UIView, ShapeDisplaying {

  private let updateClosure: Update

  public var shapeFillColor: UIColor? = .black {
    didSet {
      setNeedsDisplay()
    }
  }

  public var shapePath: UIBezierPath? {
    didSet {
      setNeedsDisplay()
    }
  }

  public var shapeLineWidth: CGFloat = 0 {
    didSet {
      setNeedsDisplay()
    }
  }

  public var shapeStrokeColor: UIColor? {
    didSet {
      setNeedsDisplay()
    }
  }

  public init(
    update: @escaping Update
  ) {
    self.updateClosure = update
    super.init(frame: .zero)
    isOpaque = false
    backgroundColor = .clear
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    self.shapePath = updateClosure(self.bounds)
    self.layer.setNeedsDisplay()
  }

  public override func draw(_ rect: CGRect) {

    shapeFillColor?.setFill()
    shapePath?.fill()

  }
}
