//
//  ImageItem.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 21.06.22.
//

import Foundation

struct ImageItem{
    let id: String
    let source: ImageSource
    let size: ImageSize
}

enum ImageSource{
    case url(String)
    case data(Data)
}
