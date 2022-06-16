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
        case .db:
            let size = FirebaseService.shared.getImageSize(by: source)
            return CGSize(width: size.width, height: size.height)
        case .cd:
            let size = CoreDataService.shared.getImageSize(by: source)
            return CGSize(width: size.width, height: size.height)
        }
    }
    
    func loadImage(for indexPath: IndexPath, completion: @escaping (Data) -> Void){
        if let source = self.imageSources?[indexPath.item]{
            switch source{
            case .db:
                FirebaseService.shared.get(by: source, onCompletion: {downloadedData in
                    completion(downloadedData)
                    DispatchQueue.global().async {
                        if let downloadedImage = UIImage(data: downloadedData){
                            CoreDataService.shared.save(
                                data: downloadedData,
                                size: ((Float(downloadedImage.size.width)), Float(downloadedImage.size.height)))
                        }
                    }
                })
            case .cd:
                CoreDataService.shared.get(by: source, onCompletion: completion)
            }
        }
    }
    
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
            CoreDataService.shared.getAll(onCompletion: {downloadedItems in
                guard let items: [Entity] = downloadedItems as? [Entity] else {return}
                self.coreDataImageSources = items.map{ImageSource.cd($0.objectID)}
            })
        }
    }
    
    private func loadImageItemsFromDatabase(){
        DispatchQueue.global().async {[weak self] in
            guard let self = self else {return}
            FirebaseService.shared.getAll(onCompletion: {downloadedItems in
                guard let items: [ImageItem] = downloadedItems as? [ImageItem] else {return}
                self.databaseImageSources = items.map{ImageSource.db($0)}
            })
        }
    }
}
