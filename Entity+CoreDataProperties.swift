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

    @NSManaged public var url: String
    @NSManaged public var data: Data
    @NSManaged public var width: Int16
    @NSManaged public var height: Int16

}

extension Entity : Identifiable {

}
