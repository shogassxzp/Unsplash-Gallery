//
//  FavoriteScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FavouriteViewController: UIViewController {
    private let collection = FeedCollection()
    private let viewModel = FeedViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Favourite", imageName: "heart")
        viewModel.mode = .favourites
        viewModel.setupObserver()
        ImageListService.shared.fethcLikedPhotosNextPage()

        collection.viewModel = viewModel

        collection.onPhotoTap = { [weak self] index in
            guard let self = self else { return }
            let detailsViewModel = DetailsViewModel(startIndex: index, mode: .favourites)
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
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
