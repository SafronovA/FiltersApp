//
//  ImageCollectionViewCell.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 16.11.21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ImageCell"
    
    var indexPath: IndexPath?
    
    let imageView: UIImageView = {
        let im = UIImageView()
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
    
    func configure(with data: Data?){
        self.imageView.image = (data != nil) ? UIImage(data: data!): nil
    }
    
    private func setupConstraints(){
        self.imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
