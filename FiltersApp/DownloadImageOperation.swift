//
//  DownloadImageOperation.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 5.01.22.
//

import UIKit

class DownloadImageOperation: Operation {
    var urlString: String?
    var downloadedImage: UIImage?
    var _executing :Bool = false
    var _finished :Bool = false
    
    override var isAsynchronous: Bool{
        return true
    }
    
    override var isExecuting: Bool{
        return _executing
    }
    
    override var isFinished: Bool{
        return _finished
    }
    
    override func start() {
        if(self.isCancelled){
            self.willChangeValue(forKey: "isFinished")
            _finished = true
            self.didChangeValue(forKey: "isFinished")
            return
        }
        self.willChangeValue(forKey: "isExecuting")
        self.main()
        _executing = true
        self.didChangeValue(forKey: "isExecuting")
    }
    
    override func main() {
        DispatchQueue.global().async {[weak self] in
            guard
                let self = self,
                let urlString = self.urlString,
                let url = URL(string: urlString)
            else {
                self?.finishOperation()
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, error == nil,
                    let img = UIImage(data: data)
                else {
                    self.finishOperation()
                    return
                }
                self.downloadedImage = img
                self.finishOperation()
            }.resume()
        }
    }
    
    func finishOperation(){
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        _executing = false
        _finished = true
        self.didChangeValue(forKey: "isExecuting")
        self.didChangeValue(forKey: "isFinished")
    }
}
