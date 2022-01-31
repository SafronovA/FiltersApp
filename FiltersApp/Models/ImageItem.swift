//
//  ImageItem.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 22.11.21.
//

import Firebase
import Foundation

struct ImageItem {
  let key: String
  let url: String

  init(url: String, key: String = "") {
    self.key = key
    self.url = url
  }

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

  func toAnyObject() -> Any {
    return [
      "url": url
    ]
  }
}
