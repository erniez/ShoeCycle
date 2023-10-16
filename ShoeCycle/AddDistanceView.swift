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
    @State private var graphAllShoes = UserSettings.shared.graphAllShoes
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    let screenWidth = UIScreen.main.bounds.size.width
    let minimumDrag: CGFloat = 20
    
    var body: some View {
        if settings.selectedShoeURL != nil {
            let progressBarWidth = screenWidth * 0.60
            VStack {
                HStack {
                    Image("logo")
                    Spacer()
                    ShoeImageView(shoe: shoe)
                        .offset(x: 0, y: 16)
                        .frame(maxWidth: 150)
                        .padding(.leading, 32)
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
                .fixedSize(horizontal: false, vertical: true)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.sectionBackground)
                    DateDistanceEntryView(runDate: $runDate, runDistance: $runDistance, shoe: shoe)
                }
                .padding([.vertical], 16)
                .fixedSize(horizontal: false, vertical: true)
                ShoeCycleDistanceProgressView(progressWidth: progressBarWidth, value: shoe.totalDistance.doubleValue, endvalue: shoe.maxDistance.intValue)
                ShoeCycleDateProgressView(progressWidth: progressBarWidth, viewModel: DateProgressViewModel(startDate: shoe.startDate, endDate: shoe.expirationDate))
                RunHistoryChart(collatedHistory: historiesToShow().collateHistories(ascending: true), graphAllShoes: $graphAllShoes)
                    .padding([.vertical], 16)
            }
            .padding([.horizontal], 16)
            .background(.patternedBackground)
            .ignoresSafeArea(.keyboard, edges: [.bottom])
            .onTapGesture {
                dismissKeyboard()
            }
        }
        else {
            // Shouldn't ever see this
            Text("Something went wrong")
        }
    }
    
    func historiesToShow() -> Set<History> {
        if graphAllShoes == true {
            var allHistories: Set<History> = []
            shoeStore.activeShoes.forEach { shoe in
                allHistories.formUnion(shoe.history)
            }
            return allHistories
        }
        else {
            return shoe.history
        }
    }
    
    func handleVerticalSwipe(translationHeight: Double) {
        switch translationHeight {
        case -Double.infinity ..< -minimumDrag: // Swipe up
            if let shoeIndex = shoeStore.activeShoes.firstIndex(of: shoe), shoeIndex < shoeStore.activeShoes.count - 1 {
                let shoe = shoeStore.activeShoes[shoeIndex + 1]
                settings.setSelected(shoeUrl: shoe.objectID.uriRepresentation())
            }
        case minimumDrag ..< Double.infinity:  // Swipe down
            if let shoeIndex = shoeStore.activeShoes.firstIndex(of: shoe), shoeIndex > 0 {
                let shoe = shoeStore.activeShoes[shoeIndex - 1]
                settings.setSelected(shoeUrl: shoe.objectID.uriRepresentation())
            }
        default:
            break // Do nothing
        }
    }
}

struct AddDistanceView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData()
    @State static var store = ShoeStore()
    @State static var settings = UserSettings.shared
    
    static var previews: some View {
        AddDistanceView(shoe: store.getShoe(from: settings.selectedShoeURL)!)
            .environmentObject(store)
    }
}

