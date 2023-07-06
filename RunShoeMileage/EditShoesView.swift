//  EditShoesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI

struct EditShoesView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @State var shoes: [ShoeDetailViewModel]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(shoes, id: \.shoe.objectID) { viewModel in
                    NavigationLink(value: viewModel) {
                        EditShoesRowView(shoe: viewModel.shoe)
                    }
                }
                .onDelete { indexSet in
                    let shoesToRemove = indexSet.map { shoes[$0] }
                    shoesToRemove.forEach { shoeStore.remove(shoe: $0.shoe) }
                    shoes = Self.generateViewModelsFromActiveShoes(from: shoeStore)
                }
            }
            .navigationDestination(for: ShoeDetailViewModel.self) { viewModel in
                ShoeDetailView(viewModel: viewModel)
            }
            .navigationTitle("Active Shoes")
        }
    }
}

extension EditShoesView {
    static func generateViewModelsFromActiveShoes(from store: ShoeStore) -> [ShoeDetailViewModel] {
        return store.activeShoes.compactMap { ShoeDetailViewModel(shoe: $0) }
    }
}

struct EditShoesView_Previews: PreviewProvider {
    static var shoes = EditShoesView.generateViewModelsFromActiveShoes(from: ShoeStore())
    static var previews: some View {
        EditShoesView(shoes: shoes)
            .environmentObject(ShoeStore())
    }
}

struct EditShoesRowView: View {
    let shoe: Shoe
    // TODO: Breakout selectedShoeURL from ShoeStore.
    // Deletion is crashing app, since update the shoe store triggers a relayout
    // of the row before the UI deletes it. All values inside of shoe are nil.
    // I temporarily put nil coaelescers to protect from the crash.
    @EnvironmentObject var shoeStore: ShoeStore
    
    var body: some View {
        VStack {
            HStack {
                Text(shoe.brand ?? "")
                Spacer()
            }
            HStack {
                if (shoe.objectID.uriRepresentation() == shoeStore.selectedShoeURL) {
                    Text("Selected")
                        .padding([.trailing], 8)
                }
                Text("Distance: \(NumberFormatter.decimal.string(from: shoe.totalDistance ?? NSNumber(value: 0)) ?? "")")
                Spacer()
            }
        }
        .padding([.trailing], 16)
        .onTapGesture {
            print("tap")
            shoeStore.setSelected(shoe: shoe)
        }
        .animation(.easeInOut, value: shoeStore.selectedShoeURL)
    }
}
