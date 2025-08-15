//  ShoeDetailView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/23/23.
//  
//

import SwiftUI
import PhotosUI

struct ShoeDetailView: View {
    @EnvironmentObject private var shoeStore: ShoeStore
    @State private var state: ShoeDetailState
    @State private var interactor: ShoeDetailInteractor
    @Environment(\.dismiss) var dismiss
    
    private let shoeURL: URL
    private let newShoe: Shoe?
    
    init(shoeURL: URL, newShoe: Shoe? = nil, selectedShoeStrategy: SelectedShoeStrategy? = nil) {
        self.shoeURL = shoeURL
        self.newShoe = newShoe
        let dummyStore = ShoeStore() // Temporary store for initialization
        self._state = State(initialValue: ShoeDetailState(shoeURL: shoeURL, newShoe: newShoe, store: dummyStore))
        self._interactor = State(initialValue: ShoeDetailInteractor(selectedShoeStrategy: selectedShoeStrategy))
    }
    
    var body: some View {
        if let shoe = getShoe() {
            VStack {
                if state.isNewShoe == true {
                    HStack {
                        Button("Cancel") {
                            interactor.handle(state: &state, action: .cancelNewShoe)
                            dismiss()
                        }
                        Spacer()
                        Button("Done") {
                            interactor.handle(state: &state, action: .saveNewShoe)
                            dismiss()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name:")
                    TextField("Shoe Name", text: shoeNameBinding, prompt: Text("Shoe Name"))
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
                        TextField("Start Distance", text: startDistanceBinding)
                            .textFieldStyle(.numberEntry)
                    }
                    .padding([.horizontal], 16)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max:")
                        TextField("Max Distance", text: maxDistanceBinding)
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
                                   selection: startDateBinding,
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
                                   selection: expirationDateBinding,
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
                
                if state.newShoe == nil {
                    HallOfFameSelector(hallOfFameBinding: hallOfFameBinding)
                        .padding([.top], 16)
                    
                    // Delete Button - only for existing shoes
                    Button("Delete Shoe") {
                        interactor.handle(state: &state, action: .deleteShoe)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.red)
                    .cornerRadius(8)
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    .contentShape(Rectangle())
                    .padding([.top], 16)
                }
                
                Spacer()
                
                #if DEBUG
                Button("Generate Histories") {
                    interactor.handle(state: &state, action: .saveNewShoe)
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
            .onAppear {
                interactor.setStore(shoeStore)
                // Recreate state with proper store
                state = ShoeDetailState(shoeURL: shoeURL, newShoe: newShoe, store: shoeStore)
                interactor.handle(state: &state, action: .viewAppeared)
            }
            .onDisappear {
                interactor.handle(state: &state, action: .viewDisappeared)
            }
            .alert("Delete Shoe", isPresented: showDeleteConfirmationBinding) {
                Button("Cancel", role: .cancel) {
                    interactor.handle(state: &state, action: .cancelDelete)
                }
                Button("Delete", role: .destructive) {
                    interactor.handle(state: &state, action: .confirmDelete)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this shoe? This action cannot be undone.")
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
    
    // MARK: - Custom Bindings
    
    private var shoeNameBinding: Binding<String> {
        Binding(
            get: { state.shoeName },
            set: { interactor.handle(state: &state, action: .shoeNameChanged($0)) }
        )
    }
    
    private var startDistanceBinding: Binding<String> {
        Binding(
            get: { state.startDistance },
            set: { interactor.handle(state: &state, action: .startDistanceChanged($0)) }
        )
    }
    
    private var maxDistanceBinding: Binding<String> {
        Binding(
            get: { state.maxDistance },
            set: { interactor.handle(state: &state, action: .maxDistanceChanged($0)) }
        )
    }
    
    private var startDateBinding: Binding<Date> {
        Binding(
            get: { state.startDate },
            set: { interactor.handle(state: &state, action: .startDateChanged($0)) }
        )
    }
    
    private var expirationDateBinding: Binding<Date> {
        Binding(
            get: { state.expirationDate },
            set: { interactor.handle(state: &state, action: .expirationDateChanged($0)) }
        )
    }
    
    private var hallOfFameBinding: Binding<Bool> {
        Binding(
            get: { interactor.getHallOfFameStatus(from: state) },
            set: { interactor.handle(state: &state, action: .hallOfFameToggled($0)) }
        )
    }
    
    private var showDeleteConfirmationBinding: Binding<Bool> {
        Binding(
            get: { state.showDeleteConfirmation },
            set: { newValue in
                if !newValue {
                    interactor.handle(state: &state, action: .cancelDelete)
                }
            }
        )
    }
    
    // Helper method to get shoe using environment object store
    private func getShoe() -> Shoe? {
        if let shoe = newShoe {
            return shoe
        }
        return shoeStore.getShoe(from: shoeURL)
    }
}

struct ShoeDetailView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData(saveData: true)
    
    static var previews: some View {
        ShoeDetailView(shoeURL: shoe.objectID.uriRepresentation(),
                       selectedShoeStrategy: SelectedShoeStrategy(store: ShoeStore(), 
                                                                  settings: UserSettings.shared))
    }
}
