//
//  FavoriteScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FavouriteViewController: UIViewController {
    private let collection = FeedCollection()
    private let viewModel: FavoritesViewModel
    private let imageListService: ImageListService

    init(viewModel: FavoritesViewModel, imageListService: ImageListService) {
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
        collection.viewModel = self.viewModel
        collection.isReadOnlyMode = true
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
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            let count = self.viewModel.photosCount
            
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.collection.reloadData()
                    self.collection.collectionViewLayout.invalidateLayout()
                    self.collection.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collection.viewModel = self.viewModel
        self.collection.reloadData()
        self.collection.collectionViewLayout.invalidateLayout()
        self.collection.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.collection.collectionViewLayout.invalidateLayout()
            self.collection.layoutIfNeeded()
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

