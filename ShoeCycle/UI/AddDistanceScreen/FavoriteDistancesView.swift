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
    let settings = UserSettings.shared
    let formatter = NumberFormatter.decimal
    @Binding var distanceToAdd: Double
    @Environment(\.dismiss) var dismiss
    
    private let padding = 8.0
    private let distanceUtility = DistanceUtility()
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    distanceToAdd(0)
                    dismiss()
                }
                .padding(16)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: "5k") { distanceToAdd(3.10686) }
                    FavoriteDistanceButton(title: "10k") { distanceToAdd(6.21371) }
                }
                .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: "5 miles") { distanceToAdd(5) }
                    FavoriteDistanceButton(title: "10 miles") { distanceToAdd(10) }
                }
                .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: "Half Marathon") { distanceToAdd(13.1) }
                    FavoriteDistanceButton(title: "Marathon") { distanceToAdd(26.2) }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .shoeCycleSection(title: "Popular Distances", color: .shoeCycleBlue, image: Image("steps"))
            .padding([.vertical], 16)
            .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: displayString(for: settings.favorite1) ?? "Favorite 1") {
                        distanceToAdd(Double(settings.favorite1))
                    }
                    FavoriteDistanceButton(title: displayString(for: settings.favorite2) ?? "Favorite 2") {
                        distanceToAdd(Double(settings.favorite2))
                    }
                }
                HStack(spacing: 16) {
                    FavoriteDistanceButton(title: displayString(for: settings.favorite3) ?? "Favorite 3") {
                        distanceToAdd(Double(settings.favorite3))
                    }
                    FavoriteDistanceButton(title: displayString(for: settings.favorite4) ?? "Favorite 4") {
                        distanceToAdd(Double(settings.favorite4))
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
    }
    
    func distanceToAdd(_ distance: Double) {
        distanceToAdd = distance
        dismiss()
    }
    
    func displayString(for distance: Double) -> String? {
        let displayString = distanceUtility.favoriteDistanceDisplayString(for: distance)
        if displayString.count > 0 {
            return displayString
        }
        return nil
    }
}

struct FavoriteDistancesView_Previews: PreviewProvider {
    @State static var distanceToAdd = 0.0
    static var previews: some View {
        FavoriteDistancesView(distanceToAdd: $distanceToAdd)
            .onChange(of: distanceToAdd) { newValue in
                print("changed!")
                print(newValue)
            }
    }
}