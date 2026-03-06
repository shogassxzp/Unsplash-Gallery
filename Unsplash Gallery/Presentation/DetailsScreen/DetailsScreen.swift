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
    // MARK: - Properties

    private var viewModel: DetailsViewModel
    private var cancellables = Set<AnyCancellable>()
    private var imageAspectRatioConstraint: NSLayoutConstraint?
    private var imageTopConstraint: NSLayoutConstraint?

    // MARK: - UI Elements

    private lazy var detailsImageView: UIImageView = {
        let details = UIImageView()
        details.layer.cornerRadius = 24
        details.layer.masksToBounds = true
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
        config.baseForegroundColor = .redUniversal
        button.configuration = config
        button.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        return button
    }()

    private lazy var textInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()

    private var aspectRatio: CGFloat {
        guard let photo = viewModel.currentPhoto, photo.height > 0 else { return 1.0 }
        return CGFloat(photo.width) / CGFloat(photo.height)
    }

    // MARK: - Init

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        togglePopGestures(enabled: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        togglePopGestures(enabled: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainUI()
        bindViewModel()
    }
}

// MARK: - UI Setup & Layout

private extension DetailsScreenViewController {
    func setupMainUI() {
        view.backgroundColor = .backgroundAdaptive
        addSubviews()
        setupLayout()
        setupGesture()
        setupNavigationBar()
    }

    func addSubviews() {
        [detailsImageView, textInfoStack, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [authorNameLabel, descriptionLabel, publishedLabel].forEach {
            textInfoStack.addArrangedSubview($0)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        detailsImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            detailsImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            likeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            likeButton.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 16),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),

            textInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textInfoStack.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -12),
            textInfoStack.topAnchor.constraint(equalTo: detailsImageView.bottomAnchor, constant: 20),
            textInfoStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func updateUI(with photo: PhotoResult) {
        detailsImageView.contentMode = .scaleAspectFill
        updateImageConstraints(aspectRatio: aspectRatio)
        updateImageTopConstraint(isVertical: photo.height > photo.width)

        authorNameLabel.text = viewModel.authorName
        publishedLabel.text = "Published: \(viewModel.formattedDate)"
        descriptionLabel.text = photo.description
        descriptionLabel.isHidden = (photo.description?.isEmpty ?? true)

        let placeholder = UIImage(resource: .imagePlaceholder).withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 40)
        )

        detailsImageView.kf.setImage(
            with: URL(string: photo.urls.full),
            placeholder: placeholder,
            options: [.transition(.fade(0.3))],
            completionHandler: { [weak self] _ in self?.detailsImageView.contentMode = .scaleAspectFit }
        )

        let imageName = photo.likedByUser ? "heart.fill" : "heart"
        likeButton.configuration?.image = UIImage(systemName: imageName)
    }

    func updateImageTopConstraint(isVertical: Bool) {
        imageTopConstraint?.isActive = false
        imageTopConstraint = isVertical ?
            detailsImageView.topAnchor.constraint(equalTo: view.topAnchor) :
            detailsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        imageTopConstraint?.isActive = true
    }

    func updateImageConstraints(aspectRatio: CGFloat) {
        imageAspectRatioConstraint?.isActive = false
        imageAspectRatioConstraint = detailsImageView.widthAnchor.constraint(equalTo: detailsImageView.heightAnchor, multiplier: aspectRatio)
        imageAspectRatioConstraint?.isActive = true
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
}

// MARK: - Actions & Gestures

private extension DetailsScreenViewController {
    func setupGesture() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right]
        directions.forEach { direction in
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            gesture.direction = direction
            view.addGestureRecognizer(gesture)
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            viewModel.nextPhoto()
        } else {
            viewModel.prevPhoto()
        }
    }

    @objc func heartTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.toggleLike()
        animateLikeButton()
    }

    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }

    func togglePopGestures(enabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = enabled
        if #available(iOS 26.0, *) {
            navigationController?.interactiveContentPopGestureRecognizer?.isEnabled = enabled
        }
    }
}

// MARK: - Animations

private extension DetailsScreenViewController {
    func animateTransition(isNext: Bool) {
        let tempImageView = UIImageView(frame: detailsImageView.frame)
        tempImageView.contentMode = detailsImageView.contentMode
        tempImageView.image = detailsImageView.image
        tempImageView.layer.cornerRadius = 24
        tempImageView.clipsToBounds = true
        view.addSubview(tempImageView)

        let width = view.bounds.width
        let translation = isNext ? -width : width
        detailsImageView.transform = CGAffineTransform(translationX: -translation, y: 0)
        [descriptionLabel, publishedLabel, authorNameLabel].forEach { $0.alpha = 0 }

        UIView.animate(withDuration: 0.2, animations: {
            tempImageView.transform = CGAffineTransform(translationX: translation, y: 0)
            tempImageView.alpha = 0
            self.detailsImageView.transform = .identity
        }, completion: { _ in
            tempImageView.removeFromSuperview()
            UIView.animate(withDuration: 0.2) {
                [self.descriptionLabel, self.publishedLabel, self.authorNameLabel].forEach { $0.alpha = 1 }
            }
        })
    }

    func animateLikeButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.likeButton.transform = .identity }
        })
    }
}

// MARK: - Navigation Bar & Bindings

private extension DetailsScreenViewController {
    func bindViewModel() {
        viewModel.$currentPhoto
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photo in
                guard let self = self, let photo = photo else { return }
                self.updateUI(with: photo)
            }
            .store(in: &cancellables)

        viewModel.transitionDirection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.animateTransition(isNext: $0) }
            .store(in: &cancellables)
    }

    func setupNavigationBar() {
        if #available(iOS 26.0, *) {
            navigationController?.navigationBar.tintColor = .blackAdaptive
        } else {
            let icon = UIImage(systemName: "chevron.left")
            let button = UIButton(type: .system)
            button.setImage(icon, for: .normal)
            button.tintColor = .blackAdaptive
            button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
}
