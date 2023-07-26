//  AddDistanceView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/6/23.
//  
//

import SwiftUI

struct AddDistanceView: View {
    @State private var runDate = Date()
    @State private var runDistance = ""
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    let screenWidth = UIScreen.main.bounds.size.width
    let minimumDrag: CGFloat = 20
    
    var body: some View {
        if shoeStore.selectedShoe != nil {
            let progressBarWidth = screenWidth * 0.60
            VStack {
                HStack {
                    Image("logo")
                    Spacer()
                    ShoeImageView(shoe: shoe, width: 150, height: 100)
                        .offset(x: 0, y: 16)
                        .gesture(DragGesture(minimumDistance: minimumDrag)
                            .onEnded({ value in
                                let translation = value.translation
                                guard abs(translation.height) > abs(translation.width) else {
                                    return
                                }
                             
                                handleVerticalSwipe(translationHeight: translation.height)
                            }))
                    Image("scroll-arrows")
                        .padding(.leading, 8)
                }
                .padding(16)
                .onTapGesture {
                    dismissKeyboard()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.sectionBackground)
                    DateDistanceEntryView(runDate: $runDate, runDistance: $runDistance, shoe: shoe)
                }
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                ShoeCycleDistanceProgressView(progressWidth: progressBarWidth, value: shoe.totalDistance.floatValue, endvalue: shoe.maxDistance.intValue)
                    .padding([.horizontal], 16)
                ShoeCycleDateProgressView(progressWidth: progressBarWidth, viewModel: DateProgressViewModel(startDate: shoe.startDate, endDate: shoe.expirationDate))
                    .padding([.horizontal], 16)
                RunHistoryChart(collatedHistory: Shoe.collateRunHistories(Array(shoe.history), ascending: true))
                    .padding(16)
                Spacer()
            }
            .background(PatternedBackground())
            .dynamicTypeSize(.medium ... .xLarge)
        }
        else {
            // Shouldn't ever see this
            Text("Something went wrong")
        }
    }
    
    func handleVerticalSwipe(translationHeight: Double) {
        switch translationHeight {
        case -Double.infinity ..< -minimumDrag: // Swipe up
            print("UP")
            if let shoeIndex = shoeStore.activeShoes.firstIndex(of: shoe), shoeIndex > 0 {
                shoeStore.setSelected(shoe: shoeStore.activeShoes[shoeIndex - 1])
                shoeStore.updateSelectedShoe()
            }
        case minimumDrag ..< Double.infinity:  // Swipe down
            print("DOWN")
            if let shoeIndex = shoeStore.activeShoes.firstIndex(of: shoe), shoeIndex < shoeStore.activeShoes.count - 1 {
                shoeStore.setSelected(shoe: shoeStore.activeShoes[shoeIndex + 1])
                shoeStore.updateSelectedShoe()
            }
        default:
            break // Do nothing
        }
    }
}

struct AddDistanceView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData()
    @StateObject static var store = ShoeStore()
    
    static var previews: some View {
        AddDistanceView(shoe: shoe)
            .environmentObject(store)
    }
}

struct PatternedBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .dark {
            Image("perfTile")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
        }
        else {
            ZStack {
                Image("perfTile")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                Rectangle()
                    .fill(Color(white: 1, opacity: 0.30))
                    .ignoresSafeArea()
            }
        }
    }
}

