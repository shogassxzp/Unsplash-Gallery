import UIKit

final class SplashScreenViewController: UIViewController, AuthViewControllerDelegate {
    private var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .unplashLogo)
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
        view.backgroundColor = .blackUniversal
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),
        ])
    }

    private func presentAuthView() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        UIBlockingProgressHUD.dismiss()
        present(navigationController, animated: true)
    }

    private func checkAuthentication() {
        guard let token = storage.token else {
            presentAuthView()
            return
        }
        switchToTabBarController()
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        let tabBarController = TabBarController()

        window.rootViewController = tabBarController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIBlockingProgressHUD.dismiss()
        }
    }
}

extension SplashScreenViewController {
    func didAuthenticate(_ vc: AuthViewController) {
        guard storage.token != nil else {
            return
        }
        checkAuthentication()
    }
}
