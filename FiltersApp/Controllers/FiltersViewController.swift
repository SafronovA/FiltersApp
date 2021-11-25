//
//  FiltersViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 25.11.21.
//

import UIKit
import SwiftUI

class FiltersViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let im = UIImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
//        im.contentMode = .scaleAspectFill
//        im.clipsToBounds = true
//        im.layer.cornerRadius = 12
        return im
    }()
    
    init(image: UIImage){
        print("FiltersViewController - init called")
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        setupConstraints()
    }
    
    private func setupConstraints(){
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
}
