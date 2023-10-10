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
        return lhs.shoeURL == rhs.shoeURL
    }
    
    @Published var shoeName: String {
        didSet {
            hasChanged = true
        }
    }
    @Published var startDistance: String {
        didSet {
            hasChanged = true
        }
    }
    @Published var maxDistance: String {
        didSet {
            hasChanged = true
        }
    }
    @Published var startDate: Date {
        didSet {
            hasChanged = true
        }
    }
    @Published var expirationDate: Date {
        didSet {
            hasChanged = true
        }
    }
    
    var isNewShoe: Bool {
        return newShoe != nil
    }
    
    var hallOfFame: Bool {
        get {
            guard let shoe = getShoe() else {
                return false
            }
            return shoe.hallOfFame
        }
        set {
            guard let shoe = getShoe() else {
                return
            }
            shoe.hallOfFame = newValue
        }
    }
    
    let shoeURL: URL
    let newShoe: Shoe?
    @Published var hasChanged = false
    
    private let store: ShoeStore
    private let distanceUtility = DistanceUtility()
    
    init?(store: ShoeStore, shoeURL: URL, newShoe: Shoe? = nil) {
        self.shoeURL = shoeURL
        self.store = store
        if let shoe = newShoe {
            shoeName = shoe.brand
            startDistance = distanceUtility.displayString(for: shoe.startDistance.doubleValue)
            maxDistance = distanceUtility.displayString(for: shoe.maxDistance.doubleValue)
            startDate = shoe.startDate
            expirationDate = shoe.expirationDate
        }
        else {
            guard let shoe = store.getShoe(from: shoeURL) else {
                return nil
            }
            shoeName = shoe.brand
            startDistance = distanceUtility.displayString(for: shoe.startDistance.doubleValue)
            maxDistance = distanceUtility.displayString(for: shoe.maxDistance.doubleValue)
            startDate = shoe.startDate
            expirationDate = shoe.expirationDate
        }
        self.newShoe = newShoe
    }
    
    /**
     Picks which shoe to update. If it's a new shoe, we update that one.
     Otherwise, we update the one pointed to by the URL, if it still exists.
     If neither shoe exists, we return with no action.
    */
    func updateShoeValues() {
        let shoeToUpdate: Shoe?
        if isNewShoe {
            shoeToUpdate = newShoe
        }
        else {
            shoeToUpdate = store.getShoe(from: shoeURL)
        }
        
        guard let shoe = shoeToUpdate else {
            return
        }
        shoe.brand = shoeName
        shoe.startDistance = NSNumber(value: distanceUtility.distance(from: startDistance))
        shoe.maxDistance = NSNumber(value: distanceUtility.distance(from: maxDistance))
        shoe.startDate = startDate
        shoe.expirationDate = expirationDate
    }
    
    func getShoe() -> Shoe? {
        if let shoe = newShoe {
            return shoe
        }
        return store.getShoe(from: shoeURL)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shoeURL)
    }
}

struct ShoeDetailView: View {
    @EnvironmentObject private var shoeStore: ShoeStore
    @ObservedObject var viewModel: ShoeDetailViewModel
    @Environment(\.dismiss) var dismiss
    let selectedShoeStrategy: SelectedShoeStrategy?
    
    init(viewModel: ShoeDetailViewModel, selectedShoeStrategy: SelectedShoeStrategy? = nil) {
        self.viewModel = viewModel
        self.selectedShoeStrategy = selectedShoeStrategy
    }
    
    var body: some View {
        if let shoe = viewModel.getShoe() {
            VStack {
                if viewModel.isNewShoe == true {
                    HStack {
                        Button("Cancel") {
                            if let shoe = viewModel.newShoe {
                                shoeStore.remove(shoe: shoe)
                            }
                            dismiss()
                        }
                        Spacer()
                        Button("Done") {
                            updateShoes(viewModel: viewModel)
                            dismiss()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name:")
                    TextField("Shoe Name", text: $viewModel.shoeName, prompt: Text("Shoe Name"))
                        .textFieldStyle(TextEntryStyle())
                        .padding([.bottom], 8)
                }
                .padding([.horizontal, .top], 16)
                .foregroundColor(.white)
                .shoeCycleSection(title: "Shoe", color: .shoeCycleOrange, image: Image("shoe"))
                .fixedSize(horizontal: false, vertical: true)
                
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
                .foregroundColor(.white)
                .shoeCycleSection(title: "Distance", color: .shoeCycleGreen, image: Image("steps"))
                .fixedSize(horizontal: false, vertical: true)
                
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
                .shoeCycleSection(title: "Wear Time", color: .shoeCycleBlue, image: Image("clock"))
                .fixedSize(horizontal: false, vertical: true)
                
                ShoeImage(shoe: shoe)
                    .padding([.horizontal], 32)
                
                if viewModel.newShoe == nil {
                    HallOfFameSelector(viewModel: viewModel)
                        .padding([.top], 16)
                }
                
                Spacer()
                
                #if DEBUG
                Button("Generate Histories") {
                    updateShoes(viewModel: viewModel)
                    MockShoeGenerator(store: shoeStore).addRunHistories(to: shoe, saveData: true)
                    shoeStore.updateAllShoes()
                    dismiss()
                }
                #endif
                
                Spacer()
            }
            // Need the font size limiter here because this view can launch modally, out of the app view heirarchy
            .dynamicTypeSize(.medium ... .xLarge)
            .padding([.horizontal], 16)
            .background(.patternedBackground)
            .onTapGesture {
                dismissKeyboard()
            }
            .onDisappear {
                if viewModel.isNewShoe == false, viewModel.hasChanged == true {
                    updateShoes(viewModel: viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard, edges: [.bottom])
        }
        else {
            Text("Error: Shoe does not exist.")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        
    }
    
    // TODO: Move this business logic into an interactor
    func updateShoes(viewModel: ShoeDetailViewModel) {
        viewModel.updateShoeValues()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        selectedShoeStrategy?.updateSelectedShoe()
    }
}

struct ShoeDetailView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData(saveData: true)
    static let viewModel = ShoeDetailViewModel(store: ShoeStore(), shoeURL: shoe.objectID.uriRepresentation())!
    
    static var previews: some View {
        ShoeDetailView(viewModel: viewModel,
                       selectedShoeStrategy: SelectedShoeStrategy(store: ShoeStore(), 
                                                                  settings: UserSettings.shared))
    }
}
