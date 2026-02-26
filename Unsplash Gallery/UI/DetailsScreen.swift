//
//  DetailsScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import Kingfisher
import UIKit

final class DetailsScreenViewController: UIViewController {
    var startIndex: Int = 0
    private var currentIndex: Int = 0
    private let imageListService = ImageListService.shared

    private lazy var detailsImageView: UIImageView = {
        let details = UIImageView()
        details.contentMode = .scaleAspectFill
        details.layer.cornerRadius = 24
        details.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        details.clipsToBounds = true
        details.kf.indicatorType = .activity
        details.backgroundColor = .blackAdaptive
        details.tintColor = .backgroundAdaptive
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

    private lazy var authorNameLabel: UILabel = {
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
        config.baseForegroundColor = .redUniversal
        config.background.backgroundColor = .clear

        button.configuration = config
        button.tintColor = .redUniversal
        button.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - ViewDidAppear

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.isEnabled = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.isEnabled = true
        }
    }

    // MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundAdaptive
        currentIndex = startIndex
        addSubviews()
        setupLayout()
        setupGesture()
        updateUI()
    }

    private func addSubviews() {
        [detailsImageView, publishedLabel, descriptionLabel, authorNameLabel, likeButton].forEach {
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

            authorNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authorNameLabel.topAnchor.constraint(equalTo: publishedLabel.bottomAnchor, constant: 16),
            authorNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func setupGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if currentIndex < imageListService.photos.count - 1 {
                currentIndex += 1
                animateTransition(isNext: true)
            } else {
                imageListService.fetchPhotosNextPage()
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
            self.authorNameLabel.alpha = 0

        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.descriptionLabel.alpha = 1.0
                self.publishedLabel.alpha = 1.0
                self.authorNameLabel.alpha = 1.0
            }
            tempImageView.removeFromSuperview()
        }
    }

    private func updateUI() {
        guard currentIndex < imageListService.photos.count else { return }
        let photos = imageListService.photos[currentIndex]

        detailsImageView.kf.setImage(with: URL(string: photos.urls.full), placeholder: UIImage(resource: .imagePlaceholder))
        descriptionLabel.text = photos.description ?? "No description"
        authorNameLabel.text = "username username"
        
        if let formattedDate = photos.createdAt?.toReadableDate() {
            publishedLabel.text = "Published at: \(formattedDate)"
        } else {
            publishedLabel.text = "Publication date unknown"
        }
       
        let imageName = photos.likedByUser ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)
    }

    @objc private func heartTapped() {
        let photo = imageListService.photos[currentIndex]
        let newLikeState = !photo.likedByUser

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        updateLikeStatusUI(isLiked: newLikeState)

        imageListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            if case .failure = result {
                self?.updateLikeStatusUI(isLiked: photo.likedByUser)
            }
        }
    }

    private func updateLikeStatusUI(isLiked: Bool) {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)

        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        }
    }

    private func updateLikeButton(isLiked: Bool) {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)

        likeButton.isSelected = isLiked
    }
}
