//
//  ImagesViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 10.11.21.
//

import UIKit
import Firebase
import SwiftUI

class ImagesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: Constants
    private let ref = Database
        .database(url: "https://filtersapp-d0e43-default-rtdb.europe-west1.firebasedatabase.app")
        .reference(withPath: "image-items")
    private var refObservers: [DatabaseHandle] = []
    
    // MARK: Properties
    var items: [ImageItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
//        fillInDB();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell        
//        DispatchQueue.global().async { [weak self, weak cell] in
//            guard let self = self else {return}
//            guard let cell = cell else {return}
//            let image = UIImage(url: URL(string: self.items[indexPath.section].url)!)
//            DispatchQueue.main.async { [weak cell] in
//                guard let cell = cell else {return}
//                cell.imageView.image = image
//            }
//        }
        cell.loadImage(url: URL(string: self.items[indexPath.section].url)!)
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        guard let image = UIImage(url: URL(string: items[indexPath.section].url)!) else {
//            return .zero
//        }
//        let heightOnWidthRatio = image.size.height / image.size.width
        let width = collectionView.bounds.width
//        let height = width * heightOnWidthRatio
//        return CGSize(width: width, height: height)
        return CGSize(width: width, height: width)
    }
    
    private func fillInDB(){
        let imageURLs = [
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
