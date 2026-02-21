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
        self.photos = [.mock, .mock1, .mock2]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collection)
        view.backgroundColor = .backgroundAdaptive
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.configure(with: self.photos)

        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
