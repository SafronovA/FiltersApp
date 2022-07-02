//
//  ImageItemsProvider.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 21.06.22.
//

import Foundation

protocol ImageItemsProvidable: AnyObject {
    var itemsDidChange: (() -> Void)? { get set }
    var items: [ImageItem]? { get }
    var count: Int { get }
    func fetch()
    func loadImageData(item: ImageItem, completion: @escaping (Data) -> Void)
    func sizeOf(_ image: ImageItem) -> ImageSize
}

final class ImageItemsProvider: ImageItemsProvidable{
    
    private let coreDataService: ImagesSourceProtocol = CoreDataService()
    
    private let firebaseService: ImagesSourceProtocol = FirebaseService()
    
    private var databaseItems: [ImageItem]? {
        didSet {
            guard let items = databaseItems, items.isEmpty == false else {return}
            self.coreDataService.clear()
            self.items = items
        }
    }
    
    var itemsDidChange: (() -> Void)?
    
    var items: [ImageItem]? {
        didSet {
            if(items?.isEmpty == false){
                self.itemsDidChange?()
            }
        }
    }
    
    var count: Int {
        return items?.count ?? 0
    }
    
    func fetch(){
        self.fetchFromCoreData()
        self.fetchFromDatabase()
    }
    
    func loadImageData(item: ImageItem, completion: @escaping (Data) -> Void){
        switch item.source{
        case .url(_):
            firebaseService.get(by: item.source, onCompletion: {downloadedData in
                completion(downloadedData)
            })
        case .data(_):
            coreDataService.get(by: item.source, onCompletion: completion)
        }
    }
    
    func sizeOf(_ item: ImageItem) -> ImageSize {
        return item.size
    }
    
    private func fetchFromCoreData(){
        DispatchQueue.global().async {[weak self] in
            guard let self = self else {return}
            self.coreDataService.getAll(onCompletion: {downloadedItems in
                guard let cdItems: [Entity] = downloadedItems as? [Entity] else {return}
                let mapper = CoreDataToImageItemMapper()
                self.items = cdItems.map{mapper.map($0)}
            })
        }
    }
    
    private func fetchFromDatabase(){
        DispatchQueue.global().async {[weak self] in
            guard let self = self else {return}
            self.firebaseService.getAll(onCompletion: {downloadedItems in
                guard let firebaseItems: [FirebaseImageItem] = downloadedItems as? [FirebaseImageItem] else {return}
                let mapper = FirebaseToImageItemMapper()
                let items: [ImageItem] = firebaseItems.map{mapper.map($0)}
                self.databaseItems = items
            })
        }
    }
}
