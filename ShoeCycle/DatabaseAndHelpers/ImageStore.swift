//  ImageStore.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/2/23.
//  
//

import Foundation
import OSLog


class ImageStore {
    static let shared = ImageStore()
    
    let imageCache = NSCache<NSString, UIImage>()
    
    func set(image: UIImage, width: Int, height: Int, on shoe: Shoe) {
        let newUniqueID = UUID().uuidString
        
        let originalImageSize = image.size
        let newImageRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        let ratio = Double.maximum(newImageRect.size.width / originalImageSize.width,
                                   newImageRect.size.height / originalImageSize.height)
        
        UIGraphicsBeginImageContext(newImageRect.size)
        
        var projectRect = CGRect()
        projectRect.size.width = ratio * originalImageSize.width
        projectRect.size.height = ratio * originalImageSize.height
        projectRect.origin.x = (newImageRect.size.width - projectRect.size.width) / 2.0
        projectRect.origin.y = (newImageRect.size.height - projectRect.size.height) / 2.0
        
        image.draw(in: projectRect)
        
        let reducedImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        imageCache.setObject(reducedImage, forKey: newUniqueID as NSString)
        guard let imagePath = FileHelpers.pathInDocumentDirectory(with: newUniqueID),
              let imageJPEG = reducedImage.jpegData(compressionQuality: 0.5) else {
            Logger.app.error("Could not create image to save")
            return
        }
        
        do {
            let imageURL = URL(fileURLWithPath: imagePath)
            try imageJPEG.write(to: imageURL)
        }
        catch let error {
            Logger.app.error("Could not write immage to disk: \(error)")
            return
        }
        
        // If everything goes smoothly, update the shoe image key.
        
        // Did the shoe already have an image? Let's delete it first.
        if let oldKey = shoe.imageKey {
            deleteImage(for: oldKey)
        }

        shoe.imageKey = newUniqueID
    }
    
    // TODO: create a broken image icon to return on errors.
    func image(for key: String) -> UIImage? {
        if let image = imageCache.object(forKey: key as NSString) {
            return image
        }
        guard let filePath = FileHelpers.pathInDocumentDirectory(with: key) else {
            Logger.app.error("Could not generate document file path")
            return UIImage()
        }
        let image = UIImage(contentsOfFile: filePath)
        return image
    }
    
    func deleteImage(for key: String) {
        imageCache.removeObject(forKey: key as NSString)
        guard let filePath = FileHelpers.pathInDocumentDirectory(with: key) else {
            Logger.app.error("Could not generate document file path")
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch let error {
            Logger.app.error("Could not remove image file: \(error)")
        }
    }
}
