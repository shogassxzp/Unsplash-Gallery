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
    var shadowView = UIView()

    static let reuseIdentifier = "FeedCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        [shadowView, collectionImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.backgroundColor = .backgroundAdaptive

        shadowView.backgroundColor = .backgroundAdaptive
        shadowView.layer.shadowColor = UIColor.blackAdaptive.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 6
        shadowView.layer.cornerRadius = 16

        collectionImageView.image = UIImage(resource: .mock)
        collectionImageView.contentMode = .scaleAspectFill
        collectionImageView.clipsToBounds = true
        collectionImageView.layer.masksToBounds = true
        collectionImageView.layer.cornerRadius = 16

        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            collectionImageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            collectionImageView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            collectionImageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
        ])
    }
}
