//
//  ImagePickerDelegate.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 4/7/19.
//

import Foundation

@objc
class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc var onDidFinishPicking: ((UIImage?) -> Void)?
    
    private let shoe: Shoe
    private lazy var imagePickerController = UIImagePickerController()
    
    @objc
    init(shoe: Shoe) {
        self.shoe = shoe
        super.init()
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let oldKey = shoe.imageKey
        
        // Did the possession already have an image?
        if let oldKey = oldKey {
            // Delete the old image
            ImageStore.default()?.deleteImage(forKey: oldKey)
        }
        
        // Get picked image from info dictionary
        let image = info[.originalImage]
        
        // Create a CFUUID object - it knows how to create unique identifier strings
        let newUniqueID = CFUUIDCreate(kCFAllocatorDefault)
        
        // Create a string from a unique identifier
        let newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID)
        
        // Use that unique ID to set our possessions imageKey
        shoe.imageKey = newUniqueIDString as String?
        
        // Store  image in the ImageStore with this key
        if let image = image as? UIImage {
            AnalyticsLogger.shared().logEvent(withName: kShoePictureAddedEvent, userInfo: nil)
            ImageStore.default()?.setImage(image, withWidth: 210, withHeight: 140, forKey: shoe.imageKey)
            shoe.setThumbnailDataFrom(image, width: 143, height: 96)
            onDidFinishPicking?(image)
        } else {
            onDidFinishPicking?(nil)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func presentImagePickerAlertViewController(presentingViewController: UIViewController) {
        let presentImagePickerController: (UIViewController, UIImagePickerController.SourceType) -> Void = { [weak self] viewController, sourceType in
            guard let self = self else { return }
            self.imagePickerController.sourceType = sourceType
            self.imagePickerController.delegate = self
            viewController.present(self.imagePickerController, animated: true, completion: nil)
            
        }
        let pictureAlertController = UIAlertController(title: "Choose Picture Method", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction.init(title: "Camera", style: .default) { _ in
            presentImagePickerController(presentingViewController, .camera)
        }
        let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in
            presentImagePickerController(presentingViewController, .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        pictureAlertController.addAction(cameraAction)
        pictureAlertController.addAction(libraryAction)
        pictureAlertController.addAction(cancelAction)
        
        presentingViewController.present(pictureAlertController, animated: true, completion: nil)
    }

}
