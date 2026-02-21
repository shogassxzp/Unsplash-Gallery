//
//  DetailsScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class DetailsScreenViewController: UIViewController {
   
    private lazy var detailsImageView: UIImageView = {
        let details = UIImageView()
        details.contentMode = .scaleAspectFill
        details.layer.cornerRadius = 24
        details.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        details.clipsToBounds = true
        details.image = .mock1
        return details
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "A vibrant top-down view of a variety of blooming Primroses (Primula). The deep green, textured foliage creates a stunning natural contrast against the multicolored petals in shade"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .blackAdaptive
        label.numberOfLines = 3
        return label
    }()

    private lazy var publishedLabel: UILabel = {
        let label = UILabel()
        label.text = "Published on February 18, 2026 (UTC)"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private lazy var shootedOnLabel: UILabel = {
        let label = UILabel()
        label.text = "FUJIFILM, X100VI"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .redUniversal
        button.tintColor = .whiteUniversal
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundAdaptive
        addSubviews()
        setupLayout()
    }

    private func addSubviews() {
        [detailsImageView, publishedLabel, descriptionLabel, shootedOnLabel, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            detailsImageView.topAnchor.constraint(equalTo: view.topAnchor),
            detailsImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailsImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),

            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: 40),
            descriptionLabel.bottomAnchor.constraint(equalTo: publishedLabel.topAnchor, constant: -12),

            likeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            likeButton.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 20),
            likeButton.widthAnchor.constraint(equalToConstant: 100),
            likeButton.heightAnchor.constraint(equalToConstant: 44),

            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: publishedLabel.topAnchor, constant: -20),

            publishedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            publishedLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            publishedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            shootedOnLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            shootedOnLabel.topAnchor.constraint(equalTo: publishedLabel.bottomAnchor, constant: 16),
            shootedOnLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}

