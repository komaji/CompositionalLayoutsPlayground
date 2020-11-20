//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class LabelCell: UICollectionViewCell {
    static let name = String(describing: self)
    
    lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .blue
        
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(text: String) {
        label.text = text
    }
    
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = .green
        label.numberOfLines = 0
        return label
    }
}

class BackgroundColorView: UICollectionReusableView {
    static let name = String(describing: self)
    static let kind = name
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .yellow
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }
}

class MyViewController : UIViewController {
    struct Item: Hashable {
        let id = UUID()
        let value: String = (1...((1...100).randomElement() ?? 1))
            .map(String.init)
            .joined(separator: ",")
    }
    typealias Section = Int
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    let items: [Item] = (0..<5).map { _ in .init() }
    
    lazy var collectionView = makeCollectionView()
    lazy var dataSource = DataSource(
        collectionView: collectionView,
        cellProvider: makeCellProvider()
    )
    
    override func loadView() {
        self.view = collectionView
        apply()
    }
    
    func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeLayout()
        )
        collectionView.backgroundColor = .white
        collectionView.register(
            LabelCell.self,
            forCellWithReuseIdentifier: LabelCell.name
        )
        return collectionView
    }

    // MARK: - Diffable Data Sources
    func makeCellProvider() -> DataSource.CellProvider {
        return { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LabelCell.name,
                for: indexPath
            )
            (cell as? LabelCell)?.update(text: item.value)
            return cell
        }
    }
    
    func apply() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    // MARK: - Compositional Layouts
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(section: makeLayoutSection_example2_1())
        layout.register(
            BackgroundColorView.self,
            forDecorationViewOfKind: BackgroundColorView.kind
        )
        return layout
    }
    
    /// はまりどころ１: itemSize と groupSize を .estimated にする必要がある
    func makeLayoutSection_note1() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .fractionalHeight(1.0) // 🙅‍♀️
            heightDimension: .estimated(100.0) // 🙆‍♀️
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let itemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: itemGroup)
        section.contentInsets = .init(
            top: 16.0,
            leading: 16.0,
            bottom: 16.0,
            trailing: 16.0
        )
        section.interGroupSpacing = 8.0
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }
    
    /// はまりどころ２: グループを UICollectionView のスクロール方向と同じ方向で count を指定して作ると Self-Sizing されない
    func makeLayoutSection_note2() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
//        let itemGroup = NSCollectionLayoutGroup.vertical( // 🙅‍♀️
        let itemGroup = NSCollectionLayoutGroup.horizontal( // 🙆‍♀️その１
            layoutSize: itemGroupSize,
            subitem: item,
            count: 1
        )
//        let itemGroup = NSCollectionLayoutGroup.vertical( // 🙆‍♀️その２
//            layoutSize: itemGroupSize,
//            subitems: [item],
//        )
        
        let section = NSCollectionLayoutSection(group: itemGroup)
        section.contentInsets = .init(
            top: 16.0,
            leading: 16.0,
            bottom: 16.0,
            trailing: 16.0
        )
        section.interGroupSpacing = 8.0
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }
    
    /// はまりどころ３: レイアウトアイテムの Self-Sizing 方向の contentInsets が効かず、垂直方向の contentInsets が設定通りに反映されない
    func makeLayoutSection_note3() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(
            top: 16.0, // 設定しても効かない
            leading: 16.0, // 設定すると leading, trailing の両方に反映される
            bottom: 16.0, // 設定しても効かない
            trailing: 16.0 // 設定すると 値 * 2 が trailing に反映される
        )
        
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let itemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: itemGroup)
        section.interGroupSpacing = 8.0
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }
    
    /// はまりどころ４: グループの Self-Sizing 方向の contentInsets が効かない
    func makeLayoutSection_note4() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let itemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 1
        )
        itemGroup.contentInsets = .init(
            top: 16.0, // 設定しても効かない
            leading: 16.0, // 設定通りに反映される
            bottom: 16.0, // 設定しても効かない
            trailing: 16.0 // 設定通りに反映される
        )
        
        let section = NSCollectionLayoutSection(group: itemGroup)
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }

    /// レイアウト例１: 縦方向にスクロールする UICollectionView で同じ item を縦に複数並べる
    func makeLayoutSection_example1() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let itemGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: itemGroupSize,
            subitems: [item]
        )
        itemGroup.contentInsets = .init(
            top: .zero,
            leading: 16.0,
            bottom: .zero,
            trailing: 16.0
        )

        let section = NSCollectionLayoutSection(group: itemGroup)
        section.contentInsets = .init(
            top: 16.0,
            leading: .zero,
            bottom: 16.0,
            trailing: .zero
        )
        section.interGroupSpacing = 8.0
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }
    
    /// レイアウト例２: 縦方向にスクロールする UICollectionView で異なるレイアウトアイテムを縦に複数並べて Self-Sizing させる
    func makeLayoutSection_example2_1() -> NSCollectionLayoutSection {
        let interItemSpacing: NSCollectionLayoutSpacing = .fixed(8.0)

        // MARK: - Large Item
        let largeItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
        
        let largeItemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300.0)
        )
        let largeItemGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: largeItemGroupSize,
            subitems: [largeItem, largeItem, largeItem]
        )
        largeItemGroup.contentInsets = .init(
            top: .zero,
            leading: 16.0,
            bottom: .zero,
            trailing: 16.0
        )
        largeItemGroup.interItemSpacing = interItemSpacing
        
        // MARK: - Small Item
        let smallItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
        
        let smallItemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let smallItemGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: smallItemGroupSize,
            subitems: [smallItem, smallItem]
        )
        smallItemGroup.contentInsets = .init(
            top: .zero,
            leading: 48.0,
            bottom: .zero,
            trailing: 48.0
        )
        smallItemGroup.interItemSpacing = interItemSpacing
        
        // MARK: - All
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500.0)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [
                largeItemGroup,
                smallItemGroup
            ]
        )
        group.interItemSpacing = interItemSpacing
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: 16.0,
            leading: .zero,
            bottom: 16.0,
            trailing: .zero
        )
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }
    
    /// レイアウト例２: 縦方向にスクロールする UICollectionView で異なるレイアウトアイテムを縦に複数並べて Self-Sizing させる
    func makeLayoutSection_example2_2() -> NSCollectionLayoutSection {
        // MARK: - Large Item
        let largeItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
        
        let largeItemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let largeItemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: largeItemGroupSize,
            subitem: largeItem,
            count: 1
        )
        largeItemGroup.contentInsets = .init(
            top: .zero,
            leading: 16.0,
            bottom: .zero,
            trailing: 16.0
        )
        
        // MARK: - Small Item
        let smallItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
        
        let smallItemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0)
        )
        let smallItemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: smallItemGroupSize,
            subitem: smallItem,
            count: 1
        )
        smallItemGroup.contentInsets = .init(
            top: .zero,
            leading: 48.0,
            bottom: .zero,
            trailing: 48.0
        )
        
        // MARK: - All
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500.0)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [
                largeItemGroup, largeItemGroup, largeItemGroup,
                smallItemGroup, smallItemGroup
            ]
        )
        group.interItemSpacing = .fixed(8.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: 16.0,
            leading: .zero,
            bottom: 16.0,
            trailing: .zero
        )
        section.decorationItems = [makeBackgroundColorDecorationItem()]
        return section
    }
    
    func makeBackgroundColorDecorationItem() -> NSCollectionLayoutDecorationItem {
        .background(elementKind: BackgroundColorView.kind)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

