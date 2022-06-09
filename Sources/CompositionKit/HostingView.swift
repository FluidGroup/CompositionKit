import SwiftUI

@available(iOS 13, *)
open class HostingView: UIView {

  public struct State {

  }

  private final class Proxy: ObservableObject {
    @Published var state = State()
    @Published var content: (State) -> SwiftUI.AnyView? = { _ in nil }
  }

  private struct RootView: SwiftUI.View {

    @ObservedObject var proxy: Proxy

    var body: some View {
      proxy.content(proxy.state)
    }

  }

  private var hostingController: UIHostingController<RootView>!

  private let proxy: Proxy = .init()

  public convenience init() {
    self.init(frame: .zero)
  }

  public convenience init<Content: View>(@ViewBuilder content: @escaping (State) -> Content) {
    self.init()
    setContent(content: content)
  }

  // MARK: - Initializers

  public override init(frame: CGRect) {

    super.init(frame: frame)

    self.hostingController = UIHostingController(
      rootView: RootView(proxy: proxy)
    )

    addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingController.view.leftAnchor.constraint(equalTo: leftAnchor),
    ])

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: UIView

  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    hostingController.sizeThatFits(in: size)
  }

  open override var intrinsicContentSize: CGSize {
    hostingController.view.intrinsicContentSize
  }

  open override func didMoveToWindow() {

    super.didMoveToWindow()
    
    // https://muukii.notion.site/Why-we-need-to-add-UIHostingController-to-view-controller-chain-14de20041c99499d803f5a877c9a1dd1

    if let _ = window {
      if let parentViewController = self.findNearestViewController() {
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
      } else {
        assertionFailure()
      }
    } else {
      hostingController.willMove(toParent: nil)
      hostingController.removeFromParent()
    }
  }

  // MARK: -

  public final func setContent<Content: SwiftUI.View>(
    @ViewBuilder content: @escaping (State) -> Content
  ) {
    proxy.content = { state in
      SwiftUI.AnyView(content(state))
    }
  }

}
