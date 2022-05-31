//
//  ImagesViewModel.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 26.04.22.
//

import Foundation
import CoreData
import UIKit

protocol ImagesViewModelProtocol: AnyObject {
    var imagesCount: Int { get }
    var imagesDidChange: (() -> Void)? { get set }
    func loadImages()
    func sizeOfImage(at: IndexPath) -> CGSize
    func loadImage(for: IndexPath, completion: @escaping (Data) -> Void)
}

enum ImageSource{
    case db(ImageItem)
    case cd(NSManagedObjectID)
}

class ImagesViewModel: ImagesViewModelProtocol {
    
    var imagesCount: Int {
        return self.imageSources?.count ?? 0
    }
    
    var imagesDidChange: (() -> Void)?
    
    func loadImages(){
        self.loadImageItemsFromDatabase()
        self.loadImageEntitiesFromCoreData()
    }
    
    func sizeOfImage(at indexPath: IndexPath) -> CGSize{
        guard let source = self.imageSources?[indexPath.item] else {return CGSize.zero}
        switch source{
        case .db(let item):
            return CGSize(width: Int(item.width), height: Int(item.height))
        case .cd(let id):
            guard let entity = CoreDataService.shared.entityBy(objectID: id) else {return CGSize.zero}
            return CGSize(width: Int(entity.width), height: Int(entity.height))
        }
    }
    
    func loadImage(for indexPath: IndexPath, completion: @escaping (Data) -> Void){
        if let source = self.imageSources?[indexPath.item]{
            switch source{
            case .db(let item):
                self.loadImage(url: item.url, completion: completion)
            case .cd(let id):
                if let entity = CoreDataService.shared.entityBy(objectID: id) {
                    completion(entity.data)
                }
            }
        }
    }
    
    private var imagesCache = NSCache<NSString, NSData>()
    
    private var imageSources: [ImageSource]? {
        didSet {
            if(imageSources?.isEmpty == false){
                self.imagesDidChange?()
            }
        }
    }
    
    private var databaseImageSources: [ImageSource]? {
        didSet {
            if(databaseImageSources?.isEmpty == false){
                imageSources = databaseImageSources
                CoreDataService.shared.clear()
            }
        }
    }
    
    private var coreDataImageSources: [ImageSource]? {
        didSet {
            if(databaseImageSources?.isEmpty ?? true){
                imageSources = coreDataImageSources
            }
        }
    }
    
    private func loadImageEntitiesFromCoreData(){
        DispatchQueue.global().async {[weak self] in
            guard let self = self else {return}
            self.coreDataImageSources = CoreDataService.shared.fetch()?.map{ImageSource.cd($0.objectID)}
        }
    }
    
    private func loadImageItemsFromDatabase(){
        DispatchQueue.global().async {[weak self] in
            guard let self = self else {return}
            FirebaseService.shared.downloadAll(onCompletion: {downloadItems in
                self.databaseImageSources = downloadItems?.map{ImageSource.db($0)}
            })
        }
    }
    
    private func loadImage(url: String, completion: @escaping (Data) -> Void){
        if let dataFromCache: NSData = self.imagesCache.object(forKey: url as NSString){
            completion(dataFromCache as Data)
        } else {
            let operation = DownloadDataOperation()
            operation.qualityOfService = .userInitiated
            operation.urlString = url
            operation.start()
            operation.completionBlock = { [weak self] in
                guard
                    let self = self,
                    let downloadedData = operation.downloadedData
                else {return}
                
                completion(downloadedData)
                
                DispatchQueue.global().async {
                    if let downloadedImage = UIImage(data: downloadedData){
                        CoreDataService.shared.saveImage(
                            url: url,
                            imageData: downloadedData,
                            size: ((Float(downloadedImage.size.width)), Float(downloadedImage.size.height)))
                    }
                }
                self.imagesCache.setObject(NSData(data: downloadedData), forKey: url as NSString)
            }
        }
    }
}
