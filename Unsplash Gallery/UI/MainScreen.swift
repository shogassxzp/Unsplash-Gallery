//
//  MainScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class MainScreen: UIViewController {
    private let collection = FeedCollection()
    private var photos: [UIImage]

    init(photos: [UIImage]) {
        self.photos = photos
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Feed", imageName: "house")
        collection.configure(with: photos)
        collection.onPhotoTap = { [weak self] index in
            guard let self = self else { return }
            
            let selectedPhoto = self.photos[index]
            
            let detailsViewController = DetailsScreenViewController()
            detailsViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(detailsViewController, animated: true)
            
        }
    }

    private func setupUI() {
        view.addSubview(collection)
        view.backgroundColor = .backgroundAdaptive
        collection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
