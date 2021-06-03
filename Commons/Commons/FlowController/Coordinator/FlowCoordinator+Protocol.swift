//
//  FlowCoordinator+Protocol.swift
//  FlowController
//
//  Created by Muhammed Rashid on 09/05/21.
//

import Foundation
import UIKit

public protocol FlowEvent {}

public protocol FlowCoordinator: AnyObject {
    func start()
}

public protocol FlowEventsDelegate: AnyObject {
    func handleEvent(_ event: FlowEvent, flowCoordinator: FlowCoordinator)
}
