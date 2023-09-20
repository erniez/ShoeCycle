//  ActiveShoesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI

struct ActiveShoesView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    @State var shoes: [ShoeDetailViewModel]
    @State var presentNewShoeView = false
    private var selectedShoeStrategy: SelectedShoeStrategy
    
    init(shoes: [ShoeDetailViewModel], presentNewShoeView: Bool = false, selectedShoeStrategy: SelectedShoeStrategy) {
        self.shoes = shoes
        self.presentNewShoeView = presentNewShoeView
        self.selectedShoeStrategy = selectedShoeStrategy
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(shoeStore.activeShoes, id: \.objectID) { shoe in
                    NavigationLink(value: shoe) {
                        ActiveShoesRowView(shoe: shoe)
                    }
                }
                .onDelete { indexSet in
                    let shoesToRemove = indexSet.map { shoes[$0] }
                    shoesToRemove.forEach { viewModel in
                        print(viewModel.shoe.objectID)
                        if let index = shoes.firstIndex(of: viewModel) {
                            shoes.remove(at: index)
                        }
                    }
                    shoesToRemove.forEach { shoeStore.remove(shoe: $0.shoe) }
                    shoes = Self.generateViewModelsFromActiveShoes(from: shoeStore)
                    selectedShoeStrategy.updateSelectedShoe()
                }
            }
            .navigationDestination(for: Shoe.self) { shoe in
                ShoeDetailView(viewModel: ShoeDetailViewModel(shoe: shoe),
                               selectedShoeStrategy: selectedShoeStrategy)
            }
            .navigationTitle("Active Shoes")
            .toolbar {
                Button("Add Shoe") {
                    presentNewShoeView = true
                }
            }
            .background(.patternedBackground)
        }
        .fullScreenCover(isPresented: $presentNewShoeView, onDismiss: {
            // Update view models to account for an added shoe
            shoes = Self.generateViewModelsFromActiveShoes(from: shoeStore)
        }) {
            let shoe = shoeStore.createShoe()
            ShoeDetailView(viewModel: ShoeDetailViewModel(shoe: shoe, isNewShoe: true),
                           selectedShoeStrategy: selectedShoeStrategy)
        }
        .onAppear {
            selectedShoeStrategy.updateSelectedShoe()
        }
    }
}

extension ActiveShoesView {
    static func generateViewModelsFromActiveShoes(from store: ShoeStore) -> [ShoeDetailViewModel] {
        return store.activeShoes.compactMap { shoe in
            return ShoeDetailViewModel(shoe: shoe)
        }
    }
}

struct ActiveShoesView_Previews: PreviewProvider {
    static var shoes = ActiveShoesView.generateViewModelsFromActiveShoes(from: ShoeStore())
    static var shoeStore = ShoeStore()
    
    static var previews: some View {
        ActiveShoesView(shoes: shoes,
                        selectedShoeStrategy: SelectedShoeStrategy(store: shoeStore, settings: UserSettings.shared))
            .environmentObject(shoeStore)
    }
}

struct ActiveShoesRowView: View {
    let shoe: Shoe
    // TODO: Look into the following problem closer. It's a code smell to me.
    // Selection of a row after a Deletion is crashing app. It appears the deleted cell
    // is still in memory somehow, and it crashes the app when the row trys to render,
    // because the shoe has been deleted and its values are nil.
    // I've put nil coalescers in as a bandaid.
    @EnvironmentObject var settings: UserSettings
    var isSelected: Bool {
        settings.isSelected(shoe: shoe)
    }
    private let distanceUtility = DistanceUtility()
    
    var body: some View {
        VStack {
            HStack {
                Text(shoe.brand ?? "")
                    .font(.title2)
                    .bold(isSelected)
                Spacer()
            }
            HStack {
                if isSelected == true {
                    Text("Selected")
                        .padding([.trailing], 8)
                        .foregroundColor(.shoeCycleOrange)
                }
                Text("Distance: \(distanceUtility.displayString(for: shoe.totalDistance?.doubleValue ?? 0.0)) \(settings.distanceUnit.displayString())")
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .padding([.trailing], 16)
        .onTapGesture {
            settings.setSelected(shoe: shoe)
        }
        .animation(.linear, value: settings.selectedShoeURL)
    }
}
