//
//  ViewController.swift
//  CollectionViewTransitionTest
//
//  Created by Eugen Waldschmidt on 27.02.18.
//  Copyright © 2018 Eugen Waldschmidt. All rights reserved.
//

import UIKit

class SquaresViewController: UICollectionViewController {
    var items = [Item]()
    let reuseableIdentifier = "Test"
    let layout: CollectionViewFlowLayout
    init(collectionViewLayout layout: CollectionViewFlowLayout) {
        self.layout = layout
        super.init(collectionViewLayout: layout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Test")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        return 50
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseableIdentifier, for: indexPath)

        cell.backgroundColor = items[indexPath.section * 50 + indexPath.item].color

        if indexPath.section == 8 {
            cell.backgroundColor = .green
        }

        return cell
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layout.lastSize?.width != view.bounds.size.width {
            layout.update(for: view.bounds.size, safeAreaInsets: view.safeAreaInsetsIfAvailable)
        }
    }
}

struct Item {
    var color: UIColor
}

class SmallViewController: SquaresViewController {
    init() {
        let layout = CollectionViewFlowLayout(itemSize: .small)
        super.init(collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        items = (0...500).map { _ in Item(color: .black) }
        useLayoutToLayoutNavigationTransitions = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mediumVC = MediumViewController()
        navigationController?.pushViewController(mediumVC, animated: true)
        mediumVC.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

class MediumViewController: SquaresViewController {
    init() {
        let layout = CollectionViewFlowLayout(itemSize: .medium)
        super.init(collectionViewLayout: layout)
        useLayoutToLayoutNavigationTransitions = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bigVC = BigViewController()
        navigationController?.pushViewController(bigVC, animated: true)
        bigVC.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

class BigViewController: SquaresViewController {
    init() {
        let layout = CollectionViewFlowLayout(itemSize: .big)
        super.init(collectionViewLayout: layout)
        useLayoutToLayoutNavigationTransitions = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    let itemSizeAvarage: CGFloat
    init(itemSize: ItemSize) {
        itemSizeAvarage = itemSize.itemSize
        super.init()
        minimumInteritemSpacing = 2
        minimumLineSpacing = 2
        sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
    }

    var lastSize: CGSize?

    func update(for size: CGSize, safeAreaInsets: UIEdgeInsets) {
        let numberOfColumns = max(3, ceil(size.width / itemSizeAvarage))
        let inset = safeAreaInsets.left + safeAreaInsets.right

        let availableWidth = size.width - ((numberOfColumns - 1) * 2) - inset
        let itemWidth = availableWidth / numberOfColumns
        let newItemSize = CGSize(width: itemWidth, height: itemWidth)

        if itemSize != newItemSize {
            itemSize = newItemSize
            invalidateLayout()
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if lastSize != newBounds.size {
            let insets = collectionView?.safeAreaInsetsIfAvailable ?? .zero
            update(for: newBounds.size, safeAreaInsets: insets)
            lastSize = newBounds.size
        }
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    var safeAreaInsetsIfAvailable: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }
}

enum ItemSize {
    case small, medium, big

    var itemSize: CGFloat {
        switch self {
        case .small:
            return 35
        case .medium:
            return 70
        case .big:
            return 140
        }
    }
}
