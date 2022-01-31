//
//  TabBarController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 1.12.21.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
        let layout = PinterestLayout()
        let imagesVC = ImagesCollectionViewController(collectionViewLayout: layout)
        imagesVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)

        let addImageVC = AddImageViewController()
        addImageVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.square"), tag: 0)
                
        self.viewControllers = [imagesVC, UINavigationController(rootViewController: addImageVC)]
    }
}
