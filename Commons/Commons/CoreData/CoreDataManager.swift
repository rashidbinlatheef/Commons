//
//  CoreDataManager.swift
//  Commons
//
//  Created by Muhammed Rashid on 16/12/20.
//

import UIKit
import CoreData

public protocol DataImportProtocol {
    func importData(_ data: [String: Any]?, using moc: NSManagedObjectContext)
    func updateData(_ data: [String: Any]?, using moc: NSManagedObjectContext)
    static var primaryKey: String? { get }
    static var primaryKeyInImport: String? { get }
}

public class CoreDataManager {
    let mocOperationQueue: OperationQueue
    var persistentContainer: NSPersistentCloudKitContainer
    var name = "something"
    var mainQueueMOC: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    let backGroundMOC: NSManagedObjectContext
    
    static let sharedInstance = CoreDataManager()
    
    private init() {
        mocOperationQueue = OperationQueue()
        mocOperationQueue.name = "PrivateQueue"
        mocOperationQueue.maxConcurrentOperationCount = 1 // Make this a serial queue
        mocOperationQueue.qualityOfService = .utility
        persistentContainer = NSPersistentCloudKitContainer(name: name)
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        backGroundMOC = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        backGroundMOC.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
    }
    
    private func create<T: NSManagedObject>(_ type:T.Type, usingMOC moc: NSManagedObjectContext? = nil) -> T? {
        guard let entityName = T.entity().name else { return nil }
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: moc ?? mainQueueMOC) else { return nil }
        let object = T(entity: entity, insertInto: moc ?? mainQueueMOC)
        return object
    }
    
    public func importDataInBackground<T: NSManagedObject>(_ dataArray: [[String: Any]], toModelClass modelClass: T.Type, completion: ((_ object: [T]? ) -> Void)?) {
        mocOperationQueue.addOperation {
            self.backGroundMOC.perform {
                if let objects = self.findOrCreateFromData(dataArray, ofType: modelClass, usingMOC: self.backGroundMOC) {
                    do {
                        try self.backGroundMOC.save()
                        DispatchQueue.main.sync {
                            self.save()
                            completion?(objects)
                        }
                    }
                    catch {
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                }
                else {
                    completion?(nil)
                }
            }
        }
    }
    
    public func importDataInBackground<T: NSManagedObject>(_ data: [String: Any], toModelClass modelClass: T.Type, completion: ((_ object: NSManagedObject?) -> Void)?) {
        mocOperationQueue.addOperation {
            self.backGroundMOC.perform {
                if let object = self.findOrCreateFromData(data, ofType: modelClass, usingMOC: self.backGroundMOC) {
                    do {
                        try self.backGroundMOC.save()
                        DispatchQueue.main.sync {
                            self.save()
                            completion?(object)
                        }
                    }
                    catch {
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                }
                else {
                    completion?(nil)
                }
            }
        }
    }
    
    func save() {
        if mainQueueMOC.hasChanges {
            do {
                try mainQueueMOC.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        guard let entityName = T.entity().name else { return }
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        do {
            try mainQueueMOC.execute(batchDeleteRequest)
            save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

///Querry on Data
extension CoreDataManager {
    
    func findObjectFrom<T: NSManagedObject>(_ data: [String: Any], ofType modelClass: T.Type, usingMOC moc: NSManagedObjectContext? = nil) -> T? {
        if let dataImportProtocol = T.self as? DataImportProtocol.Type,
           let primaryKey = dataImportProtocol.primaryKey,
           let primaryKeyInImport = dataImportProtocol.primaryKeyInImport,
           let primaryKeyValue = data[primaryKeyInImport],
           let object = findObjectForConditon([primaryKey: primaryKeyValue], ofType: modelClass, context: moc, limit: 1)?.first {
            return object
        }
        return nil
    }
    
    func findOrCreateFromData<T: NSManagedObject>(_ data: [String: Any], ofType modelClass: T.Type, usingMOC moc: NSManagedObjectContext? = nil) -> T? {
        if let object = findObjectFrom(data, ofType: modelClass, usingMOC: moc) {
            if let dataImportProtocol = object as? DataImportProtocol {
                dataImportProtocol.updateData(data, using: moc ?? mainQueueMOC)
            }
            return object
        }
        
        guard let object = create(modelClass, usingMOC: moc) else { return nil }
        
        if let dataImportProtocol = object as? DataImportProtocol {
            dataImportProtocol.importData(data, using: moc ?? mainQueueMOC)
        }
        return object
    }
    
    func findOrCreateFromData<T: NSManagedObject>(_ dataArray: [[String: Any]], ofType modelClass: T.Type, usingMOC moc: NSManagedObjectContext? = nil) -> [T]? {
        var objects = [T]()
        for data in dataArray {
            if let object = self.findOrCreateFromData(data, ofType: modelClass, usingMOC: moc) {
                objects.append(object)
            }
        }
        return objects.isEmpty ? nil : objects
    }
    
    func findObjectForConditon<T: NSManagedObject>(_ condition: [String: Any]?, ofType modelClass: T.Type, context: NSManagedObjectContext? = nil, limit: Int? = nil) -> [T]? {
        guard let entityName = T.entity().name else { return nil}
        guard let properties = condition else {
            return nil
        }
        let moc = context ?? mainQueueMOC
        // Create Predicate For Condition
        var predicates = [NSPredicate]()
        for (key, value) in properties {
            predicates.append(NSPredicate(format: "%K = %@", argumentArray: [key, value]))
        }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
        
        // Create FetchRequest
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: entityName, in: moc)
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        // Execute FetchRequest
        var results: [T]
        do {
            var fetchResult: [AnyObject]
            try fetchResult = moc.fetch(request)
            
            if let fetchedResultTyped = fetchResult as? [T] {
                results = fetchedResultTyped
            }
            else {
                throw NSError(domain: "Fetch results unable to be casted to [NSManagedObject]", code: 0, userInfo: nil)
            }
        } catch let error as NSError {
            print("Error executing fetch request \(request): " + error.description)
            results = [T]()
        }
        
        return results
    }
    
    private func findOrCreate<T: NSManagedObject>(_ type:T.Type) -> T? {
        guard let entityName = T.entity().name else { return nil }
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: mainQueueMOC) else { return nil }
        let object = T(entity: entity, insertInto: mainQueueMOC)
        return object
    }
}
