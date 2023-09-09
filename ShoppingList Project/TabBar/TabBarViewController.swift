//
//  TapBarViewController.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/07.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let searchVC = SearchViewController()
    let likeVC = LikeViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 각 뷰컨 설정 */
        searchVC.tabBarItem.title = "검색"
        likeVC.tabBarItem.title = "좋아요"
        
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        likeVC.tabBarItem.image = UIImage(systemName: "heart")
        
        let navigationSearch = UINavigationController(rootViewController: searchVC)
        let navigationLike = UINavigationController(rootViewController: likeVC)
        
        
        /* 탭바 커스텀 */
        tabBar.backgroundColor = .black                   // 배경 black
        tabBar.tintColor = .white                         // 선택된 탭 white
        tabBar.unselectedItemTintColor = .systemGray2     // 기본 gray
        
        let tabItem = [navigationSearch, navigationLike]
        
        self.viewControllers = tabItem
        print(self)
        print(self.viewControllers)
        
        setViewControllers(tabItem, animated: true)
    }
    
    
}
