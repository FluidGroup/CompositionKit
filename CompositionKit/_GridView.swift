import MondrianLayout
import UIKit

/**
 Displays views as grid vertically

 - Attention: No recycles view
 */
@available(iOS 13, *)
public class _GridView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
  private var contents: [UIView] = []

  private let layout: UICollectionViewCompositionalLayout

  init(scrollDirection: UICollectionView.ScrollDirection, numberOfColumns: Int) {

    let column = NSCollectionLayoutGroup.horizontal(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(10)),
      subitems: (0..<numberOfColumns).map { _ in
        .init(
          layoutSize: .init(
            widthDimension: .fractionalWidth(1.0 / CGFloat(numberOfColumns)),
            heightDimension: .estimated(100))
        )
      }
    )

    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(100)
      ),
      subitems: [
        column
      ]
    )

    let section = NSCollectionLayoutSection(group: group)
    let layout = UICollectionViewCompositionalLayout.init(section: section)

    layout.configuration.scrollDirection = scrollDirection

    self.layout = layout

    super.init(frame: .null, collectionViewLayout: layout)

#if DEBUG
    backgroundColor = .blue
#endif

    register(_WrapperCell.self, forCellWithReuseIdentifier: "Cell")

    isScrollEnabled = false

    dataSource = self
    delegate = self

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setContents(_ contents: [UIView]) {
    assert(Thread.isMainThread)
    self.contents = contents
    reloadData()
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contents.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! _WrapperCell
    let content = contents[indexPath.item]
    cell.setContent(content)
    return cell

  }

}

fileprivate final class _WrapperCell: UICollectionViewCell {

  override func prepareForReuse() {
    super.prepareForReuse()

    contentView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }

  func setContent(_ content: UIView) {
    contentView.addSubview(content)
    content.mondrian.layout.edges(.toSuperview).activate()
  }
}

