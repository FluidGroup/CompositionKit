import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit

enum Section {
  case a
  case b
  case c
}

@available(iOS 13, *)
@MainActor
extension Book {
  static var dynamicContentListView: BookView {
    BookNavigationLink(title: "DynamicContentListView") {
      
      BookNavigationLink(title: "Grid") {
        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) { () -> DynamicCompositionalLayoutSingleSectionView<Item> in
          
          let view = DynamicCompositionalLayoutSingleSectionView<Item>(layout: {
            let left = NSCollectionLayoutItem(
              layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(300)
              )
            )&>.do {
              $0.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 8)
            }
            
            let right = NSCollectionLayoutItem(
              layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(300)
              )
            )&>.do {
              $0.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 24)
            }
            
            let group = NSCollectionLayoutGroup.horizontal(
              layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
              ),
              subitems: [
                left,
                right
              ]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = .init(top: 20, leading: 0, bottom: 20, trailing: 0)
            
            let configuration = UICollectionViewCompositionalLayoutConfiguration()
            configuration.scrollDirection = .vertical
            
            let layout = UICollectionViewCompositionalLayout.init(section: section)
            return layout
          }())
          
          view.setUp(
            cellProvider: .init { context in
              
              return context.containerCell {
                DataRepresentingView(item: context.data)
              }
              
            },
            actionHandler: { [weak view] action in
              
              guard let view else { return }
              
              switch action {
              case .didSelect(let item):
                break
              case .batchFetch(let thunk):
                thunk {
                  try? await Task.sleep(nanoseconds: 1_000_000_000)
                  
                  let items = (0 ..< 3).map { _ in
                    Item(text: BookGenerator.randomEmoji())
                  }
                  
                  var snapshot = view.snapshot()
                  snapshot.appendItems(items)
                  
                  view.setContents(snapshot: snapshot, animatedUpdating: true)
                }
                
              }
            }
          )
          
          view.setContents([.init(id: "2", text: "2")], animatedUpdating: true)
          
          return view
        }
        .addButton("Update content") { view in
          
          let items = (0 ..< 30).map { _ in
            Item(text: BookGenerator.randomEmoji())
          }
          
          view.setContents(items)
        }
      }

      BookNavigationLink(title: "Sectioned") {
        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) { () -> DynamicCompositionalLayoutView<Section, Item> in
          
          let view = DynamicCompositionalLayoutView<Section, Item>.init(scrollDirection: .vertical)
                    
          view.setUp(
            cellProvider: .init { context in
                            
              return context.containerCell {
                DataRepresentingView(item: context.data)
              }
              
            },
            actionHandler: { [weak view] action in
              
              guard let view else { return }
              
              switch action {
              case .didSelect(let item):
                break
              case .batchFetch(let thunk):
                thunk {
                  try? await Task.sleep(nanoseconds: 1_000_000_000)
                  
                  let items = (0 ..< 3).map { _ in
                    Item(text: BookGenerator.randomEmoji())
                  }
                  
                  var snapshot = view.snapshot()
                  snapshot.appendItems(items, toSection: .b)
                  
                  view.setContents(snapshot: snapshot, animatedUpdating: true)
                }

              }
            }
          )
 
          view.setContents([.init(id: "2", text: "2")], inSection: .b, animatedUpdating: true)
          view.setContents([.init(id: "1", text: "1")], inSection: .a, animatedUpdating: true)
          
          return view
        }
        .addButton("Update content") { view in
          
          let items = (0 ..< 30).map { _ in
            Item(text: BookGenerator.randomEmoji())
          }
          
          view.setContents(items, inSection: .b)
        }
        
      }
      
      BookNavigationLink(title: "Horizontal") {
        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) { () -> DynamicCompositionalLayoutView<Section, Item> in
          
          let view = DynamicCompositionalLayoutView<Section, Item>.init(scrollDirection: .horizontal)
          
          view.setUp(
            cellProvider: .init { context in
              
              return context.containerCell {
                DataRepresentingView(item: context.data)
              }
              
            },
            actionHandler: { _ in }
          )
          
          view.setContents([.init(id: "2", text: "2")], inSection: .b, animatedUpdating: true)
          view.setContents([.init(id: "1", text: "1")], inSection: .a, animatedUpdating: true)
          
          return view
        }
      }
      
      BookNavigationLink(title: "Single") {
        
        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) { () -> DynamicCompositionalLayoutSingleSectionView<DynamicContentListItem<Book.Item>> in
          
          let view = DynamicCompositionalLayoutSingleSectionView<DynamicContentListItem<Item>>.init(scrollDirection: .vertical)
          
          view.registerCell(Cell.self)
          
          view.setUp(
            cellProvider: .init { context in
              
              switch context.data {
              case .data(let data):
                
                return context.containerCell {
                  DataRepresentingView(item: data)
                }
                
              case .view(let view):
                return context.containerCell(content: view)
              }
              
            },
            actionHandler: { _ in }
          )
          
          let items = (0 ..< 100).map { _ in
            Item(text: BookGenerator.randomEmoji())
          }
          
          view.setContents(items.map { .data($0) })
          
          return view
        }
        .addButton("Update content") { view in
          
          let items = (0 ..< 100).map { _ in
            Item(text: BookGenerator.randomEmoji())
          }
          
          view.setContents(items.map { .data($0) })
        }
        
        BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {
          let view = DynamicCompositionalLayoutSingleSectionView<Item>.init(scrollDirection: .vertical)
          
          view.registerCell(Cell.self)
          
          view.setUp(
            cellProvider: .init { context in
              
              let cell = context.dequeueReusableCell(Cell.self)
              cell.update(context.data)
              
              return cell
            },
            actionHandler: { _ in }
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
            @MainActor
            class MyConfiguration: UIContentConfiguration {
              @MainActor
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
              
              @MainActor
              func makeContentView() -> UIView & UIContentView {
                print("Make")
                return MyContentView()
              }
              
              func updated(for _: UIConfigurationState) -> Self {
                self
              }
            }
            
            let view = DynamicCompositionalLayoutSingleSectionView<Item>.init(scrollDirection: .vertical)
            
            let registration = UICollectionView.CellRegistration<UICollectionViewCell, Item>.init {
              cell,
              _,
              _ in
              let content = MyConfiguration()
              cell.contentConfiguration = content
            }
            
            view.setUp(
              cellProvider: .init { context in
                
                let cell = context.collectionView.dequeueConfiguredReusableCell(
                  using: registration,
                  for: context.indexPath,
                  item: context.data
                )
                
                return cell
                
              },
              actionHandler: { _ in }
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
            let view = DynamicCompositionalLayoutSingleSectionView<Item>.init(scrollDirection: .vertical)
            
            view.registerCell(Cell.self)
            
            view.setUp(
              cellProvider: .init { context in
                
                let cell = context.dequeueReusableCell(Cell.self)
                
                cell.contentConfiguration = UIHostingConfiguration {
                  Book.SwiftUICell(state: .init(isSelected: false, isHighlighted: false), name: context.data.text)
                }
                .margins(.all, 0)
                
                return cell
                
              },
              actionHandler: { _ in }
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
  }

  struct Item: Hashable, Identifiable {
    var id: String = UUID().uuidString

    let text: String
  }

  final class Cell: DynamicSizingCollectionViewCell {
    
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
  
  final class DataRepresentingView: HostingView {
    
    private let item: Item
    
    init(item: Item) {
      
      self.item = item
      
      print("Init, \(item)")
      
      super.init()
      
      setContent { _ in
        HStack {
          Text(item.text)
          Button("Tap") {
            
          }
        }
        .padding(20)
      }
      
    }
    
    override func didMoveToSuperview() {
      super.didMoveToSuperview()
      
      if superview == nil {
        print("removed", item)
      } else {
//        print("added", item, superview!)
      }
    }
    
  }
  
}
