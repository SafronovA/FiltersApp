//
//  FiltersViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 25.11.21.
//

import UIKit
import Firebase
import SwiftUI

class FiltersViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let im = UIImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    private var filtersView: UIView?
    
    init(image: UIImage){
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateImageView(img: UIImage) {
        imageView.image! = img
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Edit"
        self.view.addSubview(imageView)
        self.setupRightBarButtonItem()
        self.setupFiltersView()
        self.setupConstraints()
    }
    
    private func setupRightBarButtonItem(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target:self, action: #selector(showResult))
    }
    
    private func setupFiltersView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        guard let image = imageView.image else {return}
        let filtersVC = FiltersCollectionViewController(collectionViewLayout: layout, image: image)
        self.addChild(filtersVC)
        guard let filtersView = filtersVC.view else {
            print("filtersView is nil")
            return
        }
        self.filtersView = filtersView
        filtersView.backgroundColor = .red
        filtersView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(filtersView)
    }
    
    private func setupConstraints(){
        imageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        guard let filtersView = filtersView else {return}
        filtersView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        filtersView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        filtersView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        filtersView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -1).isActive = true
    }
    
    @objc private func showResult(){
        guard let img = imageView.image else {return}
        self.navigationController?.pushViewController(ResultViewController(image: img), animated: true)
        self.uploadImage(img)
    }
    
    private func uploadImage(_ img: UIImage){
        DispatchQueue.global().async {
            let storageRef = Storage.storage().reference().child(FirebaseConstants.pathToImages).child("image\(UUID().uuidString).png")
            if let uploadData = img.pngData(){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {                        return}
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print(error)
                        } else {
                            guard let url = url?.absoluteString else {return}
                            Database
                                .database(url: FirebaseConstants.databaseUrl)
                                .reference(withPath: FirebaseConstants.pathToImageItems)
                                .child(UUID().uuidString)
                                .setValue(ImageItem(url: url).toAnyObject())
                        }
                    }
                })
            }
        }
    }
}
