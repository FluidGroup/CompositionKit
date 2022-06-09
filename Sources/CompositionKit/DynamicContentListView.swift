import Foundation
import MondrianLayout
import UIKit

open class DynamicSizingCollectionViewCell: UICollectionViewCell {

  public override init(
    frame: CGRect
  ) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError()
  }

  public func layoutWithInvalidatingCollectionViewLayout(animated: Bool) {

    guard let collectionView = (superview as? UICollectionView) else {
      return
    }

    if animated {

      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [
          .beginFromCurrentState,
          .allowUserInteraction,
          .overrideInheritedCurve,
          .overrideInheritedOptions,
          .overrideInheritedDuration,
        ],
        animations: {
          collectionView.performBatchUpdates(nil, completion: nil)
          collectionView.layoutIfNeeded()
        },
        completion: { (finish) in

        }
      )

    } else {

      CATransaction.begin()
      CATransaction.setDisableActions(true)
      collectionView.performBatchUpdates(nil, completion: nil)
      collectionView.layoutIfNeeded()
      CATransaction.commit()

    }
  }

}

/// Preimplemented list view using UICollectionView and UICollectionViewCompositionalLayout.
/// - Supports dynamic content update
/// - Self cell sizing
/// - Update sizing using ``DynamicSizingCollectionViewCell``.
///
/// - TODO: Currently supported only vertical scrolling.
@available(iOS 13, *)
open class DynamicContentListView<Data: Hashable>: CodeBasedView {

  @available(iOS 14, *)
  public typealias CellRegistration<Cell: UICollectionViewCell> = UICollectionView.CellRegistration<
    Cell, Data
  >

  private enum Section: Hashable {
    case main
  }

  public var scrollView: UIScrollView {
    collectionView
  }

  public let collectionView: UICollectionView

  public var layout: UICollectionViewCompositionalLayout {
    collectionView.collectionViewLayout as! UICollectionViewCompositionalLayout
  }

  private var _delegateProxy: _DynamicContentListViewDelegateProxy?

  private var _cellForItemAt: ((UICollectionView, Data, IndexPath) -> UICollectionViewCell)?

  private var _didSelectItemAt: ((Data) -> Void)?

  private var dataSource: UICollectionViewDiffableDataSource<Section, Data>!

  public init(
    scrollDirection: UICollectionView.ScrollDirection,
    spacing: CGFloat = 0,
    contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .never
  ) {

    switch scrollDirection {
    case .vertical:

      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(50)
        ),
        subitems: [
          NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(50)
            )
          )
        ]
      )

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = spacing
      
      let configuration = UICollectionViewCompositionalLayoutConfiguration()
      configuration.scrollDirection = scrollDirection

      let layout = UICollectionViewCompositionalLayout.init(section: section)

      self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    case .horizontal:

      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)),
        subitems: [
          .init(
            layoutSize: .init(
              widthDimension: .estimated(100),
              heightDimension: .fractionalHeight(1)
            )
          )
        ]
      )

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = spacing

      let configuration = UICollectionViewCompositionalLayoutConfiguration()
      configuration.scrollDirection = scrollDirection

      let layout = UICollectionViewCompositionalLayout.init(section: section, configuration: configuration)

      self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    @unknown default:
      fatalError()
    }

    super.init(frame: .zero)

    self.backgroundColor = .clear
    self.collectionView.backgroundColor = .clear
    self.collectionView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
 
    self.addSubview(collectionView)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: topAnchor),
      collectionView.rightAnchor.constraint(equalTo: rightAnchor),
      collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
      collectionView.leftAnchor.constraint(equalTo: leftAnchor),
    ])

    let dataSource = UICollectionViewDiffableDataSource<Section, Data>(
      collectionView: collectionView,
      cellProvider: { [unowned self] collectionView, indexPath, item in
        guard let delegate = self._cellForItemAt else {
          assertionFailure("Needs setup before start using.")
          return UICollectionViewCell(frame: .zero)
        }
        let data = item
        return delegate(collectionView, data, indexPath)
      }
    )

    self.dataSource = dataSource

    let _delegateProxy = _DynamicContentListViewDelegateProxy(
      didSelectItemAt: { [weak self] indexPath in
        guard let self = self else { return }
        let item = self.dataSource.itemIdentifier(for: indexPath)!
        self._didSelectItemAt?(item)
      }
    )

    self._delegateProxy = _delegateProxy

    self.collectionView.delegate = _delegateProxy
    self.collectionView.dataSource = dataSource
    self.collectionView.delaysContentTouches = false

  }
  
  public func registerCell<Cell: UICollectionViewCell>(
    _ cellType: Cell.Type,
    forCellWithReuseIdentifier: String
  ) {
    collectionView.register(
      cellType,
      forCellWithReuseIdentifier: forCellWithReuseIdentifier
    )
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    collectionView.layoutIfNeeded()
  }

  public func setUp(
    cellForItemAt: @escaping (UICollectionView, Data, IndexPath) -> UICollectionViewCell,
    didSelectItemAt: @escaping (Data) -> Void
  ) {

    _didSelectItemAt = didSelectItemAt
    _cellForItemAt = cellForItemAt
  }

  public func setContents(_ contents: [Data], animatedUpdating: Bool = true) {

    var snapshot = NSDiffableDataSourceSnapshot<Section, Data>.init()
    snapshot.appendSections([.main])
    snapshot.appendItems(contents, toSection: .main)

    dataSource.apply(snapshot, animatingDifferences: animatedUpdating)

  }

  public func setContentInset(_ insets: UIEdgeInsets) {
    collectionView.contentInset = insets
  }

}

private final class _DynamicContentListViewDelegateProxy: NSObject,
  UICollectionViewDelegate
{

  private let _didSelectItemAt: (IndexPath) -> Void

  init(
    didSelectItemAt: @escaping (IndexPath) -> Void
  ) {
    _didSelectItemAt = didSelectItemAt
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    _didSelectItemAt(indexPath)
  }

}
