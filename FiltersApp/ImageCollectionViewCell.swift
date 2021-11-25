//
//  ImageCollectionViewCell.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 16.11.21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "Cell"
    
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
    
    func loadImage(url: URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        guard let self = self else {return}
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    private func setupConstraints(){
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

//extension UIImage{
//    convenience init?(url: URL){
//        if let data = try? Data(contentsOf: url) {
//            self.init(data: data)
//        } else{
//            return nil
//        }
//    }
//}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        guard let self = self else {return}
                        self.image = image
                    }
                }
            }
        }
    }
}

