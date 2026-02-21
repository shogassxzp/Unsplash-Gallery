//
//  FeedCell.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit
// TODO: - Double tap recognizer
final class FeedCell: UICollectionViewCell {
    private var imageId: String?
    var collectionImageView = UIImageView()
    var imageBackgound = UIView()

    static let reuseIdentifier = "FeedCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(collectionImageView)
        backgroundColor = .clear
        contentView.backgroundColor = .whiteAdaptive
        collectionImageView.image = UIImage(resource: .mock)
        collectionImageView.contentMode = .scaleAspectFill
        collectionImageView.clipsToBounds = true
        collectionImageView.layer.masksToBounds = true
        collectionImageView.layer.cornerRadius = 16
        collectionImageView.backgroundColor = .blackUniversal.withAlphaComponent(0.3)
        collectionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
