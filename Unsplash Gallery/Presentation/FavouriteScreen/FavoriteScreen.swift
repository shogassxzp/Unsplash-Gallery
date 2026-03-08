//
//  FavoriteScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FavouriteViewController: UIViewController {
    
    // MARK: - UI Elements
    private let collection = FeedCollection()
    private let viewModel: FavoritesViewModel
    private let imageListService: ImageListService

    private lazy var emptyStateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.isHidden = true

        let imageView = UIImageView(image: UIImage(resource: .favEmpty))
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = "You haven't liked any photos yet"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackAdaptive

        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(label)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init
    init(viewModel: FavoritesViewModel, imageListService: ImageListService) {
        self.viewModel = viewModel
        self.imageListService = imageListService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarTitle(text: "Favourite", imageName: "heart")
        
        collection.viewModel = self.viewModel
        collection.isReadOnlyMode = true
        
        setupBindings()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIState()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateUIState()
            }
        }
    }

    private func updateUIState() {
            let isEmpty = viewModel.photosCount == 0
            emptyStateStack.isHidden = !isEmpty
            collection.isHidden = isEmpty
        }

    private func setupUI() {
        view.backgroundColor = .backgroundAdaptive
        
        view.addSubview(collection)
        view.addSubview(emptyStateStack)
        
        collection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}
