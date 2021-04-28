//
//  AppCoordinator.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit

class AppCoordinator:BaseCoordinator {
    
    private let window:UIWindow
    
    private let navigationController:UINavigationController = {
       let nav = UINavigationController()
       let bar = nav.navigationBar
       bar.setBackgroundImage(UIImage(), for: .default)
       bar.shadowImage = UIImage()
       bar.isTranslucent = false
       return nav
    }()
    
    init(window:UIWindow) {
        self.window = window
    }
    
    override func start() {
//        let router = Router(navigationController: self.navigationController)
//        let authCoordinator = AuthCoordinator(router: router)
//        self.add(coordinator: authCoordinator)
//        
//        authCoordinator.isCompleted = { [weak self, weak authCoordinator] in
//            guard let coordinator = authCoordinator else {return}
//            self?.remove(coordinator: coordinator)
//        }
//        
//        authCoordinator.start()
//        window.rootViewController = self.navigationController
//        window.makeKeyAndVisible()
    }
}

