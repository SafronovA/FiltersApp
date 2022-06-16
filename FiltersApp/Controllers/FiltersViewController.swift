//
//  FiltersViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 25.11.21.
//

import UIKit

class FiltersViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let im = UIImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    private var filtersView: UIView?
    
    private var heightMultiplier: CGFloat {
        guard
            let height = imageView.image?.size.height,
            let width = imageView.image?.size.width
        else {
            return CGFloat(1)
        }
        return CGFloat(height/width)
    }
    
    init(imageData: Data){
        imageView.image = UIImage(data: imageData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImageView(img: UIImage) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            self.imageView.image = img
        }
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
        filtersView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(filtersView)
    }
    
    private func setupConstraints(){
        imageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: heightMultiplier).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        guard let filtersView = self.filtersView else {return}
        filtersView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        filtersView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        filtersView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        filtersView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -1).isActive = true
    }
    
    @objc private func showResult(){
        guard let img = imageView.image else {return}
        self.navigationController?.pushViewController(ResultViewController(image: img), animated: true)
        self.upload(image: img)
    }
    
    private func upload(image: UIImage){
        DispatchQueue.global().async {
            FirebaseService.shared.save(
                data: image.pngData(),
                size: ((Float(image.size.width)), Float(image.size.height)))
        }
    }
}
