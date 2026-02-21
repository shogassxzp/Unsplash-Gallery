//
//  TabBar.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class TabBarController: UITabBarController {
    private let mainScreenController = MainScreen()
    private let detailsScreenController = DetailsScreenViewController()

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
        viewControllers = [mainScreenController, detailsScreenController]
        tabBar.tintColor = .white
        tabBar.backgroundColor = .clear // for test
        tabBar.tintColor = .green // also test
        tabBar.isTranslucent = true
    }
}
