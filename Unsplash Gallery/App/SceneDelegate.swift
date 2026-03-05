//
//  SceneDelegate.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }

        let tokenStorage = OAuth2TokenStorage()
        let storageManager = StorageManager()
        let urlSession = URLSession.shared

        let profileService = ProfileService(
            urlSession: urlSession,
            tokenStorage: tokenStorage
        )

        let imageListService = ImageListService(
            urlSession: urlSession,
            tokenStorage: tokenStorage,
            storeManager: storageManager,
            profileService: profileService
        )

        let oauth2Service = OAuth2Service(
            storage: tokenStorage,
            urlSession: urlSession
        )
        let splashViewController = SplashScreenViewController(
            storage: tokenStorage,
            profileService: profileService,
            oauth2Service: oauth2Service,
            imageListService: imageListService
        )

        window = UIWindow(windowScene: scene)
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()
    }
}
