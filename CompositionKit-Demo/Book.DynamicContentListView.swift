
import StorybookKit
import UIKit
import CompositionKit
import MondrianLayout

@available(iOS 13, *)
extension Book {
  
  static var dynamicContentListView: BookView {
    BookNavigationLink(title: "DynamicContentListView") {
      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {
        
        let view = DynamicContentListView<Item>.init(scrollDirection: .vertical)
        
        view.registerCell(Cell.self, forCellWithReuseIdentifier: "Cell")
        
        view.setUp(
          cellForItemAt: { collectionView, item, indexPath in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
            cell.update(item)
          
            return cell
          },
          didSelectItemAt: { _ in
            
          }
        )
        
        view.setContents([.init(text: BookGenerator.loremIpsum(length: 10))])
        
        return view
      }
                 
    }
  }
  
  struct Item: Hashable {
    
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
