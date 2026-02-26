//
//  FavoriteScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FavouriteViewController: UIViewController {
    private var collection = FeedCollection()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ImageListService.shared.resetLikedPhotos()
        collection.reloadData()
        ImageListService.shared.fethcLikedPhotosNextPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Favourite", imageName: "heart")
    }

    private func setupUI() {
        view.backgroundColor = .backgroundAdaptive
        collection.mode = .favourites
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
