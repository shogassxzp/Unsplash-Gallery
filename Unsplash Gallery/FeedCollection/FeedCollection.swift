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
    private let imageListService = ImageListService.shared
    private var imageListObserver: NSObjectProtocol?
    private var selectedIndexPath: IndexPath?
    var onPhotoTap: ((Int) -> Void)?
    var onDeletePhoto: ((Int) -> Void)?

    init() {
        let layout = UICollectionViewLayout.createLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollection()
        setupDoubleTap()
        setupObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupObserver() {
        imageListObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            self?.updateCollectionViewAnimated()
        }
        imageListService.fetchPhotosNextPage()
    }

    private func updateCollectionViewAnimated() {
        reloadData()
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
        guard mode == .feed, gesture.state == .ended else { return }
        let point = gesture.location(in: self)

        if let indexPath = indexPathForItem(at: point),
           let cell = cellForItem(at: indexPath) as? FeedCell {
            cell.showLikeAnimation()

            print("Set like for \(indexPath.item)")
        }
    }
}

extension FeedCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mode == .feed ? imageListService.photos.count : imageListService.likedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
        if indexPath.row < imageListService.photos.count {
            let photo = mode == .feed ? imageListService.photos[indexPath.row] : imageListService.likedPhotos[indexPath.row]
            cell.configure(with: photo.urls.small)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPhotoTap?(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard mode == .favourites else { return nil }
        guard let indexPath = indexPaths.first else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: "Delete from favourite",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.onDeletePhoto?(indexPath.item)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}
