//
//  FeedCell.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import Kingfisher
import UIKit

final class FeedCell: UICollectionViewCell {
    private let likeHeartView: UIImageView = {
        let likeView = UIImageView()
        likeView.image = UIImage(systemName: "heart.fill")
        likeView.tintColor = .redUniversal
        likeView.contentMode = .scaleAspectFit
        likeView.alpha = 0
        likeView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        likeView.translatesAutoresizingMaskIntoConstraints = false
        return likeView
    }()

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionImageView.kf.cancelDownloadTask()
        collectionImageView.image = nil
    }

    private func setupCell() {
        [shadowView, collectionImageView, likeHeartView].forEach {
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
        collectionImageView.backgroundColor = .blackAdaptive
        collectionImageView.tintColor = .backgroundAdaptive

        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            collectionImageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            collectionImageView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            collectionImageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),

            likeHeartView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            likeHeartView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            likeHeartView.widthAnchor.constraint(equalToConstant: 80),
            likeHeartView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    func showLikeAnimation() {
        likeHeartView.alpha = 0
        likeHeartView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.likeHeartView.alpha = 1
            self.likeHeartView.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.likeHeartView.alpha = 0
                self.likeHeartView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
    }
}

extension FeedCell {
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        collectionImageView.kf.indicatorType = .activity
        collectionImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .imagePlaceholder),
            options: [
                .transition(.fade(0.25)),
                .cacheSerializer(FormatIndicatedCacheSerializer.jpeg)
            ]
        )
    }
}
