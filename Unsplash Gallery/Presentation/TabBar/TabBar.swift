//
//  TabBar.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//
//
import UIKit

final class TabBarController: UITabBarController {
    let feedViewController: FeedViewController
    let favouriteViewController: FavouriteViewController

    init(feedViewController: FeedViewController, favouriteViewController: FavouriteViewController) {
        self.feedViewController = feedViewController
        self.favouriteViewController = favouriteViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
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
