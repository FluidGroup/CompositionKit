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

  public struct Configuration {
    public var registersAsChildViewController: Bool
    public var fixesSafeArea: Bool

    public init(
      registersAsChildViewController: Bool = true,
      fixesSafeArea: Bool = false
    ) {
      self.registersAsChildViewController = registersAsChildViewController
      self.fixesSafeArea = fixesSafeArea
    }
  }

  public struct State {

  }

  private var hostingController: (any _HostingControllerType)!

  private let proxy: Proxy<State> = .init(state: .init())

  public let ignoringSafeAreaEdges: Edge.Set

  public let configuration: Configuration

  public convenience init<Content: View>(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    ignoringSafeAreaEdges: Edge.Set = .all,
    configuration: Configuration = .init(),
    @ViewBuilder content: @escaping (State) -> Content
  ) {
    self.init(
      name,
      file,
      function,
      line,
      ignoringSafeAreaEdges: ignoringSafeAreaEdges,
      configuration: configuration
    )
    setContent(content: content)
  }

  // MARK: - Initializers

  public init(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    ignoringSafeAreaEdges: Edge.Set = .all,
    configuration: Configuration = .init()
  ) {
    self.ignoringSafeAreaEdges = ignoringSafeAreaEdges
    self.configuration = configuration

    super.init(frame: .null)

    #if DEBUG
    let file = URL(string: file.description)?.deletingPathExtension().lastPathComponent ?? "unknown"
    self.accessibilityIdentifier = [
      name,
      file,
      function.description,
      line.description,
    ]
    .joined(separator: ".")
    #endif
    
    if configuration.fixesSafeArea {
      self.hostingController = FixedSafeAreaHostingController(
        rootView: RootView(proxy: proxy)
      )
    } else {
      
      self.hostingController = HostingController(
        rootView: RootView(proxy: proxy)
      )
    }

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

    if configuration.registersAsChildViewController {
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
  }

  // MARK: -
  
  public final func setContent<Content: SwiftUI.View>(
    @ViewBuilder content: @escaping (State) -> Content
  ) {
    proxy.content = { [ignoringSafeAreaEdges] state in
      if #available(iOS 14, *) {
        return SwiftUI.AnyView(
          content(state)
            .ignoresSafeArea(edges: ignoringSafeAreaEdges)
        )
      } else {
        return SwiftUI.AnyView(
          content(state)
            .edgesIgnoringSafeArea(ignoringSafeAreaEdges)
        )
      }
    }
  }

}
