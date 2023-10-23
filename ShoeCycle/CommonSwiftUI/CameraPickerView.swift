//  CameraPickerView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/3/23.
//  
//

import SwiftUI
import OSLog

struct CameraPickerView: UIViewControllerRepresentable {
    let shoe: Shoe
    @Environment(\.presentationMode) var isPresented
    @EnvironmentObject var shoeStore: ShoeStore
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func makeCoordinator() -> CameraPickerDelegate {
        return CameraPickerDelegate(shoeStore: shoeStore, shoe: shoe) {
            isPresented.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class CameraPickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let shoeStore: ShoeStore
    let shoe: Shoe
    let onFinishPicking: () -> Void
    let analytics = AnalyticsFactory.sharedAnalyticsLogger()
    
    init(shoeStore: ShoeStore, shoe: Shoe, onFinishPicking: @escaping () -> Void) {
        self.shoeStore = shoeStore
        self.shoe = shoe
        self.onFinishPicking = onFinishPicking
        super.init()
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage]

        if let image = image as? UIImage {
            analytics.logEvent(name: AnalyticsKeys.Event.shoePictureAddedEvent, userInfo: nil)
            shoe.setThumbnailDataFrom(image, width: 143, height: 96)
            ImageStore.shared.set(image: image, width: 210, height: 140, on: shoe)
            withAnimation {
                shoeStore.saveContext()
            }
        } else {
            Logger.app.error("Could not capture image with camera")
        }
        onFinishPicking()
    }
}

