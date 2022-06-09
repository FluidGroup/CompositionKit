import SwiftUI

/// Light-weight backported implementation from `UIHostingConfiguration`.
@available(iOS 13, *)
open class HostingCell: UICollectionViewCell {
  
  public struct State {
    public var isSelected = false
    public var isHighlighted = false
  }
  
  private class Proxy: ObservableObject {
    @Published var state  = State()
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
  
  open override var isSelected: Bool {
    didSet {
      if proxy.state.isSelected != isSelected {
        proxy.state.isSelected = isSelected
      }
    }
  }
  
  open override var isHighlighted: Bool {
    didSet {
      if proxy.state.isHighlighted != isHighlighted {
        proxy.state.isHighlighted = isHighlighted
      }
    }
  }
  
  public override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    self.hostingController = UIHostingController(
      rootView: RootView(proxy: proxy)
    )
    
    contentView.addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      hostingController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
    ])
    
  }
  
  public func setContent<Content: SwiftUI.View>(@ViewBuilder content: @escaping (State) -> Content) {
    proxy.content = { state in
      SwiftUI.AnyView(content(state))
    }
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
