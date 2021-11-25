//
//  ImageItem.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 22.11.21.
//

//import Foundation
import Firebase
import Foundation

struct ImageItem {
  let key: String
  let url: String

  // MARK: Initialize with Raw Data
  init(url: String, key: String = "") {
    self.key = key
    self.url = url
  }

  // MARK: Initialize with Firebase DataSnapshot
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let url = value["url"] as? String
    else {
      return nil
    }
    self.key = snapshot.key
    self.url = url
  }

  // MARK: Convert GroceryItem to AnyObject
  func toAnyObject() -> Any {
    return [
      "url": url
    ]
  }
}

//let ref: DatabaseReference?
//let key: String
//let name: String
//let addedByUser: String
//var completed: Bool
//
//// MARK: Initialize with Raw Data
//init(name: String, addedByUser: String, completed: Bool, key: String = "") {
//  self.ref = nil
//  self.key = key
//  self.name = name
//  self.addedByUser = addedByUser
//  self.completed = completed
//}
//
//// MARK: Initialize with Firebase DataSnapshot
//init?(snapshot: DataSnapshot) {
//  guard
//    let value = snapshot.value as? [String: AnyObject],
//    let name = value["name"] as? String,
//    let addedByUser = value["addedByUser"] as? String,
//    let completed = value["completed"] as? Bool
//  else {
//    return nil
//  }
//
//  self.ref = snapshot.ref
//  self.key = snapshot.key
//  self.name = name
//  self.addedByUser = addedByUser
//  self.completed = completed
//}
//
//// MARK: Convert GroceryItem to AnyObject
//func toAnyObject() -> Any {
//  return [
//    "name": name,
//    "addedByUser": addedByUser,
//    "completed": completed
//  ]
//}
