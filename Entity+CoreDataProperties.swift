//
//  Entity+CoreDataProperties.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 11.05.22.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }
    
    @nonobjc public class func batchDeleteRequest() -> NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: self.fetchRequest())
    }

    @NSManaged public var data: Data
    @NSManaged public var width: Float
    @NSManaged public var height: Float

}

extension Entity : Identifiable {

}
