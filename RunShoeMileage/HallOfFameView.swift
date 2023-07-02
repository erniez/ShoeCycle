//  HallOfFameView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/7/23.
//  
//

import SwiftUI


// For testing purposes only. So I can launch from Obj-C
@objc class HallOfFameViewFactory: NSObject {
    
    @objc static func create() -> UIViewController {
        let hallOfFameView = HallOfFameView()
        let hostingController = UIHostingController(rootView: hallOfFameView)
        return hostingController
    }
    
}

struct HallOfFameView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    
    var body: some View {
        if shoeStore.hallOfFameShoes.isEmpty {
            Text("You have no shoes in the Hall of Fame. To add one, please edit the shoe you want to add.")
                .multilineTextAlignment(.center)
                .padding()
        }
        else {
            List {
                ForEach(shoeStore.hallOfFameShoes, id: \.objectID) { shoe in
                    HallOfFameRowView(shoe: shoe)
                }
                .onDelete { indexSet in
                    let shoesToRemove = indexSet.map { shoeStore.hallOfFameShoes[$0] }
                    shoesToRemove.forEach { shoeStore.remove(shoe: $0) }
                }
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
    }
}
