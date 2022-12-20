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
  
  open override func invalidateIntrinsicContentSize() {
    if #available(iOS 16, *) {
      // from iOS 16, auto-resizing runs
      super.invalidateIntrinsicContentSize()
    } else {
      super.invalidateIntrinsicContentSize()
      self.layoutWithInvalidatingCollectionViewLayout(animated: true)
    }
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
          collectionView.collectionViewLayout.invalidateLayout()
          collectionView.layoutIfNeeded()
        },
        completion: { (finish) in

        }
      )

    } else {

      CATransaction.begin()
      CATransaction.setDisableActions(true)
      collectionView.collectionViewLayout.invalidateLayout()
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
  
  @MainActor
  public struct CellProviderContext {
    public unowned let collectionView: UICollectionView
    public let data: Data
    public let indexPath: IndexPath
    
    public func dequeueViewContainer() -> DynamicContentListViewContainerCell {
      return collectionView.dequeueReusableCell(withReuseIdentifier: _typeName(DynamicContentListViewContainerCell.self), for: indexPath) as! DynamicContentListViewContainerCell
    }
  }
  
  @MainActor
  public struct CellProvider {
    
    private var thunk: @MainActor (CellProviderContext) -> UICollectionViewCell
    
    public nonisolated init(_ thunk: @escaping @MainActor (CellProviderContext) -> UICollectionViewCell) {
      self.thunk = thunk
    }
    
    func cell(for context: CellProviderContext) -> UICollectionViewCell {
      thunk(context)
    }
    
  }

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

  private var _cellProvider: CellProvider?

  private var _didSelectItemAt: ((Data) -> Void)?

  private var dataSource: UICollectionViewDiffableDataSource<Section, Data>!
  
  public init(
    layout: UICollectionViewCompositionalLayout,
    contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .automatic
  ) {
    
    self.collectionView = .init(frame: .null, collectionViewLayout: layout)
    
    super.init(frame: .null)
    
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
        guard let provider = self._cellProvider else {
          assertionFailure("Needs setup before start using.")
          return UICollectionViewCell(frame: .zero)
        }
        let data = item
        return provider.cell(for: .init(collectionView: collectionView, data: data, indexPath: indexPath))
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
    self.collectionView.isPrefetchingEnabled = false
    
    collectionView.register(DynamicContentListViewContainerCell.self, forCellWithReuseIdentifier: _typeName(DynamicContentListViewContainerCell.self))
    
#if swift(>=5.7)
    if #available(iOS 16.0, *) {
      assert(self.collectionView.selfSizingInvalidation == .enabled)
    }
#endif
    
  }
  
  public convenience init(
    scrollDirection: UICollectionView.ScrollDirection,
    spacing: CGFloat = 0,
    contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .automatic
  ) {
    
    let layout: UICollectionViewCompositionalLayout

    switch scrollDirection {
    case .vertical:
      
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(100)
        ),
        subitems: [
          NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(100)
            )
          )
        ]
      )

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = spacing
      
      let configuration = UICollectionViewCompositionalLayoutConfiguration()
      configuration.scrollDirection = scrollDirection

      layout = UICollectionViewCompositionalLayout.init(section: section)
      
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

      layout = UICollectionViewCompositionalLayout.init(section: section, configuration: configuration)

    @unknown default:
      fatalError()
    }

    self.init(layout: layout, contentInsetAdjustmentBehavior: contentInsetAdjustmentBehavior)
    
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
  }

  public func setUp(
    cellProvider: CellProvider,
    didSelectItemAt: @escaping (Data) -> Void
  ) {

    _didSelectItemAt = didSelectItemAt
    _cellProvider = cellProvider
  }

  public func setContents(_ contents: [Data], animatedUpdating: Bool = true) {

    var newSnapshot = NSDiffableDataSourceSnapshot<Section, Data>.init()
    newSnapshot.appendSections([.main])
    newSnapshot.appendItems(contents, toSection: .main)

    dataSource.apply(newSnapshot, animatingDifferences: animatedUpdating)
        
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

@available(iOS 13, *)
extension DynamicContentListView {
  
  private final class InternalCollectionView: UICollectionView {
    
    override func layoutSubviews() {
      super.layoutSubviews()
    }
  }
  
}

public protocol DynamicContentListItemType {
  
  associatedtype Data: Hashable & Sendable

  @_spi(restore)
  func restore() -> DynamicContentListItem<Data>
  
}

public enum DynamicContentListItem<Data: Hashable & Sendable>: Hashable, Sendable, DynamicContentListItemType {
  case data(Data)
  case view(UIView)
  
  public func restore() -> DynamicContentListItem<Data> {
    self
  }
}

@available(iOS 13, *)
extension DynamicContentListView.CellProvider where Data : DynamicContentListItemType {
    
  public nonisolated static func `default`(cellForData: @escaping @MainActor (DynamicContentListView<Data.Data>.CellProviderContext) -> UICollectionViewCell) -> Self {
    .init { context in
      switch context.data.restore() {
      case .data(let data):
        return cellForData(.init(collectionView: context.collectionView, data: data, indexPath: context.indexPath))
      case .view(let view):
        let cell = context.dequeueViewContainer()
        cell.set(content: view)
        return cell
      }
    }
  }
}

public final class DynamicContentListViewContainerCell: UICollectionViewCell {
  
  private var _contentView: UIView?
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(content: UIView) {
    
    _contentView?.removeFromSuperview()
    
    contentView.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: contentView.topAnchor),
      content.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      content.leftAnchor.constraint(equalTo: contentView.leftAnchor),
    ])
    
    self._contentView = content
    
  }
  
}
