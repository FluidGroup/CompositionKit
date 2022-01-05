import Foundation
import MondrianLayout
import UIKit

/*
#if canImport(StorybookKit)
import StorybookKit
import UIKit
@available(iOS 13, *)
enum DynamicContentListView_BookView {

  static var body: BookView {
    BookNavigationLink(title: "DynamicContentListView") {
      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {
        let v = DynamicContentListView<CellModel>()

        v.registerCell(MyCell.self)

        v.setUp(
          dynamicContent: .constant([.init(name: "1"), .init(name: "2"), .init(name: "3")]),
          cellForItemAt: { collectionView, data, indexPath in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MyCell.self)
            cell.attach(cellModel: data)
            return cell
          },
          didSelectItemAt: { item in

          }
        )

        return v
      }

      BookPreview(expandsWidth: true, maxHeight: 300, minHeight: 300) {
        let v = DynamicContentListView<CellModel>()

        v.registerCell(MyCell.self)

        v.setUp(
          dynamicContent: .constant((0..<100).map { .init(name: "\($0)") }),
          cellForItemAt: { collectionView, data, indexPath in
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MyCell.self)
            cell.attach(cellModel: data)
            return cell
          },
          didSelectItemAt: { item in

          }
        )

        return v
      }
    }
  }

  final class CellModel: StatefulObjectBase, StoreComponentType {

    struct State: Equatable {
      let name: String
      var text: String
    }

    let store: DefaultStore

    init(
      name: String
    ) {

      self.store = .init(initialState: .init(name: name, text: "Text"))

      super.init()
    }

    func updateText() {
      commit {
        $0.text = BookGenerator.loremIpsum(
          length: stride(from: 10, to: 100, by: 5).map { $0 }.randomElement()!
        )
      }
    }

  }

  final class MyCell: DynamicSizingCollectionViewCell, Reusable {

    let label = UILabel()
    let descriptionLabel = UILabel()
    let button = UIButton(type: .system)

    private var subscription: VergeAnyCancellable?
    private var currentCellModel: CellModel?
    private let disposeBag = DisposeBag()

    override init(
      frame: CGRect
    ) {
      super.init(frame: frame)

      backgroundColor = .init(white: 0, alpha: 0.1)
      label.numberOfLines = 0
      descriptionLabel.numberOfLines = 0

      button.setTitle("Update", for: .normal)

      contentView.mondrian.buildSubviews {
        VStackBlock(spacing: 8) {
          label
          descriptionLabel
          button
        }
        .padding(16)
        .background(
          UIView()&>.do {
            $0.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
            $0.layer.borderWidth = 4
          }
        )
      }

      button.rx.tap.bind { [unowned self] _ in
        currentCellModel?.updateText()
      }
      .disposed(by: disposeBag)

    }

    override func prepareForReuse() {
      super.prepareForReuse()

    }

    func attach(cellModel: CellModel) {

      currentCellModel = cellModel

      subscription?.cancel()
      subscription = cellModel.sinkState(scan: .counter()) { [weak self] state, count in

        guard let self = self else { return }

        state.ifChanged(\.name) { name in
          self.label.text = name
        }

        state.ifChanged(\.text) { text in
          self.descriptionLabel.text = text

          if count > 1 {
            self.layoutWithInvalidatingCollectionViewLayout(animated: true)
          }
        }

      }
    }

  }

  struct Item: Equatable, Differentiable {

    var differenceIdentifier: String {
      name
    }

    let name: String
  }

}
#endif
 */

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
          heightDimension: .estimated(0)
        ),
        subitems: [
          NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(0)
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

    Mondrian.buildSubviews(on: self) {
      ZStackBlock {
        collectionView.viewBlock.alignSelf(.attach(.all))
      }
    }

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

  }

  public func registerCell<Cell: UICollectionViewCell>(
    _ cellType: Cell.Type,
    forCellWithReuseIdentifier: String
  ) {
    collectionView.register(cellType, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
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
