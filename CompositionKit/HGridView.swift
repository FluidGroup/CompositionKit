import MondrianLayout
import UIKit

/**
 Displays views as grid horizontally

 - Attention: No recycles view
 */
@available(iOS 13, *)
public final class HGridView: _GridView {

  public init(numberOfColumns: Int) {
    super.init(scrollDirection: .horizontal, numberOfColumns: numberOfColumns)
  }

}
