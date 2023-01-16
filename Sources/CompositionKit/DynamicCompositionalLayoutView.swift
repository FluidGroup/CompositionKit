import Foundation
import MondrianLayout
import UIKit

@available(iOS 13, *)
@available(*, deprecated, renamed: "DynamicCompositionalLayoutView")
public typealias DynamicContentListView<Section: Hashable, Data: Hashable> =
  DynamicCompositionalLayoutView<Section, Data>

/// Preimplemented list view using UICollectionView and UICollectionViewCompositionalLayout.
/// - Supports dynamic content update
/// - Self cell sizing
/// - Update sizing using ``DynamicSizingCollectionViewCell``.
///
/// - TODO: Currently supported only vertical scrolling.
@available(iOS 13, *)
open class DynamicCompositionalLayoutView<Section: Hashable, Data: Hashable>: CodeBasedView,
  UICollectionViewDelegate
{

  @MainActor
  fileprivate final class ContentPool {

    private var contents: [Data: UIView] = [:]

    func set(content: UIView, for data: Data) {
      #if DEBUG
      if contents[data] != nil {
        Log.error(.dynamicCompositionalLayoutView, "Content has been already created")
      }
      #endif
      contents[data] = content
    }

    func get(for data: Data) -> UIView? {
      contents[data]
    }

    func sweep(items: [Data]) {

      let unusedKeys = Set(contents.keys).subtracting(items)

      for key in unusedKeys {
        contents.removeValue(forKey: key)
      }

      #if DEBUG

      let hasUnmountedView = contents.values.contains(where: { $0.superview == nil })
      if hasUnmountedView {
        Log.error(.dynamicCompositionalLayoutView, "There are views that are not displayed")
      }

      #endif
    }

  }

  @MainActor
  public struct CellProviderContext {

    public unowned let collectionView: UICollectionView
    public let data: Data
    public let indexPath: IndexPath

    fileprivate let contentPool: ContentPool

    func dequeueViewContainer() -> DynamicContentListViewContainerCell {
      print(indexPath)
      return dequeueReusableCell(DynamicContentListViewContainerCell.self)
    }

    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellType: Cell.Type) -> Cell {
      return collectionView.dequeueReusableCell(
        withReuseIdentifier: _typeName(Cell.self),
        for: indexPath
      ) as! Cell
    }

    /**
     Returns a cell that displays given content isolated from recycling system of collection view.
     */
    public func containerCell(content: UIView) -> UICollectionViewCell {
      let cell = dequeueViewContainer()
      cell.set(content: content)
      return cell
    }

    /**
     Returns a cell that displays a created content from given block isolated from recycling system of collection view.
     That created view will be retained. Next time cell provider closure would not be called.
     */
    public func containerCell(contentBlock: () -> UIView) -> UICollectionViewCell {

      let cell = dequeueViewContainer()
      let contentView = contentBlock()
      contentPool.set(content: contentView, for: data)
      cell.set(content: contentView)
      return cell
    }
  }

  @MainActor
  public struct CellProvider {

    private var thunk: @MainActor (CellProviderContext) -> UICollectionViewCell

    public nonisolated init(
      _ thunk: @escaping @MainActor (CellProviderContext) -> UICollectionViewCell
    ) {
      self.thunk = thunk
    }

    func cell(for context: CellProviderContext) -> UICollectionViewCell {

      if let content = context.contentPool.get(for: context.data) {
        return context.containerCell(content: content)
      }

      return thunk(context)
    }

  }
  
  public enum Action {
    case didSelect(Data)
    case batchFetch((@escaping @MainActor () async -> Void) -> ())
  }

  @available(iOS 14, *)
  public typealias CellRegistration<Cell: UICollectionViewCell> = UICollectionView.CellRegistration<
    Cell, Data
  >

  public var scrollView: UIScrollView {
    collectionView
  }

  public let collectionView: UICollectionView

  public var layout: UICollectionViewCompositionalLayout {
    collectionView.collectionViewLayout as! UICollectionViewCompositionalLayout
  }

  private var _cellProvider: CellProvider?
  
  private var _actionHandler: @MainActor (Action) -> Void = { _ in }

  private var dataSource: UICollectionViewDiffableDataSource<Section, Data>!

  private let contentPool = ContentPool()

  private let contentPagingTrigger: ContentPagingTrigger

  public init(
    layout: UICollectionViewCompositionalLayout,
    contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .automatic
  ) {

    self.collectionView = .init(frame: .null, collectionViewLayout: layout)
    self.contentPagingTrigger = .init(
      scrollView: collectionView,
      trackingScrollDirection: {
        switch layout.configuration.scrollDirection {
        case .vertical:
          return .down
        case .horizontal:
          return .right
        @unknown default:
          return .down
        }
      }(),
      leadingScreensForBatching: 1
    )

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

        let context = CellProviderContext.init(
          collectionView: collectionView,
          data: data,
          indexPath: indexPath,
          contentPool: contentPool
        )

        return provider.cell(
          for: context
        )

      }
    )

    self.dataSource = dataSource

    self.collectionView.delegate = self
    self.collectionView.dataSource = dataSource
    self.collectionView.delaysContentTouches = false
    self.collectionView.isPrefetchingEnabled = false
    self.collectionView.prefetchDataSource = nil

    collectionView.register(
      DynamicContentListViewContainerCell.self,
      forCellWithReuseIdentifier: _typeName(DynamicContentListViewContainerCell.self)
    )
    
    contentPagingTrigger.onBatchFetch = { [weak self] in

      await withCheckedContinuation { c in
        self?._actionHandler(.batchFetch({ task in
          Task {
            await task()
            c.resume()
          }
        }))
      }
      
    }

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

      layout = UICollectionViewCompositionalLayout.init(
        section: section,
        configuration: configuration
      )

    @unknown default:
      fatalError()
    }

    self.init(layout: layout, contentInsetAdjustmentBehavior: contentInsetAdjustmentBehavior)

  }

  public func registerCell<Cell: UICollectionViewCell>(
    _ cellType: Cell.Type
  ) {
    collectionView.register(
      cellType,
      forCellWithReuseIdentifier: _typeName(Cell.self)
    )
  }

  public func setUp(
    cellProvider: CellProvider,
    actionHandler: @escaping @MainActor (Action) -> Void
  ) {

    _actionHandler = actionHandler
    _cellProvider = cellProvider
  }

  public func setContents(
    snapshot: NSDiffableDataSourceSnapshot<Section, Data>,
    animatedUpdating: Bool = true
  ) {

    dataSource.apply(snapshot, animatingDifferences: animatedUpdating)

    if #available(iOS 15, *) {

    } else if #available(iOS 14, *) {
      // iOS 14

      // sometimes cell's content will be gone.
      collectionView.reloadData()
    } else {
      // workaround: iOS13 sometimes fails to update layout
      Task { @MainActor in
        collectionView.layoutIfNeeded()
      }
    }

    contentPool.sweep(items: snapshot.itemIdentifiers)

  }

  /**
   Displays cells with given contents.
   CollectionView will update its cells partially using DiffableDataSources.
   */
  public func setContents(_ contents: [Data], animatedUpdating: Bool = true)
  where Section == DynamicCompositionalLayoutSingleSection {

    var newSnapshot = NSDiffableDataSourceSnapshot<Section, Data>.init()
    newSnapshot.appendSections([.main])
    newSnapshot.appendItems(contents, toSection: .main)

    setContents(snapshot: newSnapshot, animatedUpdating: animatedUpdating)

  }
  
  public func snapshot() -> NSDiffableDataSourceSnapshot<Section, Data> {
    dataSource.snapshot()
  }

  public func setContents(
    _ contents: [Data],
    inSection section: Section,
    animatedUpdating: Bool = true
  ) {

    var snapshot = dataSource.snapshot()

    snapshot.deleteSections([section])
    snapshot.appendSections([section])
    snapshot.appendItems(contents, toSection: section)

    setContents(snapshot: snapshot, animatedUpdating: animatedUpdating)

  }

  public func setContentInset(_ insets: UIEdgeInsets) {
    collectionView.contentInset = insets
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let item = dataSource.itemIdentifier(for: indexPath)!
    _actionHandler(.didSelect(item))
  }

}

@available(iOS 13, *)
public typealias DynamicCompositionalLayoutSingleSectionView<Data: Hashable> =
  DynamicCompositionalLayoutView<DynamicCompositionalLayoutSingleSection, Data>

public enum DynamicCompositionalLayoutSingleSection: Hashable {
  case main
}

@available(iOS 13, *)
extension DynamicCompositionalLayoutView {

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

public enum DynamicContentListItem<Data: Hashable & Sendable>: Hashable, Sendable,
  DynamicContentListItemType
{
  case data(Data)
  case view(UIView)

  public func restore() -> DynamicContentListItem<Data> {
    self
  }
}

public final class DynamicContentListViewContainerCell: UICollectionViewCell {

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func set(content: UIView) {

    if content.superview == contentView {
      // already in display
      return
    }

    contentView.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: contentView.topAnchor),
      content.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      content.leftAnchor.constraint(equalTo: contentView.leftAnchor),
    ])

  }

  public override func prepareForReuse() {
    super.prepareForReuse()

    for subview in contentView.subviews {
      subview.removeFromSuperview()
    }

  }

}

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
