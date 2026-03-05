import UIKit

final class SplashScreenViewController: UIViewController, AuthViewControllerDelegate {
    private let storage: OAuth2TokenStorage
    private let profileService: ProfileService
    private let oauth2Service: OAuth2Service
    private let imageListService: ImageListService

    init(storage: OAuth2TokenStorage, profileService: ProfileService, oauth2Service: OAuth2Service, imageListService: ImageListService) {
        self.storage = storage
        self.profileService = profileService
        self.oauth2Service = oauth2Service
        self.imageListService = imageListService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .unsplashLogo)
        imageView.tintColor = .blackAdaptive
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .whiteAdaptive
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),
        ])
    }

    private func presentAuthView() {
        let authViewController = AuthViewController(
            oauth2Service: oauth2Service,
            delegate: self,
            tokenStorage: storage
        )
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func checkAuthentication() {
        guard storage.token != nil else {
            presentAuthView()
            return
        }
        fetchProfileAndSwitch()
    }

    private func fetchProfileAndSwitch() {
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.switchToTabBarController()
                case let .failure(error):
                    print("Profile error: \(error)")
                }
            }
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            return
        }

        let feedViewModel = FeedViewModel(imageListService: imageListService)
        feedViewModel.mode = .feed

        let favViewModel = FeedViewModel(imageListService: imageListService)
        favViewModel.mode = .favourites
        
        let feedViewController = FeedViewController(viewModel: feedViewModel, imageListService: imageListService)
        let favoutiteViewController = FavouriteViewController(viewModel: favViewModel, imageListService: imageListService)

        let tabBarController = TabBarController(feedViewController: feedViewController, favouriteViewController: favoutiteViewController)

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}

extension SplashScreenViewController {
    func didAuthenticate(_ viewController: AuthViewController) {
        guard storage.token != nil else {
            return
        }
        checkAuthentication()
    }
}
