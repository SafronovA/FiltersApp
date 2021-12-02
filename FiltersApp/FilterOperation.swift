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
    
    override func main() {
        outputImage = filter(image: inputImage, filter: filter)
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
