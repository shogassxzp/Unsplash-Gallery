//
//  FeedCollection.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class FeedCollection: UICollectionView {
    
    private let photos: [String] = []
    private var selectedIndexPath: IndexPath?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 16
        
        super .init(frame: .zero, collectionViewLayout: layout)
        setupCollection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollection() {
        delegate = self
        dataSource = self
        register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.reuseIdentifier)
        allowsMultipleSelection = false
        translatesAutoresizingMaskIntoConstraints = false
    }
}
