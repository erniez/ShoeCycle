//  ShoeImage.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/3/23.
//  
//

import SwiftUI
import PhotosUI

struct ShoeImage: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @ObservedObject var shoe: Shoe
    @State private var showImagePicker = false
    @State private var showImageSelection = false
    @State private var showCamera = false

    @State private var shoeItem: PhotosPickerItem?
    private let imageStore = ImageStore.shared
    
    var body: some View {
        Group {
            if let imagekey = shoe.imageKey,
               let image = imageStore.image(for: imagekey as NSString) {
                Image(uiImage: image)
                    .resizable()
                    .padding(32)
                    .aspectRatio(1.4, contentMode: .fit)
                    .background(.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.shoeCycleOrange, lineWidth: 2)
                    }
            }
            else {
                Image("photo-placeholder")
                    .resizable()
                    .padding(32)
                    .aspectRatio(1.4, contentMode: .fit)
                    .background(.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.shoeCycleOrange, lineWidth: 2)
                    }
            }
        }
        .confirmationDialog("Image Picker", isPresented: $showImageSelection) {
            
            Button("Photo Library") {
                print("Photo Library")
                showImagePicker = true
            }
            
            Button("Camera") {
                showCamera = true
                print("Camera")
            }
        }
        .onTapGesture {
            showImageSelection = true
        }
        .photosPicker(isPresented: $showImagePicker, selection: $shoeItem)
        .onChange(of: shoeItem) { _ in
            print("Shoe Item has changed")
                    Task {
                        if let data = try? await shoeItem?.loadTransferable(type: Data.self),
                           let shoeUIImage = UIImage(data: data) {
                            shoe.setThumbnailDataFrom(shoeUIImage, width: 143, height: 96)
                            imageStore.set(image: shoeUIImage, width: 210, height: 140, on: shoe)
                            withAnimation {
                                // Animate updating the shoe image, which will propagate back to the view.
                                shoeStore.saveContext()
                            }
                            return
                        }
                        print("Failed to create Image")
                    }
                }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(shoe: shoe)
        }
        
    }
}

struct ShoeImage_Previews: PreviewProvider {
    @State static var shoe = MockShoeGenerator().generateNewShoeWithData()
    static var previews: some View {
        ShoeImage(shoe: shoe)
    }
}
