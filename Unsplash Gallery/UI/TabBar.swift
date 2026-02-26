//
//  TabBar.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//
//
import UIKit

final class TabBarController: UITabBarController {
    let mainViewController = MainScreen()
    let favouriteViewController = FavouriteViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
        let favouriteNavigationController = UINavigationController(rootViewController: favouriteViewController)
        
        mainNavigationController.tabBarItem = UITabBarItem(title: "Flow", image: UIImage(systemName: "house"), tag: 0)
        favouriteNavigationController.tabBarItem = UITabBarItem(title: "Fav", image: UIImage(systemName: "heart"), tag: 1)
        
        viewControllers = [mainNavigationController, favouriteNavigationController]
        tabBar.tintColor = .white
        tabBar.backgroundColor = .clear
        tabBar.tintColor = .blackAdaptive
        tabBar.isTranslucent = true
    }
}
