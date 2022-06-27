//
//  FirebaseToImageItemMapper.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 23.06.22.
//

import Foundation

final class FirebaseToImageItemMapper {
    
    func map(_ input: FirebaseImageItem) -> ImageItem {
        return ImageItem(id: input.key,
                         source: .url(input.url),
                         size: (width: input.width, height: input.height))
    }
}
