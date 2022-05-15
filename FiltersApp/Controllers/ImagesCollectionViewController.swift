//
//  ImagesCollectionViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 10.11.21.
//

import UIKit
import Firebase
import SwiftUI
import CoreData

private let imagesCache = NSCache<NSString, UIImage>()

class ImagesCollectionViewController: UICollectionViewController{
    
    var viewModel: ImagesViewModelProtocol!{
        didSet {
            self.viewModel.imagesDidChange = { [weak self] viewModel in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ImagesViewModel(appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.loadImages()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageItems?.count ?? viewModel.imageEntities?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        if(viewModel.imageItemsExist) {
            let item = viewModel.imageItems![indexPath.item]
            cell.imageView.loadImageUseingUrlString(urlString: item.url)
        } else
        if(viewModel.imageEntitiesExist) {
            if let entity = viewModel.entityBy(objectID: viewModel.imageEntities![indexPath.item].objectID) {
                DispatchQueue.main.async{
                    cell.imageView.image = UIImage(data: entity.data)
                }
            }
        }
        return cell;
    }
    
    private func setupCollectionView(){
        self.collectionView.backgroundColor = .white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        if let layout = self.collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
}

extension ImagesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeOfImageAtIndexPath indexPath: IndexPath) -> CGSize {
        if(viewModel.imageItemsExist){
            if let item = viewModel.imageItems?[indexPath.item]{
                return CGSize(width: Int(item.width), height: Int(item.height))
            }
        }
        if(viewModel.imageEntitiesExist){
            if let entity = viewModel.entityBy(objectID: viewModel.imageEntities![indexPath.item].objectID) {
                return CGSize(width: Int(entity.width), height: Int(entity.height))
            }
        }
        return CGSize(width: 0, height: 0)
    }
    
}
class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUseingUrlString(urlString: String){
        image = nil
        imageUrlString = urlString
        
        if let imageFromCache = imagesCache.object(forKey: urlString as NSString){
            image = imageFromCache
        } else {
            let downloadImageOperation = DownloadImageOperation()
            downloadImageOperation.qualityOfService = .userInitiated
            downloadImageOperation.urlString = urlString
            downloadImageOperation.start()
            downloadImageOperation.completionBlock = { [weak self] in
                guard
                    let self = self,
                    let downloadedImage = downloadImageOperation.downloadedImage
                else {return}
                if(self.imageUrlString == urlString) {
                    DispatchQueue.main.async {
                        // MARK: fix for the common bug when wrong Image is loaded in UICollectionViewCell
                        // For more details check "Swift: YouTube - How to Load Images Async in UICollectionView (Ep 6)"
                        self.image = downloadedImage
                        self.saveImageInCoreData(url: urlString, image: downloadedImage)
                    }
                    imagesCache.setObject(downloadedImage, forKey: urlString as NSString)
                }
            }
        }
    }
    
    private func saveImageInCoreData(url: String, image: UIImage){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.newBackgroundContext()
        guard let data = image.pngData() else {return}
        let entity = Entity(context: viewContext)
        entity.url = url
        entity.data = data
        entity.width = Int16(image.size.width)
        entity.height = Int16(image.size.height)
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

