//
//  PagingDataSource.swift
//  Commons
//
//  Created by Muhammed Rashid on 18/12/20.
//

import UIKit
import CoreData

class PagingDataSource<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    private var fetchResultController: DataFetchRequestController<T>?
    private var scrollView: UIScrollView!    
    
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
    }
    
    func reloadDataFrom(_ fetchResultController: DataFetchRequestController<T>) {
        self.fetchResultController = fetchResultController
        self.fetchResultController?.delegate = self
        self.fetchResultController?.performFetchIfNeeded()
        (scrollView as? UITableView)?.reloadData()
    }
    
    var numberOfSections: Int {
        fetchResultController?.numberOfSections ?? 0
    }
    
    func numberOfItemInSection(_ section: Int) -> Int {
        fetchResultController?.numberOfItemInSection(section) ?? 0
    }
    
    func object(at indexPath: IndexPath) -> T {
        fetchResultController!.object(at: indexPath)
    }
    
    func requestPage() {
         fetchResultController?.performFetchIfNeeded()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let tableView = scrollView as? UITableView {
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                }
            case .delete:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            case .update:
                if let indexPath = indexPath {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }
            default:
                break
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let tableView = scrollView as? UITableView {
            tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let tableView = scrollView as? UITableView {
            DispatchQueue.main.async {
                tableView.endUpdates()
            }
        }
    }
}
