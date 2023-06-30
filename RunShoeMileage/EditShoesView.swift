//  EditShoesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI

// For testing purposes only. So I can launch from Obj-C
@objc class EditShoesViewFactory: NSObject {
    
    @objc static func create() -> UIViewController {
        let editShoesView = EditShoesView()
        let hostingController = UIHostingController(rootView: editShoesView)
        return hostingController
    }
    
}

struct EditShoesView: View {
    var store = ShoeStore.defaultStore
    @State var shoes = Self.generateViewModelsFromActiveShoes()
    
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
                    shoesToRemove.forEach { store.remove(shoe: $0.shoe) }
                    shoes = Self.generateViewModelsFromActiveShoes()
                }
            }
            .navigationDestination(for: ShoeDetailViewModel.self, destination: ShoeDetailView.init)
            .navigationTitle("Active Shoes")
        }
    }
}

private extension EditShoesView {
    static func generateViewModelsFromActiveShoes() -> [ShoeDetailViewModel] {
        return ShoeStore.defaultStore.activeShoes.compactMap { ShoeDetailViewModel(shoe: $0) }
    }
}

struct EditShoesView_Previews: PreviewProvider {
    static var previews: some View {
        EditShoesView()
    }
}

struct EditShoesRowView: View {
    let shoe: Shoe
    // TODO: Breakout selectedShoeURL from ShoeStore.
    // Deletion is crashing app, since update the shoe store triggers a relayout
    // of the row before the UI deletes it. All values inside of shoe are nil.
    // I temporarily put nil coaelescers to protect from the crash.
    @ObservedObject var store = ShoeStore.defaultStore
    
    var body: some View {
        VStack {
            HStack {
                Text(shoe.brand ?? "")
                Spacer()
            }
            HStack {
                if (shoe.objectID.uriRepresentation() == store.selectedShoeURL) {
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
            store.setSelected(shoe: shoe)
        }
        .animation(.easeInOut, value: store.selectedShoeURL)
    }
}
