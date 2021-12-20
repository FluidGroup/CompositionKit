import StorybookKit
import UIKit
import SwiftUI
import MondrianLayout

public enum Book_NavigationHostingView {

  static var body: BookView {

    BookNavigationLink(title: "NavigationHostingView") {
      BookPresent(title: "Present") {
        let controller = ViewController()
        controller.modalPresentationStyle = .fullScreen
        return controller
      }
    }

  }

  private final class ViewController: UIViewController {

    private let navigationView: NavigationHostingView = .init()

    override func viewDidLoad() {
      super.viewDidLoad()

      view.backgroundColor = .white

      navigationView.setup(on: self)

      let dismissButton = UIButton(type: .system)&>.do {
        $0.onTap { [unowned self] in
          dismiss(animated: true, completion: nil)
        }
        $0.setTitle("Dismiss", for: .normal)
      }

      let navigationContentView = AnyView { view in
        ZStackBlock {
          HStackBlock {
            dismissButton
          }
        }
      }

      navigationContentView.backgroundColor = .init(white: 0.95, alpha: 1)

      navigationView.setContent(navigationContentView)


      Mondrian.buildSubviews(on: view) {
        LayoutContainer(attachedSafeAreaEdges: .all) {
          ZStackBlock {
            UIView.mock(backgroundColor: .neon(.cyan))
              .viewBlock
              .alignSelf(.attach(.top))
          }
        }
      }
      
    }
  }

}

