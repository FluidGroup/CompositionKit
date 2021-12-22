
import UIKit
import MondrianLayout

/// - Ref: https://texturegroup.org/docs/corner-rounding.html
public enum StyledEdgeCornerRoundingStrategy {
  /// High-performance
//  case clip(assimilationColor: UIColor)
  /// Low-performance
  /// It appears their background.
  case mask
}

public enum StyledEdgeCornerRounding {
  case circular
  case radius(CGFloat)
}

/**
 Ported from TextureSwiftSupport
 */
open class StyledEdgeView<Content: UIView>: WrapperView<Content> {

  private var circularConstrainGroups: ConstraintGroup?

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var cornerRadius: StyledEdgeCornerRounding {
    didSet {
      updateCornerRadius()
    }
  }

  private var cornerRoundingStrategy: StyledEdgeCornerRoundingStrategy {
    didSet {

    }
  }

  public init(
    cornerRadius: StyledEdgeCornerRounding,
    cornerRoundingStrategy: StyledEdgeCornerRoundingStrategy,
//    border: StyledEdgeBorderDescriptor? = nil,
    content: Content
  ) {

    self.cornerRadius = cornerRadius
    self.cornerRoundingStrategy = cornerRoundingStrategy

    super.init(content)

    updateCornerRadius()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    updateCornerRadius()
  }

  private func updateCornerRadius() {

    switch cornerRoundingStrategy {
    case .mask:

      switch cornerRadius {
      case .circular:

        if circularConstrainGroups == nil {
          circularConstrainGroups = Mondrian.layout {
            mondrian.layout
              .width(.to(self).height)
          }
        }

        layer.masksToBounds = true
        layer.cornerRadius = bounds.width / 2

      case .radius(let radius):

        circularConstrainGroups.map {
          $0.deactivate()
        }

        layer.masksToBounds = true
        layer.cornerRadius = radius

      }

    }
  }

}
