//
//  FilterCollectionViewCell.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 28.11.21.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FilterCell"
    
    let imageView: UIImageView = {
        let im = UIImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
//        im.contentMode = .scaleAspectFill
//        im.clipsToBounds = true
        im.layer.cornerRadius = 12
        return im
    }()
    
    let filterLabel: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.textColor = .black
        lab.lineBreakMode = .byWordWrapping
        lab.setContentCompressionResistancePriority(.required, for: .vertical)
        lab.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(imageView)
        contentView.addSubview(filterLabel)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupConstraints(){
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        filterLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        filterLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        filterLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
//        filterLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
