//  ShoeDetailView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/23/23.
//  
//

import SwiftUI
import PhotosUI

class ShoeDetailViewModel: ObservableObject, Hashable {
    
    static func == (lhs: ShoeDetailViewModel, rhs: ShoeDetailViewModel) -> Bool {
        return lhs.shoe.objectID == rhs.shoe.objectID
    }
    
    @Published var shoeName: String
    @Published var startDistance: String
    @Published var maxDistance: String
    @Published var startDate: Date
    @Published var expirationDate: Date
    let shoe: Shoe
    let isNewShoe: Bool
    
    init(shoe: Shoe, isNewShoe: Bool = false) {
        self.shoe = shoe
        shoeName = shoe.brand
        startDistance = shoe.startDistance.stringValue
        maxDistance = shoe.maxDistance.stringValue
        startDate = shoe.startDate
        expirationDate = shoe.expirationDate
        self.isNewShoe = isNewShoe
    }
    
    func updateShoeValues() {
        shoe.brand = shoeName
        if let startDistanceDigits = Double(startDistance) {
            shoe.startDistance = NSNumber(value: startDistanceDigits)
        }
        if let maxDistanceDigits = Double(maxDistance) {
            shoe.maxDistance = NSNumber(value: maxDistanceDigits)
        }
        shoe.startDate = startDate
        shoe.expirationDate = expirationDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shoe.objectID)
    }
}

struct ShoeDetailView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @ObservedObject var viewModel: ShoeDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            PatternedBackground()
            VStack {
                if viewModel.isNewShoe == true {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        Spacer()
                        Button("Done") {
                            viewModel.updateShoeValues()
                            shoeStore.saveContext()
                            shoeStore.updateAllShoes()
                            dismiss()
                        }
                    }
                }
                SettingsOptionView(optionText: "Shoe", color: .shoeCycleOrange, image: Image("shoe")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name:")
                        TextField("Shoe Name", text: $viewModel.shoeName, prompt: Text("Shoe Name"))
                            .textFieldStyle(TextEntryStyle())
                    }
                    .foregroundColor(.white)
                    .padding([.horizontal], 16)
                }
                .padding([.top], 16)
                .fixedSize(horizontal: false, vertical: true)
                SettingsOptionView(optionText: "Distance", color: .shoeCycleGreen, image: Image("steps")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start:")
                            TextField("Start Distance", text: $viewModel.startDistance)
                                .textFieldStyle(.numberEntry)
                        }
                        .padding([.horizontal], 16)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Max:")
                            TextField("Max Distance", text: $viewModel.maxDistance)
                                .textFieldStyle(.numberEntry)
                        }
                        .padding([.horizontal], 16)
                    }
                }
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                SettingsOptionView(optionText: "Wear Time", color: .shoeCycleBlue, image: Image("clock")) {
                    VStack {
                        HStack {
                            Text("Start:")
                            Spacer()
                            DatePicker("Start Date",
                                       selection: $viewModel.startDate,
                                       displayedComponents: [.date])
                            .accentColor(.shoeCycleOrange)
                            .foregroundColor(.white)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(8)
                        }
                        HStack {
                            Text("End:")
                            Spacer()
                            DatePicker("Expiration Date",
                                       selection: $viewModel.expirationDate,
                                       displayedComponents: [.date])
                            .accentColor(.shoeCycleOrange)
                            .foregroundColor(.white)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .foregroundColor(.white)
                }
                .fixedSize(horizontal: false, vertical: true)
                ShoeImage(shoe: viewModel.shoe)
                HallOfFameSelector()
                    .padding([.top], 16)
                    .environmentObject(viewModel.shoe)
                
                Spacer()
            }
            .padding([.horizontal], 16)
        }
    }
}

struct ShoeDetailView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData()
    static let viewModel = ShoeDetailViewModel(shoe: shoe)
    
    static var previews: some View {
        ShoeDetailView(viewModel: viewModel)
    }
}
