import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit

@available(iOS 13, *)
@MainActor
extension Book {

  static var hostingView: some BookView {

    BookNavigationLink(title: "HostingView") {

      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

        let view = HostingView { _ in
          BookLozenge()
        }

        view.backgroundColor = .yellow

        return CompositionKit.AnyView { _ in

          ZStackBlock {

            view

          }
        }

      }

      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

        HostingView { _ in
          Text("Hello, HostingView")
            .padding()
        }

      }

      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

        AnyView { _ in
          HStackBlock(spacing: 2) {
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

  struct BookLozenge: View {
    var body: some View {
      Text("こんにちは")
        .padding(10)
        .background(
          Color.blue
            .clipShape(RoundedCorner(radius: 10, corners: [.topLeft]))
            .clipShape(RoundedCorner(radius: 20, corners: [.topRight]))
            .clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft]))
            .clipShape(RoundedCorner(radius: 10, corners: [.bottomRight]))

        )
    }
  }

  struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
      let path = UIBezierPath(
        roundedRect: rect,
        byRoundingCorners: corners,
        cornerRadii: CGSize(width: radius, height: radius)
      )
      return Path(path.cgPath)
    }
  }

  struct BookLozenge_Previews: PreviewProvider {
    static var previews: some View {
      BookLozenge()
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
      HStack {
        Text("Hello")
        Color.gray.frame(height: 30)
      }
    }
  }

}
