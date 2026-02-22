//
//  TabBar.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//
//
import UIKit

final class TabBarController: UITabBarController {
    private let mainScreenController = UINavigationController(rootViewController: MainScreen(photos: [.mock, .mock1, .mock2,.mock3,.mock4]))
    private let detailsScreenController = DetailsScreenViewController()
    private let favouriteScreenController = UINavigationController(rootViewController: FavouriteViewController(favouritePhotos: [.mock, .mock1, .mock2,.mock3,.mock4]))

    override func viewDidLoad() {
        super.viewDidLoad()

        mainScreenController.tabBarItem = UITabBarItem(
            title: "flow",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house")
        )
        detailsScreenController.tabBarItem = UITabBarItem(
            title: "details",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house")
        )
        favouriteScreenController.tabBarItem = UITabBarItem(
            title: "fav",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart")
        )
        viewControllers = [mainScreenController, detailsScreenController, favouriteScreenController]
        tabBar.tintColor = .white
        tabBar.backgroundColor = .clear
        tabBar.tintColor = .green // also test
        tabBar.isTranslucent = true
    }
}
