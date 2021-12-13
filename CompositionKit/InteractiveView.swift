import MondrianLayout
import UIKit

public final class InteractiveView<ContentView: UIView>: UIControl {

  public struct Handlers {
    public var onTap: () -> Void = {}
    public var onLongPress: (CGPoint) -> Void = { _ in }
  }

  public let contentView: ContentView

  public var handlers = Handlers()

  public let overlayView: UIView?

  private let animationTargetViw: UIView

  private let animation: InteractiveViewHighlightAnimation
  private let haptics: HapticsDescriptor?

  public var longPressGestureRecognizer: UILongPressGestureRecognizer?
  private let useLongPressGesture: Bool

  public override var isHighlighted: Bool {
    didSet {
      animation.animation(isHighlighted, self, animationTargetViw)
    }
  }

  public init(
    animation: InteractiveViewHighlightAnimation,
    haptics: HapticsDescriptor? = nil,
    useLongPressGesture: Bool = false,
    contentView: ContentView
  ) {

    self.haptics = haptics
    self.animation = animation
    self.overlayView = animation.overlayView
    self.animationTargetViw = contentView
    self.contentView = contentView
    self.useLongPressGesture = useLongPressGesture

    super.init(frame: .zero)

    addSubview(contentView)

    contentView.mondrian.layout.edges(.toSuperview).activate()
    contentView.isUserInteractionEnabled = false

    accessibilityTraits = .button

    addTarget(
      self,
      action: #selector(_touchUpInside),
      for: .touchUpInside
    )

    addTarget(
      self,
      action: #selector(_touchDownInside),
      for: .touchDown
    )

    if let overlayView = overlayView {

      mondrian.buildSubviews {
        ZStackBlock {
          animationTargetViw
            .viewBlock
            .overlay(overlayView)
        }
      }
    } else {

      mondrian.buildSubviews {
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

  @objc private func _touchDownInside() {
    haptics?.send(event: .onTouchDownInside)
  }

  @objc private func _touchUpInside() {
    haptics?.send(event: .onTouchUpInside)
    handlers.onTap()
  }

}

public struct InteractiveViewHighlightAnimation {

  public typealias Block = (
    _ isHighlighted: Bool,
    _ containerNode: UIView,
    _ bodyNode: UIView
  ) -> Void

  public let animation: Block
  public let overlayView: UIView?

  public init(
    overlayView: () -> UIView? = { nil },
    animation: @escaping Block
  ) {
    self.overlayView = overlayView()
    self.animation = animation
  }
}

extension InteractiveViewHighlightAnimation {

  public static let noAnimation: Self = .init { _, _, _ in }

  ///
  public static let bodyShrink: Self = customBodyShrink(
    shrinkingScale: 0.97
  )

  public static func customBodyShrink(
    shrinkingScale: CGFloat
  ) -> Self {
    return .init { isHighlighted, containerNode, body in
      if isHighlighted {
        UIView.animate(
          withDuration: 0.4,
          delay: 0,
          usingSpringWithDamping: 1,
          initialSpringVelocity: 0,
          options: [.beginFromCurrentState, .allowUserInteraction],
          animations: {
            body.transform = .init(scaleX: shrinkingScale, y: shrinkingScale)
          },
          completion: nil
        )
      } else {
        UIView.animate(
          withDuration: 0.3,
          delay: 0.1,
          usingSpringWithDamping: 1,
          initialSpringVelocity: 0,
          options: [.beginFromCurrentState, .allowUserInteraction],
          animations: {
            body.transform = .identity
          },
          completion: nil
        )
      }
    }
  }

  ///
  public static let translucent: Self = .init {
    isHighlighted,
    containerNode,
    body in
    if isHighlighted {
      UIView.animate(
        withDuration: 0.12,
        delay: 0,
        options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction],
        animations: {
          containerNode.alpha = 0.8
        },
        completion: nil
      )
    } else {
      UIView.animate(
        withDuration: 0.08,
        delay: 0.1,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: {
          containerNode.alpha = 1
        },
        completion: nil
      )
    }
  }

  ///
  ///
  /// - Parameters:
  ///   - cornerRadius:
  ///   - insets:
  ///   - overlayColor:
  /// - Returns:
  public static func shrink(
    cornerRadius: CGFloat,
    insets: UIEdgeInsets,
    overlayColor: UIColor = .init(white: 0, alpha: 0.05)
  ) -> Self {

    let containerView = UIView()
    let overlayView = ShapeLayerView.roundedCorner(radius: cornerRadius)

    containerView.addSubview(overlayView)

    var insets = insets
    insets.top *= -1
    insets.right *= -1
    insets.bottom *= -1
    insets.left *= -1

    containerView.mondrian.buildSubviews {
      ZStackBlock {
        overlayView
          .viewBlock
          .padding(insets)
      }
    }

    containerView.alpha = 0

    return .init(overlayView: { containerView }) { isHighlighted, _, body in

      overlayView.shapeFillColor = overlayColor

      if isHighlighted {
        UIView.animate(
          withDuration: 0.26,
          delay: 0,
          options: [
            .beginFromCurrentState, .allowAnimatedContent,
            .allowUserInteraction, .curveEaseOut,
          ],
          animations: {
            containerView.layer.opacity = 0.98
            containerView.transform = .init(scaleX: 0.98, y: 0.98)
            body.transform = .init(scaleX: 0.98, y: 0.98)
          },
          completion: nil
        )

      } else {
        UIView.animate(
          withDuration: 0.20,
          delay: 0,
          options: [
            .beginFromCurrentState, .allowAnimatedContent,
            .allowUserInteraction, .curveEaseOut,
          ],
          animations: {
            containerView.layer.opacity = 0
            containerView.transform = .identity
            body.transform = .identity
          },
          completion: nil
        )
      }
    }
  }

  ///
  public static func colorOverlay(
    overlayColor: UIColor = .init(white: 0, alpha: 0.05),
    cornerRadius: CGFloat = 0
  ) -> Self {

    let overlayView = UIView()
    overlayView.backgroundColor = overlayColor
    overlayView.alpha = 0

    overlayView.layer.cornerRadius = cornerRadius
    if #available(iOS 13.0, *) {
      overlayView.layer.cornerCurve = .continuous
    }

    return .init(overlayView: { overlayView }) { isHighlighted, _, _ in

      if isHighlighted {
        UIView.animate(
          withDuration: 0.12,
          delay: 0,
          options: [
            .beginFromCurrentState, .curveEaseIn, .allowUserInteraction,
          ],
          animations: {
            overlayView.alpha = 1
          },
          completion: nil
        )

      } else {
        UIView.animate(
          withDuration: 0.08,
          delay: 0.1,
          options: [.beginFromCurrentState, .allowUserInteraction],
          animations: {
            overlayView.alpha = 0
          },
          completion: nil
        )
      }
    }
  }
}

public struct HapticsDescriptor {

  public enum Event: Equatable {
    case onTouchDownInside
    case onTouchUpInside
    case onLongPress
  }

  private let _onReceiveEvent: (Event) -> Void

  public init(
    onReceiveEvent: @escaping (Event) -> Void
  ) {
    self._onReceiveEvent = onReceiveEvent
  }

  public func send(event: Event) {
    _onReceiveEvent(event)
  }
}

extension HapticsDescriptor {

  public static func impactOnTouchUpInside(
    style: UIImpactFeedbackGenerator.FeedbackStyle = .light,
    delay: DispatchTimeInterval = .seconds(0)
  ) -> Self {

    let feedbackGenerator = UIImpactFeedbackGenerator(style: style)

    return self.init { event in
      if case .onTouchUpInside = event {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          feedbackGenerator.impactOccurred()
        }
      }
    }
  }

}
