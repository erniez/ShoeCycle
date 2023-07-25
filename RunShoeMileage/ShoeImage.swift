//  ShoeImage.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/3/23.
//  
//

import SwiftUI
import PhotosUI

struct ShoeImage: View {
    @ObservedObject var shoe: Shoe
    @State private var showPhotoPicker = false
    @State private var showImageSelection = false
    @State private var showCamera = false
    @State private var shoeItem: PhotosPickerItem?
    
    var allowImageChange = true
    
    private let imageStore = ImageStore.shared
    
    var body: some View {
            Group {
                if let imagekey = shoe.imageKey,
                   let image = imageStore.image(for: imagekey as NSString) {
                    if allowImageChange {
                        Image(uiImage: image)
                            .shoeImageContent()
                            .shoeImagePicker(shoe: shoe)
                    }
                    else {
                        Image(uiImage: image)
                            .shoeImageContent()
                    }
                }
                else {
                    Image("photo-placeholder")
                        .shoeImageContent()
                        .shoeImagePicker(shoe: shoe)
                }
            }
            
    }
}

struct ShoeImage_Previews: PreviewProvider {
    @State static var shoe = MockShoeGenerator().generateNewShoeWithData()
    static var previews: some View {
        ShoeImage(shoe: shoe)
    }
}

fileprivate extension View {
    func shoeImagePicker(shoe: Shoe) -> some View {
        modifier(ShoeImagePicker(shoe: shoe))
    }
}

fileprivate struct ShoeImagePicker: ViewModifier {
    @EnvironmentObject var shoeStore: ShoeStore
    @ObservedObject var shoe: Shoe
    @State private var showPhotoPicker = false
    @State private var showImageSelection = false
    @State private var showCamera = false
    @State private var shoeItem: PhotosPickerItem?
    
    private let imageStore = ImageStore.shared
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog("Image Picker", isPresented: $showImageSelection) {
                
                Button("Photo Library") {
                    print("Photo Library")
                    showPhotoPicker = true
                }
                
                Button("Camera") {
                    showCamera = true
                    print("Camera")
                }
            }
            .onTapGesture {
                showImageSelection = true
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $shoeItem)
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

fileprivate extension Image {
    func shoeImageContent() -> some View {
        self
            .resizable()
            .aspectRatio(1.4, contentMode: .fill)
            .background(.black)
            .clipShape(.shoeCycleRoundedRectangle)
            .overlay {
                RoundedRectangle.shoeCycleRoundedRectangle
                    .stroke(Color.shoeCycleOrange, lineWidth: 2)
            }
    }
}
