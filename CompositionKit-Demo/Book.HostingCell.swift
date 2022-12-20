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
          cellProvider: .init { context in
            
            let cell =
            context.collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: context.indexPath)
            as! HostingCell
            
            cell.setContent { state in
              
              Book.SwiftUICell(state: state, name: context.data.text)
            }
            
            return cell
            
          },
          didSelectItemAt: { _ in
          }
        )

        let items = (0 ..< 100).map { i in
          Item(text: "\(i)")
        }

        view.setContents(items)

        return view
      }
    }
  }

  struct SwiftUICell: View {
    let state: HostingCell.State
    let name: String

    @State var isOn = true

    var body: some View {
      HStack {
        Text(name)
          .font(.system(size: 20, weight: .heavy, design: .serif))
        VStack {
          HStack(spacing: -50) {
            Circle()
              .frame(width: 40, height: 40)
              .foregroundColor(.pink)
              .blur(
                radius: {
                  if state.isHighlighted {
                    return 20
                  } else {
                    return 0
                  }
                }()
              )

            Circle()
              .frame(width: 40, height: 40)
              .foregroundColor(.blue)
              .blur(radius: state.isHighlighted ? 20 : 0)
          }

          if isOn {
            Text("Hi!")
          }

          Button("Toggle") {
            withAnimation(.interactiveSpring()) {
              isOn.toggle()
            }
          }
        }
      }
      .padding(50)
      .background(Rectangle().border(isOn ? .blue : .gray, width: 8).foregroundColor(.clear))
      .background(Rectangle().border(.pink, width: 30).foregroundColor(.clear))
      
    }
  }
}

@available(iOS 13, *)
enum Preview: PreviewProvider {
  static var previews: some View {
    Group {
      Book.SwiftUICell(state: .init(isSelected: false, isHighlighted: false), name: "20")
    }
  }
}

@available(iOS 13, *)
struct HostingCellSimulator<Content: View>: View {
  init(content _: @escaping (HostingCell.State) -> Content) {}

  var body: some View {
    Group {}
  }
}
