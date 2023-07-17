//  HallOfFameSelector.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/7/23.
//  
//

import SwiftUI

struct HallOfFameSelector: View {
    @EnvironmentObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    
    var body: some View {
        HStack {
            Text("🏆")
            Group {
                if shoe.hallOfFame == true {
                    Text("Remove from Hall of Fame")
                        .onTapGesture {
                            shoe.hallOfFame = false
                            shoeStore.saveContext()
                            shoeStore.updateAllShoes()
                        }
                }
                else {
                    Text("Add to Hall of Fame")
                        .onTapGesture {
                            shoe.hallOfFame = true
                            shoeStore.saveContext()
                            shoeStore.updateAllShoes()
                        }
                }
            }
        }
        .animation(.default, value: shoe.hallOfFame)
    }
}

