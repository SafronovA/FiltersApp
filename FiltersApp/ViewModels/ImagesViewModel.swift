//
//  ImagesViewModel.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 26.04.22.
//

import Foundation
import Firebase

protocol ImagesViewModelProtocol: AnyObject {
    var images: [ImageItem]? { get }
    var imagesDidChange: ((ImagesViewModelProtocol) -> ())? { get set }
    func getImages()
}

class ImagesViewModel: ImagesViewModelProtocol {
    private let ref = Database
        .database(url: FirebaseConstants.databaseUrl)
        .reference(withPath: FirebaseConstants.pathToImageItems)
    private var refObservers: [DatabaseHandle] = []
    
    var images: [ImageItem]? {
        didSet {
            self.imagesDidChange?(self)
        }
    }
    
    var imagesDidChange: ((ImagesViewModelProtocol) -> ())?
    
    public func getImages(){
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {return}
            let completed = self.ref
                .observe(.value, with: { snapshot in
                    var newItems: [ImageItem] = []
                    for child in snapshot.children {
                        if
                            let snapshot = child as? DataSnapshot,
                            let imageItem = ImageItem(snapshot: snapshot) {
                            newItems.append(imageItem)
                        }
                    }
                    self.images = newItems
                })
            self.refObservers.append(completed)
        }
    }
}
