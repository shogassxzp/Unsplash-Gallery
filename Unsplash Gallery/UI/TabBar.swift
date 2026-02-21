//
//  TabBar.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

final class TabBarController: UITabBarController {
    private let mainScreenController = MainScreen()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainScreenController.tabBarItem = UITabBarItem(
            title: "main",
            image: UIImage(systemName: "home"),
            selectedImage: UIImage(systemName: "chevron.left")
        )
        
        tabBar.tintColor = .white
        tabBar.backgroundColor = .red //for test
        tabBar.tintColor = .green //also test
        tabBar.isTranslucent = true
        
    }
}
