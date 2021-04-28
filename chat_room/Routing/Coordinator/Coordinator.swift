//
//  Coordinator.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import Foundation


protocol Coordintator:class {
    var children:[Coordintator] {get set}
    func start() -> Void
}


extension Coordintator {
    func add(coordinator:Coordintator) -> Void {
        children.append(coordinator)
    }
    
    func remove(coordinator:Coordintator) {
        children = children.filter({ $0 !== coordinator})
    }
}

