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
    var imagesDidChange: (() -> Void)? { get set }
    var imagesCount: Int { get }
    func loadImages()
    func loadImage(for: IndexPath, completion: @escaping (Data) -> Void)
    func sizeOfImage(at: IndexPath) -> CGSize
}

final class ImagesViewModel: ImagesViewModelProtocol {
    
    private let imagesProvider: ImageItemsProvidable!
    
    init(){
        self.imagesProvider = ImageItemsProvider()
        self.imagesProvider.itemsDidChange = { [weak self] in
            guard let self = self else {return}
            self.imagesDidChange?()
        }
    }
    
    var imagesDidChange: (() -> Void)?
    
    var imagesCount: Int {
        return self.imagesProvider.count
    }
    
    func loadImages(){
        self.imagesProvider.fetch()
    }
    
    func loadImage(for indexPath: IndexPath, completion: @escaping (Data) -> Void){
        guard let item = self.imagesProvider.items?[indexPath.item] else {return}
        self.imagesProvider.loadImageData(item: item, completion: completion)
    }
    
    func sizeOfImage(at indexPath: IndexPath) -> CGSize{
        guard let item = self.imagesProvider.items?[indexPath.item] else {return CGSize.zero}
        return CGSize(from: self.imagesProvider.sizeOf(item))
    }
}

extension CGSize {
    init(from: ImageSize){
        self.init(width: CGFloat(from.width), height: CGFloat(from.height))
    }
}
