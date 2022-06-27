//
//  FirebaseImageItem.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 22.11.21.
//

import Firebase
import Foundation

struct FirebaseImageItem {
    let key: String
    let url: String
    let width: Float
    let height: Float
    
    init(url: String, width: Float, height: Float, key: String = "") {
        self.key = key
        self.url = url
        self.width = width
        self.height = height
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let url = value["url"] as? String,
            let width = value["width"] as? Float,
            let height = value["height"] as? Float
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
