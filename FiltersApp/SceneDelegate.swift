//
//  SceneDelegate.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 10.11.21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: windowScene)
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = self.rootViewContronner()
        window?.makeKeyAndVisible()
    }
    
    func rootViewContronner() -> UIViewController {
        let tabBarController = UITabBarController()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let imagesVC = ImagesViewController(collectionViewLayout: layout)
        
        imagesVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
        let addImageVC = AddImageViewController()
        addImageVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.square"), tag: 0)
        
        tabBarController.viewControllers = [imagesVC, UINavigationController(rootViewController: addImageVC)]
        
        return tabBarController
    }
}

