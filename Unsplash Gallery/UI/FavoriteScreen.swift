//
//  FavoriteScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FavouriteViewController: UIViewController {
    private var favouritePhotos: [UIImage]
    private var collection = FeedCollection()
    init(favouritePhotos: [UIImage]) {
        self.favouritePhotos = favouritePhotos
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Favourite", imageName: "heart")
        collection.configure(with: favouritePhotos)
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
