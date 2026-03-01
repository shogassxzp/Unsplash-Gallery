//
//  DetailsScreen.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import Combine
import Kingfisher
import UIKit

final class DetailsScreenViewController: UIViewController {
    private var viewModel: DetailsViewModel
    private var cancellables = Set<AnyCancellable>()

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
        setupNavigationBar() 
        
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
            detailsImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),

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
            authorNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        if #available(iOS 26.0, *) {
            navigationController?.navigationBar.tintColor = .blackAdaptive
        } else {
            
            let blurEffect = UIBlurEffect(style: .systemThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            blurView.layer.cornerRadius = 17.5
            blurView.clipsToBounds = true
            blurView.isUserInteractionEnabled = false

            let icon = UIImageView(image: UIImage(systemName: "chevron.left"))
            icon.contentMode = .center
            icon.frame = blurView.bounds
            icon.tintColor = .blackAdaptive
            blurView.contentView.addSubview(icon)

            let button = UIButton(type: .custom)
            button.frame = blurView.frame
            button.addSubview(blurView)
            button.addTarget(self, action: #selector(backAction), for: .touchUpInside)

            let customBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = customBarButton
        }
    }

    // MARK: - Combine Binding

    private func bindViewModel() {
        viewModel.$currentPhoto
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photo in
                guard let self = self, let photo = photo else { return }
                self.updateUI(with: photo)
            }
            .store(in: &cancellables)

        viewModel.transitionDirection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isNext in
                self?.animateTransition(isNext: isNext)
            }
            .store(in: &cancellables)
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
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    private func animateTransition(isNext: Bool) {
        let tempImageView = UIImageView(frame: detailsImageView.frame)
        tempImageView.contentMode = detailsImageView.contentMode
        tempImageView.image = detailsImageView.image
        tempImageView.clipsToBounds = true
        tempImageView.layer.cornerRadius = detailsImageView.layer.cornerRadius
        tempImageView.layer.maskedCorners = detailsImageView.layer.maskedCorners
        view.addSubview(tempImageView)

        let width = view.bounds.width
        let departureTranslation = isNext ? -width : width
        let arrivalTranslation = isNext ? width : -width

        detailsImageView.transform = CGAffineTransform(translationX: arrivalTranslation, y: 0)

        [descriptionLabel, publishedLabel, authorNameLabel].forEach { $0.alpha = 0 }

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            tempImageView.transform = CGAffineTransform(translationX: departureTranslation, y: 0)
            tempImageView.alpha = 0
            self.detailsImageView.transform = .identity
        }, completion: { _ in
            tempImageView.removeFromSuperview()
            UIView.animate(withDuration: 0.2) {
                [self.descriptionLabel, self.publishedLabel, self.authorNameLabel].forEach { $0.alpha = 1 }
            }
        }
        )
    }

    private func updateUI(with photo: PhotoResult) {
        authorNameLabel.text = viewModel.authorName
        descriptionLabel.text = viewModel.description
        publishedLabel.text = "Published: \(viewModel.formattedDate)"

        detailsImageView.kf.setImage(
            with: URL(string: photo.urls.full),
            placeholder: UIImage(resource: .imagePlaceholder),
            options: [.transition(.fade(0.3))]
        )

        let imageName = photo.likedByUser ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)
    }

    @objc private func heartTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        viewModel.toggleLike()

        animateLikeButton()
    }

    private func animateLikeButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        }
        )
    }
}
