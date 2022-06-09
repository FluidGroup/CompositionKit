import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit

@available(iOS 13, *)
extension Book {

  static var hostingCell: some BookView {
    BookNavigationLink(title: "HostingCell") {
      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

        let view = DynamicContentListView<Item>.init(scrollDirection: .vertical)

        view.registerCell(HostingCell.self, forCellWithReuseIdentifier: "HostingCell")

        view.setUp(
          cellForItemAt: { collectionView, item, indexPath in

            let cell =
              collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath)
              as! HostingCell

            cell.setContent { state in

              Book.SwiftUICell(state: state)
            }

            return cell

          },
          didSelectItemAt: { _ in

          }
        )

        let items = (0..<100).map { _ in
          Item.init(text: BookGenerator.loremIpsum(length: 10))
        }

        view.setContents(items)

        return view
      }

    }
  }

  struct SwiftUICell: View {

    let state: HostingCell.State

    var body: some View {

      HStack(spacing: -50) {

        Circle()
          .frame(width: 40, height: 40)
          .foregroundColor(.pink)
          .blur(radius: {
            if state.isHighlighted {
              return 20
            } else {
              return 0
            }
          }())
        
        Circle()
          .frame(width: 40, height: 40)
          .foregroundColor(.blue)
          .blur(radius: state.isHighlighted ? 20 : 0)
            
      }
      .padding(50)
      .animation(.interactiveSpring())

    }

  }

}

@available(iOS 13, *)
enum Preview: PreviewProvider {

  static var previews: some View {

    Group {
      Book.SwiftUICell(state: .init(isSelected: false, isHighlighted: false))
    }

  }

}

@available(iOS 13, *)
struct HostingCellSimulator<Content: View>: View {

  init(content: @escaping (HostingCell.State) -> Content) {

  }

  var body: some View {
    Group {

    }

  }

}
