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
      
      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {
        
        AnyView { _ in
          VStackBlock(spacing: 2) {
            HostingView { _ in
              InteractiveView()
            }&>.do {
              $0.backgroundColor = .lightGray
            }
            HostingView { _ in
              InteractiveView()
            }&>.do {
              $0.backgroundColor = .lightGray
            }
            HostingView { _ in
              InteractiveView()
            }&>.do {
              $0.backgroundColor = .lightGray
            }
          }
        }
                       
      }
    }

  }

}

@available(iOS 13.0, *)
private struct InteractiveView: View {
  
  @State var isOn: Bool = false
  
  var body: some View {
    Button("toggle") {
      isOn.toggle()
    }
    if isOn {
      Color.gray.frame(height: 30)
    }
  }
  
}
