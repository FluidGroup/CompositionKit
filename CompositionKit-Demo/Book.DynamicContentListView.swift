import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit

@available(iOS 13, *)
extension Book {

  static var dynamicContentListView: BookView {
    BookNavigationLink(title: "DynamicContentListView") {
      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

        let view = DynamicContentListView<Item>.init(scrollDirection: .vertical)

        view.registerCell(Cell.self, forCellWithReuseIdentifier: "Cell")

        view.setUp(
          cellForItemAt: { collectionView, item, indexPath in

            let cell =
              collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
              as! Cell
            cell.update(item)

            return cell
          },
          didSelectItemAt: { _ in

          }
        )

        view.setContents([.init(text: BookGenerator.loremIpsum(length: 10))])

        return view
      }

      BookText("HostingCell")

      
      if #available(iOS 14, *) {

        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

          class MyConfiguration: UIContentConfiguration {

            class MyContentView: UIView, UIContentView {

              let label = UILabel()

              var configuration: UIContentConfiguration

              init() {
                self.configuration = MyConfiguration()
                super.init(frame: .zero)

                label.text = "Hey"

                Mondrian.buildSubviews(on: self) {
                  VStackBlock {
                    label
                  }
                  .padding(.vertical, 10)
                }
              }

              required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
              }
            }

            func makeContentView() -> UIView & UIContentView {
              print("Make")
              return MyContentView()
            }

            func updated(for state: UIConfigurationState) -> Self {
              return self
            }
          }

          let view = DynamicContentListView<Item>.init(scrollDirection: .vertical)

          let registration = UICollectionView.CellRegistration<UICollectionViewCell, Item>.init {
            cell,
            indexPath,
            itemIdentifier in
            let content = MyConfiguration()
            cell.contentConfiguration = content
          }

          view.setUp(
            cellForItemAt: { collectionView, item, indexPath in

              let cell = collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
              )
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

#if swift(>=5.7)
      if #available(iOS 16, *) {

        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {

          let view = DynamicContentListView<Item>.init(scrollDirection: .vertical)

          view.registerCell(Cell.self, forCellWithReuseIdentifier: "Cell")

          view.setUp(
            cellForItemAt: { collectionView, item, indexPath in

              let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                as! Cell

              cell.contentConfiguration = UIHostingConfiguration {
                VStack {
                  Text("\(item.text)")
                  Text("\(item.text)")
                }
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
#endif
    }

  }

  struct Item: Hashable, Identifiable {

    var id: UUID = UUID()

    let text: String

  }

  final class Cell: UICollectionViewCell {

    private let label = UILabel()

    override init(frame: CGRect) {
      super.init(frame: frame)

      Mondrian.buildSubviews(on: contentView) {
        VStackBlock {
          label
        }
        .padding(.vertical, 10)
      }
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func update(_ item: Item) {
      self.label.text = item.text
    }

  }

}
