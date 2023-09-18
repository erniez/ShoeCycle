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
                    shoesToRemove.forEach { shoeStore.remove(shoe: $0.shoe) }
                    shoes = Self.generateViewModelsFromActiveShoes(from: shoeStore)
                }
            }
            .navigationDestination(for: Shoe.self) { shoe in
                ShoeDetailView(viewModel: ShoeDetailViewModel(shoe: shoe))
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
            ShoeDetailView(viewModel: ShoeDetailViewModel(shoe: shoe, isNewShoe: true))
        }
    }
}

extension ActiveShoesView {
    static func generateViewModelsFromActiveShoes(from store: ShoeStore) -> [ShoeDetailViewModel] {
        return store.activeShoes.compactMap { ShoeDetailViewModel(shoe: $0) }
    }
}

struct ActiveShoesView_Previews: PreviewProvider {
    static var shoes = ActiveShoesView.generateViewModelsFromActiveShoes(from: ShoeStore())
    static var previews: some View {
        ActiveShoesView(shoes: shoes)
            .environmentObject(ShoeStore())
    }
}

struct ActiveShoesRowView: View {
    let shoe: Shoe
    // TODO: Breakout selectedShoeURL from ShoeStore.
    // Deletion is crashing app, since update the shoe store triggers a relayout
    // of the row before the UI deletes it. All values inside of shoe are nil.
    // I temporarily put nil coaelescers to protect from the crash.
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    var isSelected: Bool {
        shoeStore.isSelected(shoe: shoe)
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
                Text("Distance: \(distanceUtility.displayString(for: shoe.totalDistance.doubleValue)) \(settings.distanceUnit.displayString())")
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .padding([.trailing], 16)
        .onTapGesture {
            shoeStore.setSelected(shoe: shoe)
            shoeStore.updateSelectedShoe()
        }
        .animation(.linear, value: shoeStore.selectedShoeURL)
    }
}
