//  FavoriteDistancesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/19/23.
//  
//

import SwiftUI

struct FavoriteDistanceButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.shoeCycle)
    }
}

struct FavoriteDistancesView: View {
    @Binding var distanceToAdd: Double
    @Environment(\.dismiss) var dismiss
    @State private var state = FavoriteDistancesState()
    private let interactor: FavoriteDistancesInteractor
    
    private let padding = 8.0
    
    init(distanceToAdd: Binding<Double>) {
        self._distanceToAdd = distanceToAdd
        self.interactor = FavoriteDistancesInteractor()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    interactor.handle(state: &state, action: .cancelPressed)
                    dismiss()
                }
                .padding(16)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: "5k") { 
                        interactor.handle(state: &state, action: .distanceSelected(3.10686))
                        dismiss()
                    }
                    FavoriteDistanceButton(title: "10k") { 
                        interactor.handle(state: &state, action: .distanceSelected(6.21371))
                        dismiss()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: "5 miles") { 
                        interactor.handle(state: &state, action: .distanceSelected(5))
                        dismiss()
                    }
                    FavoriteDistanceButton(title: "10 miles") { 
                        interactor.handle(state: &state, action: .distanceSelected(10))
                        dismiss()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: "Half Marathon") { 
                        interactor.handle(state: &state, action: .distanceSelected(13.1))
                        dismiss()
                    }
                    FavoriteDistanceButton(title: "Marathon") { 
                        interactor.handle(state: &state, action: .distanceSelected(26.2))
                        dismiss()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .shoeCycleSection(title: "Popular Distances", color: .shoeCycleBlue, image: Image("steps"))
            .padding([.vertical], 16)
            .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: state.favorite1DisplayString ?? "Favorite 1") {
                        let settings = UserSettings.shared
                        interactor.handle(state: &state, action: .distanceSelected(Double(settings.favorite1)))
                        dismiss()
                    }
                    FavoriteDistanceButton(title: state.favorite2DisplayString ?? "Favorite 2") {
                        let settings = UserSettings.shared
                        interactor.handle(state: &state, action: .distanceSelected(Double(settings.favorite2)))
                        dismiss()
                    }
                }
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: state.favorite3DisplayString ?? "Favorite 3") {
                        let settings = UserSettings.shared
                        interactor.handle(state: &state, action: .distanceSelected(Double(settings.favorite3)))
                        dismiss()
                    }
                    FavoriteDistanceButton(title: state.favorite4DisplayString ?? "Favorite 4") {
                        let settings = UserSettings.shared
                        interactor.handle(state: &state, action: .distanceSelected(Double(settings.favorite4)))
                        dismiss()
                    }
                }
            }
            .buttonStyle(.shoeCycle)
            .padding(16)
            .shoeCycleSection(title: "Favorite Distances", color: .shoeCycleGreen, image: Image("tabbar-add"))
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .background(.patternedBackground)
        .dynamicTypeSize(.medium ... .xLarge)
        .onAppear {
            interactor.handle(state: &state, action: .viewAppeared)
        }
        .onChange(of: state.distanceToAdd) { _, newValue in
            distanceToAdd = newValue
        }
    }
}

struct FavoriteDistancesView_Previews: PreviewProvider {
    @State static var distanceToAdd = 0.0
    static var previews: some View {
        FavoriteDistancesView(distanceToAdd: $distanceToAdd)
            .onChange(of: distanceToAdd) { _, newValue in
                print("changed!")
                print(newValue)
            }
    }
}
