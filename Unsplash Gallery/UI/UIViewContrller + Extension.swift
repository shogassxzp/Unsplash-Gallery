//
//  UIViewContrller + Extension.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 22.02.26.
//

import UIKit

extension UIViewController {
    func setupNavigationBarTitle(text: String, imageName: String) {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .blackAdaptive

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: imageName)
        iconView.tintColor = .blackAdaptive
        iconView.contentMode = .scaleAspectFit

        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
        ])

        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center

        navigationItem.titleView = stackView
    }
}
