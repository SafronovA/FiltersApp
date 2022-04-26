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
    
    private var items: [ImageItem] = []
    
    var viewModel: ImagesViewModelProtocol!{
        didSet {
            self.viewModel.imagesDidChange = { [weak self] viewModel in
                guard let self = self, let images = viewModel.images else {return}
                self.items = images
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ImagesViewModel()
        self.setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getImages()
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
