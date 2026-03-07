//
//  FavoriteScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FavouriteViewController: UIViewController {
    private let collection = FeedCollection()
    private let viewModel: FeedViewModel
    private let imageListService: ImageListService

    init(viewModel: FeedViewModel, imageListService: ImageListService) {
        self.viewModel = viewModel
        self.imageListService = imageListService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Favourite", imageName: "heart")
        
        viewModel.mode = .favourites
        collection.viewModel = viewModel
        viewModel.setupObserver()

        imageListService.resetLikedPhotos()
        imageListService.fetchLikedPhotosNextPage()

        collection.onPhotoTap = { [weak self] index in
            guard let self = self else { return }
            let detailsViewModel = DetailsViewModel(
                startIndex: index,
                mode: .favourites,
                imageListService: self.imageListService
            )
            let detailsViewController = DetailsScreenViewController(viewModel: detailsViewModel)
            self.navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }

    private func setupUI() {
        view.backgroundColor = .backgroundAdaptive
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
