//  HallOfFameView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/7/23.
//  
//

import SwiftUI


struct HallOfFameView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    
    var body: some View {
        if shoeStore.hallOfFameShoes.isEmpty {
            Text("You have no shoes in the Hall of Fame. To add one, please edit the shoe you want to add.")
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
                    ShoeDetailView(viewModel: ShoeDetailViewModel(shoe: shoe))
                }
                .navigationTitle("Hall of Fame Shoes")
            }
        }
    }
}

struct HallOfFameRowView: View {
    let shoe: Shoe
    
    var body: some View {
        VStack {
            HStack {
                Text(shoe.brand)
                Spacer()
            }
            HStack {
                Text("Distance: \(NumberFormatter.decimal.string(from: shoe.totalDistance) ?? "")")
                Spacer()
            }
        }
        .contentShape(Rectangle())
    }
}

struct HallOfFameView_Previews: PreviewProvider {
    static var previews: some View {
        HallOfFameView()
            .environmentObject(ShoeStore())
    }
}
