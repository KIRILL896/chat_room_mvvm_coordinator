//
//  Drawable.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit

protocol Drawable {
    var viewController:UIViewController? {get}
}

extension UIViewController:Drawable {
    var viewController: UIViewController? {return self}
}
