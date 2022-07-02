//
//  CoreDataToImageItemMapper.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 23.06.22.
//

import Foundation

final class CoreDataToImageItemMapper {
    
    func map(_ input: Entity) -> ImageItem {
        return ImageItem(id: UUID().uuidString,
                         source: .data(input.data),
                         size: (width: input.width, height: input.height))
    }
}
