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
            collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath) as! HostingCell
            
            cell.setContent { state in
              
              VStack {
                
                Rectangle()
                  .foregroundColor(.blue)
                  .frame(width: 50, height: 50)
                
                Rectangle()
                  .foregroundColor(.blue)
                  .frame(width: 50, height: 50)
                
                HStack {
                  Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .blur(radius: 20)
                  
                  Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .blur(radius: 10)
                }
                
              }
              .background(state.isHighlighted ? Color.red : Color.blue)
              
              Text("isHighlighted: \(state.isHighlighted.description)")
              
              Text("\(item.text)")
              
              Button.init("Hit!") {
                print("Hit")
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
  }

}
