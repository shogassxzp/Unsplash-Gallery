import UIKit

final class SplashScreenViewController: UIViewController, AuthViewControllerDelegate {
    private var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .unsplashLogo)
        imageView.tintColor = .blackAdaptive
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let storage = OAuth2TokenStorage.shared

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
            logoImageView.heightAnchor.constraint(equalToConstant: 74)
        ])
    }

    private func presentAuthView() {
        let authViewController = AuthViewController()
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
        ProfileService.shared.fetchProfile { [weak self] result in
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

        let tabBarController = TabBarController()

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
