import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit

@available(iOS 13, *)
extension Book {

  static var hostingView: some BookView {

    BookNavigationLink(title: "HostingView") {
      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

        HostingView { _ in
          Text("Hello, HostingView")
            .padding()
        }

      }
    }

  }

}
