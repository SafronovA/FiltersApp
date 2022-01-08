//
//  FilterOperation.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 29.11.21.
//

import UIKit

class FilterOperation: Operation {
    var filter: String?
    var inputImage: UIImage?
    var outputImage: UIImage?
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
            guard let self = self else {return}
            self.outputImage = self.filter(image: self.inputImage, filter: self.filter)
            self.finishOperation()
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
    
    private func filter(image: UIImage?, filter: String?) -> UIImage?{
        guard let image = image, let filter = filter else { return nil }
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: image)
        guard let filter = CIFilter(name: filter) else { return nil }
        filter.setDefaults()
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter.value(forKey:kCIOutputImageKey) as! CIImage
        guard let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent) else { return nil }
        return UIImage(cgImage: filteredImageRef);
    }
}
