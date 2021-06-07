//
//  Router.swift
//  FlowController
//
//  Created by Muhammed Rashid on 09/05/21.
//

import Foundation
import UIKit

public final class Router: Routable {
    public var rootNavigationController: UINavigationController
    
    public init(_ rootViewController: UINavigationController) {
        rootNavigationController = rootViewController
    }
}
