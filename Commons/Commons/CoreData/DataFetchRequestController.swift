//
//  DataFetchRequestController.swift
//  Commons
//
//  Created by Muhammed Rashid on 18/12/20.
//

import UIKit
import CoreData

class DataFetchRequestController<T: NSManagedObject>: NSObject {
    private var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
    private var fetchPerformed = false
    var delegate: NSFetchedResultsControllerDelegate! {
        didSet {
            fetchResultController.delegate = delegate
        }
    }
    
    var objects: [T]? {
        guard fetchPerformed else {
            fatalError("performFetchIfNeeded should be called before making this call")
        }
        return fetchResultController.fetchedObjects as? [T]
    }
    
    override init() {
        super.init()
        let entityName = "\(T.self)"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesSubentities = true
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedInstance.mainQueueMOC, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func performFetchIfNeeded() {
        guard !fetchPerformed else { return }
        try? fetchResultController.performFetch()
        fetchPerformed = true
    }
    
    var numberOfSections: Int {
        fetchResultController.sections?.count ?? 0
    }
    
    func numberOfItemInSection(_ section: Int) -> Int {
        fetchResultController.sections?[0].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> T {
        fetchResultController.object(at: indexPath) as! T
    }
}
