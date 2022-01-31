//
//  FiltersCollectionViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 29.11.21.
//

import UIKit

private let reuseIdentifier = "Cell"
private let CIFilterNames:[String] = [
    "CIPhotoEffectChrome",
    "CIPhotoEffectFade",
    "CIPhotoEffectInstant",
    "CIPhotoEffectNoir",
    "CIPhotoEffectProcess",
    "CIPhotoEffectTonal",
    "CIPhotoEffectTransfer",
    "CISepiaTone"
]

class FiltersCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var image: UIImage?
    private let filtersCache = NSCache<NSString, UIImage>()
    
    init(collectionViewLayout: UICollectionViewFlowLayout, image: UIImage){
        super.init(collectionViewLayout: collectionViewLayout)
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView!.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.reuseIdentifier)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return CIFilterNames.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.reuseIdentifier, for: indexPath) as! FilterCollectionViewCell
        cell.imageView.image = nil
        let index = indexPath.section
        if(index == 0){
            cell.imageView.image = self.image
            cell.filterLabel.text = "Normal"
        } else {
            let filterName = CIFilterNames[index]
            cell.filterLabel.text = "Filter \(index)"
            if let filterFromCache = filtersCache.object(forKey: filterName as NSString){
                cell.imageView.image = filterFromCache
            } else {
                let filterOperation = FilterOperation()
                filterOperation.qualityOfService = .userInitiated
                filterOperation.filter = filterName
                filterOperation.inputImage = self.image
                filterOperation.start()
                filterOperation.completionBlock = { [weak self, weak cell] in
                    guard
                        let self = self,
                        let cell = cell,
                        let outputImage = filterOperation.outputImage
                    else {return}
                    DispatchQueue.main.async {
                        cell.imageView.image = outputImage
                    }
                    self.filtersCache.setObject(outputImage, forKey: filterName as NSString)
                }
            }
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: height, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let parentVC = self.parent as! FiltersViewController
        let cell = collectionView.cellForItem(at: indexPath) as! FilterCollectionViewCell
        guard let img = cell.imageView.image else {return}
        parentVC.updateImageView(img: img)
    }
}
