//
//  FeedViewController.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FeedViewController: UIViewController {
    private let collection = FeedCollection()
    private let viewModel: FeedViewModel
    private let imageListService: ImageListService
    
    init(viewModel: FeedViewModel,imageListService: ImageListService) {
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
        setupNavigationBarTitle(text: "Feed", imageName: "house")
        viewModel.setupObserver()
        collection.viewModel = viewModel
        viewModel.fetchNextPage()

        collection.onPhotoTap = { [weak self] index in
            guard let self = self else { return }
            let detailsViewModel = DetailsViewModel(startIndex: index, mode: .feed, imageListService: imageListService)
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
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
