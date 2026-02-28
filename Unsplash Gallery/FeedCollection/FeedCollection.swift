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
    var viewModel: FeedViewModel? {
        didSet {
            bindViewModel()
        }
    }

    private var imageListObserver: NSObjectProtocol?
    private var selectedIndexPath: IndexPath?
    var onPhotoTap: ((Int) -> Void)?
    var onDeletePhoto: ((Int) -> Void)?

    init() {
        let layout = UICollectionViewLayout.createLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollection()
        setupDoubleTap()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindViewModel() {
        viewModel?.onDataUpdated = { [weak self] in
            self?.reloadData()
        }
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
        guard let viewModel = viewModel, viewModel.mode == .feed, gesture.state == .ended else { return }
        
        let point = gesture.location(in: self)

        if let indexPath = indexPathForItem(at: point) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()

            if let cell = cellForItem(at: indexPath) as? FeedCell {
                cell.showLikeAnimation()
                
                viewModel.toggleLike(at: indexPath.item) { success in
                    if success {
                        print("Successfully updated like via ViewModel")
                    } else {
                        print("Failed to change like")
                    }
                }
            }
        }
    }
}

extension FeedCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.photosCount ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if indexPath.row + 1 == viewModel?.photosCount {
                viewModel?.fetchNextPage()
            }
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: FeedCell.reuseIdentifier, for: indexPath) as! FeedCell
        if let photo = viewModel?.photo(at: indexPath.item) {
            cell.configure(with: photo.urls.small)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPhotoTap?(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let viewModel = viewModel, viewModel.mode == .favourites else { return nil }
        guard let indexPath = indexPaths.first else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: "Delete from favourite",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in

                self?.viewModel?.toggleLike(at: indexPath.item) { success in
                    if success {
                        print("Photo removed from favourites")
                    }
                }
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}
