
import UIKit
import MondrianLayout
import Descriptors

public class _ShapeLayerView: UIView {
  public override class var layerClass: AnyClass {
    return CAShapeLayer.self
  }

  public override var layer: CAShapeLayer {
    return super.layer as! CAShapeLayer
  }

  public override init(
    frame: CGRect
  ) {
    super.init(frame: frame)
    self.backgroundColor = .clear
    self.layer.contentsScale = UIScreen.main.scale
    self.layer.allowsEdgeAntialiasing = true
    self.layer.lineWidth = 0
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/// A node that displays shape with CAShapeLayer
public final class ShapeLayerView: _ShapeLayerView, ShapeDisplaying {

  public var shapeLineWidth: CGFloat {
    get {
      return layer.lineWidth
    }
    set {
      layer.lineWidth = newValue
    }
  }

  public var shapeStrokeColor: UIColor? {
    get {
      return layer.strokeColor.map { UIColor(cgColor: $0) }
    }
    set {
      layer.strokeColor = newValue?.cgColor
    }
  }

  public var shapeFillColor: UIColor? {
    get {
      return layer.fillColor.map { UIColor(cgColor: $0) }
    }
    set {
      layer.fillColor = newValue?.cgColor
    }
  }

  private let updateClosure: (CGRect) -> UIBezierPath

  public init(
    update: @escaping (CGRect) -> UIBezierPath
  ) {
    self.updateClosure = update
    super.init(frame: .zero)
  }

  public override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    self.layer.path = updateClosure(self.bounds).cgPath
    self.layer.setNeedsDisplay()
  }

}

extension ShapeLayerView {

  /// Returns an instance that displays rounded corner shape.
  /// Rounded corner uses smooth-curve
  ///
  /// - Parameter radius:
  /// - Returns:
  public static func roundedCorner(radius: CGFloat) -> ShapeLayerView {
    return ShapeLayerView { bounds in
      UIBezierPath.init(roundedRect: bounds, cornerRadius: radius)
    }
  }

}
