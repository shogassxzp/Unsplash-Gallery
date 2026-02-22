//
//  DetailsScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class DetailsScreenViewController: UIViewController {
    private var currentIndex: Int = 0
    private var photos: [UIImage] = [.mock, .mock1, .mock2]

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
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .blackAdaptive
        label.numberOfLines = 3
        return label
    }()

    private lazy var publishedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .blackAdaptive
        return label
    }()

    private lazy var shootedOnLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .blackAdaptive
        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()

        config.image = UIImage(systemName: "heart")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        config.baseBackgroundColor = .clear
        config.background.backgroundColor = .clear

        button.configuration = config
        button.tintColor = .redUniversal
        button.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        return button
    }()

    //MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundAdaptive
        addSubviews()
        setupLayout()
        setupGesture()
        updateUI()
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

            likeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            likeButton.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 16),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
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

    private func setupGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        swipeLeft.delegate = self
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        swipeRight.delegate = self
        view.addGestureRecognizer(swipeRight)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if currentIndex < photos.count - 1 {
                currentIndex += 1
                animateTransition(isNext: true)
            }
        } else if gesture.direction == .right {
            if currentIndex > 0 {
                currentIndex -= 1
                animateTransition(isNext: false)
            }
        }
    }

    private func animateTransition(isNext: Bool) {
        let tempImageView = UIImageView(frame: detailsImageView.frame)
        tempImageView.contentMode = detailsImageView.contentMode
        tempImageView.image = detailsImageView.image
        tempImageView.clipsToBounds = detailsImageView.clipsToBounds
        tempImageView.layer.cornerRadius = detailsImageView.layer.cornerRadius
        tempImageView.layer.maskedCorners = detailsImageView.layer.maskedCorners
        view.addSubview(tempImageView)

        updateUI()

        let translationX = isNext ? view.bounds.width : -view.bounds.width

        detailsImageView.transform = CGAffineTransform(translationX: translationX, y: 0)

        UIView.animate(withDuration: 0.4, delay: .zero, options: .curveEaseInOut, animations: {
            tempImageView.transform = CGAffineTransform(translationX: -translationX, y: 0)
            tempImageView.alpha = 0

            self.detailsImageView.transform = .identity
            self.descriptionLabel.alpha = 0
            self.publishedLabel.alpha = 0
            self.shootedOnLabel.alpha = 0
            
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.descriptionLabel.alpha = 1.0
                self.publishedLabel.alpha = 1.0
                self.shootedOnLabel.alpha = 1.0
            }
            tempImageView.removeFromSuperview()
        }
    }

    private func updateUI() {
        detailsImageView.image = photos[currentIndex]
        descriptionLabel.text = "That photo number \(currentIndex). Take description from API"
        publishedLabel.text = "Take date from API"
        shootedOnLabel.text = "Take camera name from API"
    }

    @objc private func heartTapped() {
        likeButton.isSelected.toggle()

        let imageName = likeButton.isSelected ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)

        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        }
    }
}

extension DetailsScreenViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
