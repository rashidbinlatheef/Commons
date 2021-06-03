//
//  UIViewController+Spinner.swift
//  Commons
//
//  Created by Muhammed Rashid on 08/01/21.
//

import Foundation
import UIKit

private var spinnerAssociatedKey: UInt8 = 0

extension UIViewController {
    
    public var spinner: UIActivityIndicatorView? {
        get {
            objc_getAssociatedObject(self, &spinnerAssociatedKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &spinnerAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func showSpinner() {
        removeSpinner()
        spinner = UIActivityIndicatorView()
        if let spinner = self.spinner {
            view.addSubview(spinner)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            let centerXConstraint = NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
            view.addConstraints([centerXConstraint, centerYConstraint])
            spinner.startAnimating()
        }
    }
    
    public func removeSpinner() {
        spinner?.removeFromSuperview()
        spinner = nil
    }
}
