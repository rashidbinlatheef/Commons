//
//  Routable.swift
//  FlowController
//
//  Created by Muhammed Rashid on 09/05/21.
//

import Foundation
import UIKit

// Routable should consider uiviewcontroller instance as well
public protocol Routable {
    var rootNavigationController: UINavigationController { get set }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)

    func pushViewController(_ viewController: UIViewController, animate: Bool, hideBottomBar: Bool, completion: (() -> Void)?)
    func popViewController(animated: Bool)
    func popToRootViewController(animated: Bool)
    
    func setAsRootViewController(_ viewController: UIViewController, animated: Bool, hideNavigationBar: Bool)
}

extension Routable {
    public func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        rootNavigationController.present(viewController, animated: animated, completion: completion)
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        rootNavigationController.dismiss(animated: animated, completion: completion)
    }
    
    public func pushViewController(_ viewController: UIViewController, animate: Bool = true, hideBottomBar: Bool = true, completion: (() -> Void)? = nil) {
        guard viewController is UINavigationController == false else {
            assertionFailure("Pushing UINavigationController into UINavigationController")
            return
        }
        rootNavigationController.pushViewController(viewController, animated: animate)
        viewController.hidesBottomBarWhenPushed = hideBottomBar
    }
    
    public func popViewController(animated: Bool = true) {
        rootNavigationController.popViewController(animated: animated)
    }
    
    public func popToRootViewController(animated: Bool = true) {
        rootNavigationController.popToRootViewController(animated: animated)
    }
    
    public func setAsRootViewController(_ viewController: UIViewController, animated: Bool = true, hideNavigationBar: Bool = true) {
        rootNavigationController.isNavigationBarHidden = hideNavigationBar
        rootNavigationController.setViewControllers([viewController], animated: animated)
    }
}
