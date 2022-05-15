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
    let width: Int16
    let height: Int16
    
    init(url: String, width: Int16, height: Int16, key: String = "") {
        self.key = key
        self.url = url
        self.width = width
        self.height = height
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let url = value["url"] as? String,
            let width = value["width"] as? Int16,
            let height = value["height"] as? Int16
        else {
            return nil
        }
        self.key = snapshot.key
        self.url = url
        self.width = width
        self.height = height
    }
    
    func toAnyObject() -> Any {
        return [
            "url": url,
            "width": width,
            "height": height
        ]
    }
}
