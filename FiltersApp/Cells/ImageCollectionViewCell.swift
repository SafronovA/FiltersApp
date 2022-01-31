//
//  ImageCollectionViewCell.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 16.11.21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ImageCell"
    
    let imageView: CustomImageView = {
        let im = CustomImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
        im.contentMode = .scaleAspectFill
        im.clipsToBounds = true
        im.layer.cornerRadius = 12
        return im
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints(){
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
