//
//  AddImageViewController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 10.11.21.
//

import UIKit
import Photos
import PhotosUI
import Firebase

class AddImageViewController: UIViewController {
    
    //    private let ref = Database.database().reference(withPath: "image-items")
    //    private var refObservers: [DatabaseHandle] = []
    
//    private let imageView: UIImageView = {
//        let im = UIImageView()
//        im.translatesAutoresizingMaskIntoConstraints = false
//        im.contentMode = .scaleAspectFill
//        im.clipsToBounds = true
//        im.layer.cornerRadius = 12
//        return im
//    }()
    
    private let fromGaleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("From Galery", for: .normal)
        button.addTarget(self, action: #selector(addImageFromGalery), for: .touchUpInside)
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Download", for: .normal)
        button.addTarget(self, action: #selector(downloadImage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(fromGaleryButton)
        view.addSubview(downloadButton)
        
        setupConstraints()
    }
    
    @objc func addImageFromGalery(sender: UIButton!) {
        print("fromGaleryButton tapped")
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] (status) in
            DispatchQueue.main.async { [weak self] in
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .notDetermined {
                    print("PERMISSION notDetermined")
                }
                if photos == .authorized {
                    print("PERMISSION authorized")
                    self?.showImagePicker()
                }
                if photos == .restricted {
                    print("PERMISSION restricted")
                }
                if photos == .denied {
                    print("PERMISSION denied")
                }
                if photos == .limited {
                    print("PERMISSION limited")
                }
            }
        }
    }
    
    @objc func downloadImage(sender: UIButton!) {
        print("downloadButton tapped")
        
        DispatchQueue.global().async {
            print("downloadImage - STARTED")
            
            print("downloadImage - FINISHED")
        }
        
    }
    
    private func setupConstraints(){
        let buttonHeight: CGFloat = 50
        let centerYAnchorConstantABS: CGFloat = buttonHeight + 20
        fromGaleryButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        fromGaleryButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        fromGaleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fromGaleryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -centerYAnchorConstantABS).isActive = true
        
        downloadButton.heightAnchor.constraint(equalTo: fromGaleryButton.heightAnchor).isActive = true
        downloadButton.widthAnchor.constraint(equalTo: fromGaleryButton.widthAnchor).isActive = true
        downloadButton.centerXAnchor.constraint(equalTo: fromGaleryButton.centerXAnchor).isActive = true
        downloadButton.centerYAnchor.constraint(equalTo: fromGaleryButton.centerYAnchor, constant: centerYAnchorConstantABS).isActive = true
    }
    
    private func showImagePicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
}

extension AddImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            //            imageView.image = image
            print("OPEN FiltersViewController")
            let vc: FiltersViewController = FiltersViewController(image: image)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
