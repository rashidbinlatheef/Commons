//
//  Box.swift
//  Commons
//
//  Created by Muhammed Rashid on 13/12/20.
//

import UIKit

public class Box <T> {
    public typealias Listener = (T) -> Void
    public var listener: Listener?
    
    public var value: T {
        didSet {
            listener?(value)
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
