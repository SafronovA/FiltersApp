//
//  ImagesCollectionViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 10.11.21.
//

import UIKit

class ImagesCollectionViewController: UICollectionViewController{
    
    var viewModel: ImagesViewModelProtocol!{
        didSet {
            self.viewModel.imagesDidChange = { [weak self] in
                guard let self = self else {return}
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
        self.viewModel.loadImages()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return viewModel.imagesCount
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.configure(with: nil)
        cell.indexPath = indexPath
        viewModel.loadImage(for: indexPath, completion: {data in
            DispatchQueue.main.async {
                // MARK: fix for the common bug when wrong Image is loaded in UICollectionViewCell
                // For more details check "Swift: YouTube - How to Load Images Async in UICollectionView (Ep 6)"
                guard cell.indexPath == indexPath else {return}
                cell.configure(with: data)
            }
        })
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
        return viewModel.sizeOfImage(at: indexPath)
    }
}
