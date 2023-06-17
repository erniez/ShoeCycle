//  SettingsOptionView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/9/23.
//  
//

import SwiftUI


struct SettingsOptionView<Content>: View where Content: View {
    let optionText: String
    let color: Color
    let image: Image
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(color, lineWidth: 2)
                .background(Color.sectionBackground)
                .padding(.horizontal)
            HStack(spacing: 0) {
                VStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(color)
                        .padding([.top], 8)
                    Text(optionText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal)
                        .padding([.bottom], 8)
                        .frame(width: 100)
                        .foregroundColor(color)
                        .font(.subheadline)
                }
                .frame(width: 100)
                Line()
                    .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(width: 1)
                Spacer()
                content()
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct SettingsOptionView_Previews: PreviewProvider {
    @State static var units: SettingsUnitsView.DistanceUnits = .miles
    
    static var previews: some View {
        SettingsOptionView(optionText: "Units",
                           color: .shoeCycleOrange,
                           image: Image("gear")) {
            Picker("Please select units for distance", selection: $units) {
                Text("Miles").tag(SettingsUnitsView.DistanceUnits.miles)
                Text("Km").tag(SettingsUnitsView.DistanceUnits.km)
            }
            .pickerStyle(.segmented)
            .onChange(of: units) { newValue in
                print(units.rawValue)
            }
        }
    }
}
