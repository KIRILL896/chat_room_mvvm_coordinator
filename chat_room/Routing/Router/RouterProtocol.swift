//
//  RouterProtocol.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit

typealias NavigationBackClosure = (() -> ())

protocol RouterProtocol:UIViewControllerTransitioningDelegate {
    func push(_ drawable:Drawable, animated:Bool, onNavigationBack:NavigationBackClosure?)
    func present(_ drawable:Drawable, animated:Bool, onDismiss closure:NavigationBackClosure?)
    func presenTation(_ drawable: Drawable, animated: Bool, onDismiss closure: NavigationBackClosure?) 
    func pop(_ isAnimated:Bool)
    func back(_ isAnimated:Bool)
}

