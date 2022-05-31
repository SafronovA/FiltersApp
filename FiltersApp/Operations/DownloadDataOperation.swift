//
//  DownloadDataOperation.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 25.05.22.
//

import Foundation

class DownloadDataOperation: AsyncOperation {
    var urlString: String?
    var downloadedData: Data?
    
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
                    let data = data, error == nil
                else {
                    self.finish()
                    return
                }
                self.downloadedData = data
                self.finish()
            }.resume()
        }
    }
}
