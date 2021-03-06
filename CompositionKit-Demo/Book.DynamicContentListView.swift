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

        let items = (0 ..< 100).map { _ in
          Item(text: BookGenerator.loremIpsum(length: 10))
        }
        
        view.setContents(items)

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

              @available(*, unavailable)
              required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
              }
            }

            func makeContentView() -> UIView & UIContentView {
              print("Make")
              return MyContentView()
            }

            func updated(for _: UIConfigurationState) -> Self {
              self
            }
          }

          let view = DynamicContentListView<Item>.init(scrollDirection: .vertical)

          let registration = UICollectionView.CellRegistration<UICollectionViewCell, Item>.init {
            cell,
              _,
              _ in
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

          let items = (0 ..< 100).map { _ in
            Item(text: BookGenerator.loremIpsum(length: 10))
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
                  Book.SwiftUICell(state: .init(isSelected: false, isHighlighted: false), name: item.text)
                }
                .margins(.all, 0)

                return cell
              },
              didSelectItemAt: { _ in
              }
            )

            let items = (0 ..< 100).map { _ in
              Item(text: BookGenerator.loremIpsum(length: 10))
            }

            view.setContents(items)

            return view
          }
        }
      #endif
    }
  }

  struct Item: Hashable, Identifiable {
    var id: UUID = .init()

    let text: String
  }

  final class Cell: UICollectionViewCell {
    
    private let label = UILabel()
    private let box = UIView()
    private let button = UIButton(type: .system)

    override var isHighlighted: Bool {
      didSet {
        print(isHighlighted)
      }
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)

      button.setTitle("Hit", for: .normal)

      Mondrian.buildSubviews(on: contentView) {
        VStackBlock(spacing: 8) {
          label
          box
          button
        }
        .padding(.vertical, 10)
      }
      
      let height = box.heightAnchor.constraint(equalToConstant: 0)
      height.isActive = true
      
      var isOn = false

      button.onTap { [unowned self] in
        isOn.toggle()
        
        if isOn {
          height.constant = 30
        } else {
          height.constant = 0
        }
        
        self.invalidateIntrinsicContentSize()
      }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
      let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
      
      return attributes
    }

    func update(_ item: Item) {
      label.text = item.text
    }
  }
}
