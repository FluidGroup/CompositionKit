import MondrianLayout
import UIKit
import Descriptors

/**

 It uses UIView as superclass to behave like UICollectionViewCell in UIScrollView.
 UIControl cancels scroll tracking when touch-up-insde detected.
 */
public final class InteractiveView<ContentView: UIView>: UIView {

  public struct Handlers {
    public var onTap: () -> Void = {}
    public var onLongPress: (CGPoint) -> Void = { _ in }
  }

  public let contentView: ContentView

  public var handlers = Handlers()

  public let overlayView: UIView?

  private let animationTargetViw: UIView

  private let animation: HighlightAnimationDescriptor
  private let haptics: HapticsDescriptor?

  public var longPressGestureRecognizer: UILongPressGestureRecognizer?
  private let useLongPressGesture: Bool
  private let animationHandler: HighlightAnimationDescriptor.Context.Handler?

  public init(
    animation: HighlightAnimationDescriptor,
    haptics: HapticsDescriptor? = nil,
    useLongPressGesture: Bool = false,
    contentView: ContentView
  ) {

    self.haptics = haptics
    self.animation = animation
    let context = animation.prepare()
    self.overlayView = context.overlay
    self.animationHandler = context.handler
    self.animationTargetViw = contentView
    self.contentView = contentView
    self.useLongPressGesture = useLongPressGesture

    super.init(frame: .zero)

    addSubview(contentView)

    contentView.mondrian.layout.edges(.toSuperview).activate()
    contentView.isUserInteractionEnabled = false

    accessibilityTraits = .button

    if let overlayView = overlayView {
      
      Mondrian.buildSubviews(on: self) {
        ZStackBlock {
          animationTargetViw
            .viewBlock
            .overlay(overlayView)
        }
      }
      
    } else {

      Mondrian.buildSubviews(on: self) {
        ZStackBlock {
          animationTargetViw
            .viewBlock
        }
      }
    }

    if useLongPressGesture {
      let longPressGesture = UILongPressGestureRecognizer(
        target: self,
        action: #selector(_onLongPress(_:))
      )
      addGestureRecognizer(longPressGesture)
      longPressGestureRecognizer = longPressGesture
    }

  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    super.touchesBegan(touches, with: event)

    animationHandler?(true, self, animationTargetViw)
    haptics?.send(event: .onTouchDownInside)
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    super.touchesEnded(touches, with: event)

    animationHandler?(false, self, animationTargetViw)

    guard !shouldCancelTouches(touches) else {
      return
    }

    haptics?.send(event: .onTouchUpInside)
    handlers.onTap()
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    super.touchesMoved(touches, with: event)

    if shouldCancelTouches(touches) {
      animationHandler?(false, self, animationTargetViw)
    } else {
      animationHandler?(true, self, animationTargetViw)
    }
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    animationHandler?(false, self, animationTargetViw)
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func _onLongPress(_ gesture: UILongPressGestureRecognizer) {
    guard case .began = gesture.state else { return }
    let point = gesture.location(in: gesture.view)

    haptics?.send(event: .onLongPress)
    handlers.onLongPress(point)
  }

  private func shouldCancelTouches(_ touches: Set<UITouch>) -> Bool {
    guard
      let touch = touches.first,
      bounds.insetBy(dx: -50, dy: -50).contains(touch.location(in: self)) else {
      return true
    }
    return false
  }

}

public final class HighlightView<ContentView: UIView>: UIView {
  
  public var isHighlighted: Bool = false {
    didSet {
      guard oldValue != isHighlighted else { return }
      
      if isHighlighted {
        animationHandler?(true, self, animationTargetViw)
        haptics?.send(event: .onTouchDownInside)
      }  else {
        animationHandler?(false, self, animationTargetViw)
        haptics?.send(event: .onTouchUpInside)
      }
    }
  }
   
  public let contentView: ContentView
    
  public let overlayView: UIView?
  
  private let animationTargetViw: UIView
  
  private let animation: HighlightAnimationDescriptor
  private let haptics: HapticsDescriptor?
  
  private let animationHandler: HighlightAnimationDescriptor.Context.Handler?
  
  public init(
    animation: HighlightAnimationDescriptor,
    haptics: HapticsDescriptor? = nil,
    contentView: ContentView
  ) {
    
    self.haptics = haptics
    self.animation = animation
    let context = animation.prepare()
    self.overlayView = context.overlay
    self.animationHandler = context.handler
    self.animationTargetViw = contentView
    self.contentView = contentView
    
    super.init(frame: .zero)
    
    addSubview(contentView)
    
    contentView.mondrian.layout.edges(.toSuperview).activate()
    contentView.isUserInteractionEnabled = false
    
    accessibilityTraits = .button
    
    if let overlayView = overlayView {
      
      Mondrian.buildSubviews(on: self) {
        ZStackBlock {
          animationTargetViw
            .viewBlock
            .overlay(overlayView)
        }
      }
      
    } else {
      
      Mondrian.buildSubviews(on: self) {
        ZStackBlock {
          animationTargetViw
            .viewBlock
        }
      }
    }
          
  }
  
  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func dynamicContentListContainerCell(didChangeHighlighted isHighlighted: Bool) {
    self.isHighlighted = isHighlighted
  }
}
