//  HallOfFameSelector.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/7/23.
//  
//

import SwiftUI

struct HallOfFameSelector: View {
    @ObservedObject var viewModel: ShoeDetailViewModel
    
    var body: some View {
        HStack {
            Text("🏆")
            Group {
                if viewModel.shoe.hallOfFame == true {
                    Text("Remove from Hall of Fame")
                        .onTapGesture {
                            viewModel.shoe.hallOfFame = false
                            viewModel.hasChanged = true
                        }
                }
                else {
                    Text("Add to Hall of Fame")
                        .onTapGesture {
                            viewModel.shoe.hallOfFame = true
                            viewModel.hasChanged = true
                        }
                }
            }
        }
        .animation(.default, value: viewModel.shoe.hallOfFame)
    }
}

