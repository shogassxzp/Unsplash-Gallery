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
        view.addSubview(collection)
        
        collection.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
