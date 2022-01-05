import MondrianLayout
import UIKit

/**
 Displays views as grid vertically

 - Attention: No recycles view
 */
@available(iOS 13, *)
public final class VGridView: _GridView {

  public init(numberOfColumns: Int) {
    super.init(scrollDirection: .vertical, numberOfColumns: numberOfColumns)
  }

}
