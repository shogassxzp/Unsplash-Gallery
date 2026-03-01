//
//  TabBar.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//
//
import UIKit

final class TabBarController: UITabBarController {
    let feedViewController = FeedViewController()
    let favouriteViewController = FavouriteViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainNavigationController = UINavigationController(rootViewController: feedViewController)
        let favouriteNavigationController = UINavigationController(rootViewController: favouriteViewController)
        
        mainNavigationController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "photo.on.rectangle.angled"), tag: 0)
        favouriteNavigationController.tabBarItem = UITabBarItem(title: "Favourite", image: UIImage(systemName: "heart"), tag: 1)
        
        viewControllers = [mainNavigationController, favouriteNavigationController]
        tabBar.tintColor = .white
        tabBar.backgroundColor = .clear
        tabBar.tintColor = .blackAdaptive
        tabBar.isTranslucent = true
    }
}
