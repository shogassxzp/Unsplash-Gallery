//
//  MainScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class MainScreen: UIViewController {
    private let collection = FeedCollection()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Feed", imageName: "house")
        collection.onPhotoTap = { [weak self] index in
            guard let self = self else { return }
            
            let detailsViewController = DetailsScreenViewController()
            detailsViewController.startIndex = index
            detailsViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }

    private func setupUI() {
        view.addSubview(collection)
        view.backgroundColor = .backgroundAdaptive
        collection.mode = .feed
        collection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
