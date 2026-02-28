//
//  MainScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class MainScreen: UIViewController {
    private let collection = FeedCollection()
    private let viewModel = FeedViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Feed", imageName: "house")
        viewModel.setupObserver()
        collection.viewModel = viewModel
        viewModel.fetchNextPage()
        
        collection.onPhotoTap = { [weak self] index in
            guard let self = self else { return }
            let detailsViewModel = DetailsViewModel(startIndex: index,mode: .feed)
            let detailsViewController = DetailsScreenViewController(viewModel: detailsViewModel)
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
