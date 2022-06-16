//
//  CoreDataService.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 23.05.22.
//

import Foundation
import CoreData

final class CoreDataService: ImagesSourceProtocol{
    
    static var shared: ImagesSourceProtocol = {
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
    
    func save(data: Data?, size: (width: Float, height: Float)){
        guard let data = data else {return}
        let viewContext = persistentContainer.newBackgroundContext()
        let entity = Entity(context: viewContext)
        entity.data = data
        entity.width = Int16(size.width)
        entity.height = Int16(size.height)
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func get(by key: ImageSource, onCompletion: @escaping (Data) -> Void){
        guard case .cd(let id) = key else {return}
        guard let entity = entityBy(objectID: id) else{return}
        onCompletion(entity.data)
    }

    func getAll() -> [Entity]?{
        var entities: [Entity]?
        do {
            entities = try persistentContainer.viewContext.fetch(Entity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return entities
    }
    
    func getAll(onCompletion: @escaping ([Any]) -> Void){
        var entities: [Entity]?
        do {
            entities = try persistentContainer.viewContext.fetch(Entity.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        guard let entities = entities else {return}
        onCompletion(entities)
    }
      
    func getImageSize(by key: ImageSource) -> Size{
        guard case .cd(let id) = key else {return (0, 0)}
        guard let entity = entityBy(objectID: id) else {return (0, 0)}
        return (width: Int(entity.width), height: Int(entity.height))
    }
    
    func clear(){
        do {
            try persistentContainer.viewContext.execute(Entity.batchDeleteRequest())
            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func entityBy(objectID: NSManagedObjectID) -> Entity? {
        return persistentContainer.viewContext.object(with: objectID) as? Entity
    }
}

extension CoreDataService: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
