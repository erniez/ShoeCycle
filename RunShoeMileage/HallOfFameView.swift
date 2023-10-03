//  HallOfFameView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/7/23.
//  
//

import SwiftUI


struct HallOfFameView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    let selectedShoeStrategy: SelectedShoeStrategy
    
    var body: some View {
        if shoeStore.hallOfFameShoes.isEmpty {
            Text("You have no shoes in the Hall of Fame. Please go to the Active Shoes tab and edit the shoe you want to add.")
                .multilineTextAlignment(.center)
                .padding()
        }
        else {
            NavigationStack {
                List {
                    ForEach(shoeStore.hallOfFameShoes, id: \.objectID) { shoe in
                        NavigationLink(value: shoe) {
                            HallOfFameRowView(shoe: shoe)
                        }
                    }
                    .onDelete { indexSet in
                        let shoesToRemove = indexSet.map { shoeStore.hallOfFameShoes[$0] }
                        shoesToRemove.forEach { shoeStore.remove(shoe: $0) }
                    }
                }
                .navigationDestination(for: Shoe.self) { shoe in
                    if let viewModel = ShoeDetailViewModel(store: shoeStore, shoeURL: shoe.objectID.uriRepresentation()) {
                        ShoeDetailView(viewModel: viewModel,
                                       selectedShoeStrategy: selectedShoeStrategy)
                    }
                }
                .navigationTitle("Hall of Fame Shoes")
            }
        }
    }
}



struct HallOfFameRowView: View {
    let shoe: Shoe
    @EnvironmentObject var settings: UserSettings
    private let distanceUtility = DistanceUtility()
    
    var body: some View {
        VStack {
            HStack {
                Text(shoe.brand)
                Spacer()
            }
            HStack {
                Text("Distance: \(distanceUtility.displayString(for: shoe.totalDistance.doubleValue)) \(settings.distanceUnit.displayString())")
                Spacer()
            }
        }
        .contentShape(Rectangle())
    }
}

