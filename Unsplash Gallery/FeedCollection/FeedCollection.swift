//
//  FeedCollection.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FeedCollection: UICollectionView {
    private var photos: [UIImage] = []
    private var selectedIndexPath: IndexPath?
    var onPhotoTap: ((Int) -> Void)?

    init() {
        let layout = UICollectionViewLayout.createLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollection() {
        backgroundColor = .backgroundAdaptive
        delegate = self
        dataSource = self
        register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.reuseIdentifier)
        allowsMultipleSelection = false
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
    }

    func configure(with photos: [UIImage]) {
        self.photos = photos
        reloadData()
    }
}

extension FeedCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
        cell.collectionImageView.image = photos[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPhotoTap?(indexPath.item)
    }
}
