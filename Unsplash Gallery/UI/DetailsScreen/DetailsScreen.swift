//
//  DetailsScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import Kingfisher
import UIKit

final class DetailsScreenViewController: UIViewController {
    private var viewModel: DetailsViewModel
    
    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .blackAdaptive
        return label
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .semibold)
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
        addSubviews()
        setupLayout()
        setupGesture()
        bindViewModel()
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
            detailsImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            likeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            likeButton.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 16),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -12),
            
            publishedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            publishedLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            publishedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            authorNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authorNameLabel.bottomAnchor.constraint(equalTo: publishedLabel.topAnchor, constant: -8),
            authorNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.animateTransition(isNext: true)
        }
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
            viewModel.nextPhoto()
        } else if gesture.direction == .right {
            viewModel.prevPhoto()
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
        guard let photo = viewModel.currentPhoto else { return }
        authorNameLabel.text = viewModel.authorName
        descriptionLabel.text = viewModel.description
        publishedLabel.text = "Published: \(viewModel.formattedDate)"
        
        detailsImageView.kf.setImage(with: URL(string: photo.urls.full), placeholder: UIImage(resource: .imagePlaceholder))
        
        let imageName = photo.likedByUser ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)
    }
    
    @objc private func heartTapped() {
        guard let photo = viewModel.currentPhoto else { return }
        let futureLikeState = !photo.likedByUser
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        animateLikeButton(isLiked: futureLikeState)
        
        viewModel.toggleLike { [weak self] success in
            if !success {
                self?.animateLikeButton(isLiked: photo.likedByUser)
            }
        }
    }
    
    private func animateLikeButton(isLiked: Bool) {
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
}
