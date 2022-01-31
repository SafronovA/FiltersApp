//
//  FinalImageViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 1.12.21.
//

import UIKit

class ResultViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let im = UIImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
        return im
    }()
    
    init(image: UIImage){
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(imageView)
        self.setupRightBarButtonItem()
        self.setupConstraints()
    }
    
    private func setupRightBarButtonItem(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(showActivityView))
    }
    
    @objc private func showActivityView(){
        guard let img = self.imageView.image else {return}
        let activityVC = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        self.present(activityVC, animated: true, completion: nil)
    }
    
    private func setupConstraints(){
        imageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
}
