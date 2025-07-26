//  AddDistanceView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/6/23.
//  
//

import SwiftUI

struct AddDistanceView: View {
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    
    @State private var state = AddDistanceState()
    @State private var interactor = AddDistanceInteractor()
    
    let screenWidth = UIScreen.main.bounds.size.width
    let minimumDrag: CGFloat = 20
    
    var body: some View {
        // NavigationView is required for keyboard toolbars to work properly in SwiftUI
        // Without this, the Done button won't appear on number pad keyboards
        NavigationView {
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
                             
                                interactor.handle(state: &state, action: .swipeGestureDetected(translationHeight: translation.height))
                            }))
                    Image("scroll-arrows")
                        .padding(.leading, 8)
                }
                .fixedSize(horizontal: false, vertical: true)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.sectionBackground)
                    DateDistanceEntryView(runDate: $state.runDate, runDistance: $state.runDistance, shouldBounce: $state.shouldBounce, shoe: shoe)
                }
                .padding([.vertical], 16)
                .fixedSize(horizontal: false, vertical: true)
                ShoeCycleDistanceProgressView(progressWidth: progressBarWidth, value: shoe.totalDistance.doubleValue, endvalue: shoe.maxDistance.intValue, shouldBounce: $state.shouldBounce)
                ShoeCycleDateProgressView(progressWidth: progressBarWidth, viewModel: DateProgressViewModel(startDate: shoe.startDate, endDate: shoe.expirationDate, shouldBounce: $state.shouldBounce))
                RunHistoryChart(collatedHistory: historiesToShow().collateHistories(ascending: true), graphAllShoes: $state.graphAllShoes)
                    .padding([.vertical], 16)
            }
            .padding([.horizontal], 16)
            .background(.patternedBackground)
            .ignoresSafeArea(.keyboard, edges: [.bottom])
            .onAppear {
                interactor.setDependencies(shoeStore: shoeStore, userSettings: settings)
                interactor.handle(state: &state, action: .viewAppeared)
            }
            .onChange(of: state.graphAllShoes) { _, newValue in
                interactor.handle(state: &state, action: .graphAllShoesToggled(newValue))
            }
        }
        else {
            // Shouldn't ever see this
            Text("Something went wrong")
        }
        }
    }
    
    func historiesToShow() -> Set<History> {
        if state.graphAllShoes == true {
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

