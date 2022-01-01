import MondrianLayout
import UIKit

// FIXME: WIP
@available(iOS 13, *)
public final class VGridView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
  private var contents: [UIView] = []

  private let layout: UICollectionViewCompositionalLayout

  public convenience init(contents: [UIView]) {
    self.init()
    self.contents = contents
  }

  public init() {

    let column = NSCollectionLayoutGroup.horizontal(
      layoutSize: NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(10)),
      subitems: [
        .init(
          layoutSize: .init(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(100))
        ),
        .init(
          layoutSize: .init(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(100))
        )
      ]
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

    self.layout = layout

    super.init(frame: .null, collectionViewLayout: layout)

    #if DEBUG
    backgroundColor = .blue
    #endif

    Mondrian.layout {
      mondrian.layout
        .height(.min(1))
        .height(.to(contentLayoutGuide).height)
    }
//
//    frameLayoutGuide.mondrian.layout
//      .edges(.to(contentLayoutGuide), .exact(0, .defaultHigh))
//      .activate()

    register(_WrapperCell.self, forCellWithReuseIdentifier: "Cell")

    isScrollEnabled = false

    dataSource = self
    delegate = self

  }

//  public override var intrinsicContentSize: CGSize {
//    layout.collectionViewContentSize
//  }

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

final class _WrapperCell: UICollectionViewCell {

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
