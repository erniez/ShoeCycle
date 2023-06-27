//  ShoeDetailView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/23/23.
//  
//

import SwiftUI

class ShoeDetailViewModel: ObservableObject {
    @Published var shoeName = ""
    @Published var startDistance = "0"
    @Published var maxDistance = "350"
    @Published var startDate = Date()
    @Published var expirationDate = Date() + TimeInterval.secondsInSixMonths
}

struct ShoeDetailView: View {
    @ObservedObject var viewModel = ShoeDetailViewModel()
    
    var body: some View {
        ZStack {
            PatternedBackground()
            VStack {
                SettingsOptionView(optionText: "Shoe", color: .shoeCycleOrange, image: Image("shoe")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name:")
                        TextField("Shoe Name", text: $viewModel.shoeName, prompt: Text("Shoe Name"))
                            .textFieldStyle(TextEntryStyle())
                    }
                    .foregroundColor(.white)
                    .padding([.horizontal], 16)
                }
                .padding([.top], 16)
                .fixedSize(horizontal: false, vertical: true)
                SettingsOptionView(optionText: "Distance", color: .shoeCycleGreen, image: Image("steps")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start:")
                            TextField("Start Distance", text: $viewModel.startDistance)
                                .textFieldStyle(.numberEntry)
                        }
                        .padding([.horizontal], 16)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Max:")
                            TextField("Max Distance", text: $viewModel.maxDistance)
                                .textFieldStyle(.numberEntry)
                        }
                        .padding([.horizontal], 16)
                    }
                }
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                SettingsOptionView(optionText: "Wear Time", color: .shoeCycleBlue, image: Image("clock")) {
                    VStack {
                        HStack {
                            Text("Start:")
                            Spacer()
                            DatePicker("Start Date",
                                       selection: $viewModel.startDate,
                                       displayedComponents: [.date])
                            .accentColor(.shoeCycleOrange)
                            .foregroundColor(.white)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(8)
                        }
                        HStack {
                            Text("End:")
                            Spacer()
                            DatePicker("Expiration Date",
                                       selection: $viewModel.expirationDate,
                                       displayedComponents: [.date])
                            .accentColor(.shoeCycleOrange)
                            .foregroundColor(.white)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .foregroundColor(.white)
                }
                .fixedSize(horizontal: false, vertical: true)
                ZStack (alignment: .bottom) {
                    Image("photo-placeholder")
                        .resizable()
                        .padding(32)
                        .aspectRatio(1.4, contentMode: .fit)
                        .background(.black)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.shoeCycleOrange, lineWidth: 2)
                        }
                }
                Spacer()
            }
            .padding([.horizontal], 16)
        }
    }
}

struct ShoeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShoeDetailView()
    }
}
