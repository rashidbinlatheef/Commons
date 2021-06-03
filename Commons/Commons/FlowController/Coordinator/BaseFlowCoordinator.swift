//
//  BaseFlowCoordinator.swift
//  FlowController
//
//  Created by Muhammed Rashid on 09/05/21.
//

import Foundation
import UIKit

open class BaseFlowCoordinator: FlowCoordinator, FlowEventsDelegate {
    public weak var flowEventsDelegate: FlowEventsDelegate?
    private var childCoordinators = [FlowCoordinator]()
    
    public init() { }
    
    final public func addChildCoordinator(_ childCoordinator: FlowCoordinator) {
        guard !childCoordinators.contains(where: { $0 === childCoordinator }) else {
            return
        }
        childCoordinators.append(childCoordinator)
    }
    
    final public func removeChildCoordinator(_ childCoordinator: FlowCoordinator?) {
        guard let childCoordinator = childCoordinator, !childCoordinators.isEmpty else {
            return
        }
        if let coordinator = childCoordinator as? BaseFlowCoordinator, !coordinator.childCoordinators.isEmpty {
            coordinator.childCoordinators
                .filter({ $0 !== coordinator })
                .forEach({ coordinator.removeChildCoordinator($0) })
        }
        for (index, element) in childCoordinators.enumerated() where element === childCoordinator {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    final public func sendEvent(_ event: FlowEvent) {
        handleEvent(event, flowCoordinator: self)
    }
    
    open func start() {
        assertionFailure("Base Class Should Implement this")
    }
    
    open func handleEvent(_ event: FlowEvent, flowCoordinator: FlowCoordinator) {}
}
