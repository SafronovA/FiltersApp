//
//  DownloadImageOperation.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 5.01.22.
//

import UIKit

class DownloadImageOperation: AsyncOperation {
    var urlString: String?
    var downloadedImage: UIImage?
    
    override func main() {
        DispatchQueue.global().async {[weak self] in
            guard
                let self = self,
                let urlString = self.urlString,
                let url = URL(string: urlString)
            else {
                self?.finish()
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, error == nil,
                    let img = UIImage(data: data)
                else {
                    self.finish()
                    return
                }
                self.downloadedImage = img
                self.finish()
            }.resume()
        }
    }
}
