//
//  ViewController.swift
//  collectionViewMemoryTest
//
//  Created by Inter Ferenc on 01/07/2026.
//

import UIKit

nonisolated private enum Section: Hashable, Sendable {
    case main
}

nonisolated private struct Item: Hashable, Sendable {
    let id = UUID()
    let title: String
}

final class ViewController: UICollectionViewController {

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private var dataSource: DataSource!

    init() {
        super.init(collectionViewLayout: Self.makeLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsSelectionDuringEditing = true
        collectionView.allowsMultipleSelectionDuringEditing = true

        title = "20k Items"
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsMultipleSelection = false

        configureDataSource()
        applyInitialSnapshot()
        updateToolbarItems()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if !editing {
            collectionView.indexPathsForSelectedItems?.forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }
        }
        updateToolbarItems()
    }

    private static func makeLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.multiselect()]
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func applyInitialSnapshot() {
        let items = (1...20_000).map { index in
            Item(title: "Item \(index) - \(Int.random(in: 100_000...999_999))")
        }

        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateToolbarItems() {
        if isEditing {
            toolbarItems = [
                UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllItems)),
                UIBarButtonItem(systemItem: .flexibleSpace),
                UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(disableEditing))
            ]
        } else {
            toolbarItems = [
                UIBarButtonItem(systemItem: .flexibleSpace),
                UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(enableEditing))
            ]
        }
    }

    @objc private func enableEditing() {
        setEditing(true, animated: true)
    }

    @objc private func disableEditing() {
        setEditing(false, animated: true)
    }

    @objc private func selectAllItems() {
        dataSource.snapshot().itemIdentifiers.forEach { item in
            guard let indexPath = dataSource.indexPath(for: item) else { return }
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}
