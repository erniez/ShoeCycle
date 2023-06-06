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
    @ObservedObject var store = ShoeStore.defaultStore
    
    var body: some View {
        List {
            ForEach(store.activeShoes, id: \.objectID) { shoe in
                EditShoesRowView(shoe: shoe)
            }
            .onDelete { indexSet in
                let shoesToRemove = indexSet.map { store.activeShoes[$0] }
                shoesToRemove.forEach { store.remove(shoe: $0) }
            }
        }
    }
}

struct EditShoesView_Previews: PreviewProvider {
    static var previews: some View {
        EditShoesView()
    }
}

struct EditShoesRowView: View {
    let shoe: Shoe
    @ObservedObject var store = ShoeStore.defaultStore
    
    var body: some View {
        VStack {
            HStack {
                Text(shoe.brand)
                Spacer()
            }
            HStack {
                if (shoe.objectID.uriRepresentation() == store.selectedShoeURL) {
                    Text("Selected")
                        .padding([.trailing], 8)
                }
                Text("Distance: \(NumberFormatter.decimal.string(from: shoe.totalDistance) ?? "")")
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("tap")
            store.setSelected(shoe: shoe)
        }
        .animation(.easeInOut, value: store.selectedShoeURL)
    }
}
