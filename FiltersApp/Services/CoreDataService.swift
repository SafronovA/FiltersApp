//
//  CoreDataService.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 23.05.22.
//

import Foundation
import CoreData

final class CoreDataService: ImagesSourceProtocol{
    
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
    
    func save(data: Data?, size: ImageSize){
        guard let data = data else {return}
        let viewContext = persistentContainer.newBackgroundContext()
        let entity = Entity(context: viewContext)
        entity.data = data
        entity.width = size.width
        entity.height = size.height
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func save(items: [ImageItem]){
        items.forEach{
            guard case .data(let data) = $0.source else {return}
            self.save(data: data, size: (width: $0.size.width, height: $0.size.height))
        }
    }
    
    func get(by key: ImageSource, onCompletion: @escaping (Data) -> Void){
        guard case .data(let data) = key else {return}
        onCompletion(data)
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
        guard let entities = self.getAll() else {return}
        onCompletion(entities)
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
