import SwiftUI

@available(iOS 13, *)
final class Proxy<State>: ObservableObject {
  @Published var state: State
  @Published var content: (State) -> SwiftUI.AnyView? = { _ in nil }
  
  init(state: State) {
    self.state = state
  }
}

@available(iOS 13, *)
struct RootView<State>: SwiftUI.View {
  @ObservedObject var proxy: Proxy<State>
  
  var body: some View {
    proxy.content(proxy.state)
  }
}

@available(iOS 13, *)
open class HostingView: UIView {

  public struct State {

  }

  private var hostingController: HostingController<RootView<State>>!
  
  private let proxy: Proxy<State> = .init(state: .init())

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

    self.hostingController = HostingController(
      rootView: RootView(proxy: proxy)
    )
    
    hostingController.view.backgroundColor = .clear

    addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingController.view.leftAnchor.constraint(equalTo: leftAnchor),
    ])
    
    hostingController.view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    hostingController.view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    
    hostingController.view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    hostingController.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    
    setContentHuggingPriority(.defaultHigh, for: .horizontal)
    setContentHuggingPriority(.defaultHigh, for: .vertical)
    
    hostingController.onViewDidLayoutSubviews = { controller in
      // TODO: Reduces number of calling invalidation, it's going to be happen even it's same value.
      controller.view.invalidateIntrinsicContentSize()
    }

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: UIView

  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    hostingController.sizeThatFits(in: size)
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
      SwiftUI.AnyView(
        content(state)
          .edgesIgnoringSafeArea(.all)
      )
    }
  }

}
