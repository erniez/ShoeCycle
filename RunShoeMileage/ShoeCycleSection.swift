//  SettingsOptionView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/9/23.
//  
//

import SwiftUI

struct ShoeCycleSection: ViewModifier {
    let title: String
    let color: Color
    let image: Image
    
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            VStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                Text(title)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal)
                    .frame(width: 100)
                    .font(.subheadline)
            }
            .padding([.vertical], 8)
            .frame(width: 100)
            .foregroundColor(color)
            Line()
                .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: 1)
            Spacer()
            content
            Spacer()
        }
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(color, lineWidth: 2)
                .background(Color.sectionBackground, ignoresSafeAreaEdges: [])
                .padding(.horizontal)
        }
    }
}

struct ShoeCycleSection_Previews: PreviewProvider {
    @State static var units: UserSettings.DistanceUnit = .miles
    @State static var shoeName = ""
    
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    print("test")
                }) {
                    Text("Half Marathon")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: 100)
                        .lineLimit(2)
                }
                Button(action: { } ) {
                    Text("10k")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button("5 miles") {  }
                Button("10 miles") { }
            }
            HStack {
                Button("Half Marathon") {  }
                Button("Marathon") {  }
            }
        }
        .padding(8)
        .shoeCycleSection(title: "Units",
                          color: .shoeCycleOrange,
                          image: Image("gear"))
        .buttonStyle(.shoeCycle)
        
        Picker("Please select units for distance", selection: $units) {
            Text("Miles").tag(UserSettings.DistanceUnit.miles)
            Text("Km").tag(UserSettings.DistanceUnit.km)
        }
        .pickerStyle(.segmented)
        .onChange(of: units) { newValue in
            print(units.rawValue)
        }
        .shoeCycleSection(title: "Units", color: .shoeCycleOrange, image: Image("gear"))
        
        VStack(alignment: .leading, spacing: 4) {
            Text("Name:")
            TextField("Shoe Name", text: $shoeName, prompt: Text("Shoe Name"))
                .textFieldStyle(TextEntryStyle())
        }
        .padding([.horizontal], 16)
        .shoeCycleSection(title: "Shoe", color: .shoeCycleOrange, image: Image("shoe"))
                    
    }
}
