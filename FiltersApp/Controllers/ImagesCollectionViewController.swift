//
//  ImagesCollectionViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 10.11.21.
//

import UIKit
import Firebase
import SwiftUI

private let imagesCache = NSCache<NSString, UIImage>()

class ImagesCollectionViewController: UICollectionViewController{
    
    private let ref = Database
        .database(url: FirebaseConstants.databaseUrl)
        .reference(withPath: FirebaseConstants.pathToImageItems)
    private var refObservers: [DatabaseHandle] = []
    private var items: [ImageItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = self.collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        self.collectionView.backgroundColor = .white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(ImageCollectionViewCell.self,
                                     forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: call fillInDB() to add initial data in Data Base
        //        fillInDB();
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
                    self.items = newItems
                    
                    self.collectionView.reloadData()
                })
            self.refObservers.append(completed)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.loadImageUseingUrlString(urlString: self.items[indexPath.item].url)
        return cell;
    }
    
    private func fillInDB(){
        let imageURLs = [
            "https://carsweek.ru/upload/iblock/bda/bda7e2beb0c69851cdc0dea4dd612b50.jpg",
            "https://a.d-cd.net/4ee2w/960.jpg",
            "https://cdn.pixabay.com/photo/2021/08/25/20/42/field-6574455__480.jpg",
            "https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8&w=1000&q=80",
            "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1000&q=80",
            "https://media.istockphoto.com/photos/very-closeup-view-of-amazing-domestic-pet-in-mirror-round-fashion-is-picture-id1281804798?b=1&k=20&m=1281804798&s=170667a&w=0&h=HIWbeaP_cQSngCz7l9t3xwyE2eyzVgIy3K6xIqPhJQA=",
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8Dui-CG5_VcIxTHxks0tTiME_1rIvYeIfMA&usqp=CAU",
            "https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F5faad4255239c9448d6c7bcd%2F0x0.jpg",
            "https://sun9-62.userapi.com/impf/c854320/v854320580/35a46/SWIQ1iW81nw.jpg?size=807x535&quality=96&sign=4c6e3859443348636c530a514e8e07a4&type=album"
        ]
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {return}
            for im in imageURLs {
                self.ref.child(UUID().uuidString).setValue(ImageItem(url: im).toAnyObject())
            }
        }
    }
}

extension ImagesCollectionViewController: PinterestLayoutDelegate {
    
    private func imageSize(url: String) -> CGSize{
        if let imageSource = CGImageSourceCreateWithURL(URL(string: url)! as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                return CGSize(width: imageProperties[kCGImagePropertyPixelWidth] as! CGFloat,
                              height: imageProperties[kCGImagePropertyPixelHeight] as! CGFloat)
            }
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, sizeOfImageAtIndexPath indexPath: IndexPath) -> CGSize {
        return imageSize(url: self.items[indexPath.item].url)
        
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
                    }
                    imagesCache.setObject(downloadedImage, forKey: urlString as NSString)
                }
            }
        }
    }
}
