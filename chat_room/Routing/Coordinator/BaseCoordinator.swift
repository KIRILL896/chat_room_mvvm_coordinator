//
//  BaseCoordinator.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import Foundation


class BaseCoordinator: Coordintator {
    var children: [Coordintator] = []
    var isCompleted:(() -> ())?
    func start() {
        fatalError("not")
    }
}

