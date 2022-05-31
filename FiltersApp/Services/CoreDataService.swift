//
//  CoreDataService.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 23.05.22.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol: AnyObject{
    func saveViewContext()
    func saveImage(url: String, imageData: Data?, size: (width: Float, height: Float))
    func entityBy(objectID: NSManagedObjectID) -> Entity?
    func fetch() -> [Entity]?
    func clear()
}

final class CoreDataService: CoreDataServiceProtocol{
    
    static var shared: CoreDataServiceProtocol = {
        return CoreDataService()
    }()
    
    private init(){}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveViewContext() {
        let context: NSManagedObjectContext = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveImage(url: String, imageData: Data?, size: (width: Float, height: Float)){
        guard let data = imageData else {return}
        let viewContext = persistentContainer.newBackgroundContext()
        let entity = Entity(context: viewContext)
        entity.url = url
        entity.data = data
        entity.width = Int16(size.width)
        entity.height = Int16(size.height)
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func entityBy(objectID: NSManagedObjectID) -> Entity? {
        return persistentContainer.viewContext.object(with: objectID) as? Entity
    }
    
    func fetch() -> [Entity]?{
        var entities: [Entity]?
        do {
            entities = try persistentContainer.viewContext.fetch(Entity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return entities
    }
    
    func clear(){
        do {
            try persistentContainer.viewContext.execute(Entity.batchDeleteRequest())
            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension CoreDataService: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
