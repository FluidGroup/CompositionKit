
import UIKit

public class PaddingView<Body: UIView>: UIView {
  
  public let body: Body
  
  ///
  ///
  /// - Parameters:
  ///   - padding: if you no needs padding, use .infinity.
  ///   - bodyView: Embedded view
  public init(padding: UIEdgeInsets, bodyView: Body) {
    
    self.body = bodyView
    
    super.init(frame: .zero)
    
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(bodyView)
    
    if padding.top.isFinite {
      bodyView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top).isActive = true
    } else {
      bodyView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
    }
    
    if padding.right.isFinite {
      bodyView.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding.right).isActive = true
    } else {
      bodyView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
    }
    
    if padding.left.isFinite {
      bodyView.leftAnchor.constraint(equalTo: leftAnchor, constant: padding.left).isActive = true
    } else {
      bodyView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
    }
    
    if padding.bottom.isFinite {
      bodyView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom).isActive = true
    } else {
      bodyView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
    }
    
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/// Composition
///
/// A container view with added padding
/// - Author: muukii
public final class AnyPaddingView: PaddingView<UIView> {
  

}
