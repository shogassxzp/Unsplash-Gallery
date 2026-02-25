//
//  FeedCollection.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

enum FeedMode {
    case feed
    case favourites
}

final class FeedCollection: UICollectionView {
    var mode: FeedMode = .feed
    private var photos: [UIImage] = []
    private var selectedIndexPath: IndexPath?
    var onPhotoTap: ((Int) -> Void)?
    var onDeletePhoto: ((Int) -> Void)?

    init() {
        let layout = UICollectionViewLayout.createLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollection()
        setupDoubleTap()
        setupLongPress()
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

    private func setupDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        addGestureRecognizer(doubleTap)

        if let singleTap = gestureRecognizers?.first(where: {
            String(describing: type(of: $0)).contains("Touch") || $0 is UITapGestureRecognizer
        }) {
            singleTap.require(toFail: doubleTap)
        }
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard mode == .feed, gesture.state == .began else { return }
        let point = gesture.location(in: self)

        if let indexPath = indexPathForItem(at: point),
           let cell = cellForItem(at: indexPath) as? FeedCell {
            cell.showLikeAnimation()

            print("Set like for \(indexPath.item)")
        }
    }

    private func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard mode == .favourites, gesture.state == .began else { return }
        let point = gesture.location(in: self)
        if let indexPath = indexPathForItem(at: point) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onDeletePhoto?(indexPath.item)
        }
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
