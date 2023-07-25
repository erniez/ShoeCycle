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
    
    var body: some View {
        if shoeStore.selectedShoe != nil {
            let progressBarWidth = screenWidth * 0.60
            VStack {
                HStack {
                    Image("logo")
                    Spacer()
                    ShoeImageView(shoe: shoe, width: 150, height: 100)
                        .offset(x: 0, y: 16)
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
        }
        else {
            // Shouldn't ever see this
            Text("Something went wrong")
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

struct DateDistanceEntryView: View {
    @State private var buttonMaxHeight: CGFloat?
    @State private var showHistoryView = false
    @State private var showFavoriteDistances = false
    @State private var favoriteDistanceToAdd = 0.0
    @Binding var runDate: Date
    @Binding var runDistance: String
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Date:")
                    .padding(.bottom, -4)
                    .foregroundColor(.white)
                
                DatePicker("runDate",
                           selection: $runDate,
                           displayedComponents: [.date])
                .accentColor(.shoeCycleOrange)
                .foregroundColor(.white)
                .labelsHidden()
                .datePickerStyle(.compact)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: RowHeightPreferenceKey.self,
                        value: geometry.size.height
                    )
                })
                .frame(height: buttonMaxHeight)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(8)
                
                Button {
                    showHistoryView = true
                } label: {
                    Label("History", systemImage: "calendar")
                        .font(.caption)
                }
                .buttonStyle(.shoeCycle)
                .fullScreenCover(isPresented: $showHistoryView) {
                    let viewModel = HistoryListViewModel(shoeStore: shoeStore, shoe: shoe)
                    HistoryListView(listData: viewModel)
                }
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            
            VStack(alignment: .leading) {
                Text("Distance:")
                    .padding(.bottom, -4)
                    .foregroundColor(.white)
                
                TextField(" Distance  ", text: $runDistance, prompt: Text(" Distance ").foregroundColor(Color(uiColor: .systemGray2)))
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: RowHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    })
                    .frame(height: buttonMaxHeight)
                    .frame(minWidth: 50)
                    .textFieldStyle(.numberEntry)
                    .fixedSize()
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                dismissKeyboard()
                            }
                        }
                    }
                
                Button {
                    showFavoriteDistances = true
                } label: {
                    Label("Distances", systemImage: "heart.fill")
                        .font(.caption)
                }
                .buttonStyle(.shoeCycle)
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            .fullScreenCover(isPresented: $showFavoriteDistances) {
                FavoriteDistancesView(distanceToAdd: $favoriteDistanceToAdd)
            }
            .onChange(of: favoriteDistanceToAdd) { newValue in
                if newValue > 0 {
                    let formatter = NumberFormatter.decimal
                    runDistance = formatter.string(from: NSNumber(value: favoriteDistanceToAdd)) ?? ""
                }
            }
            
            Spacer()
            
            Button {
                dismissKeyboard()
                guard let runDistanceNumber = Float(runDistance) else {
                    print("Could not form a number from string entered")
                    return
                }
                shoeStore.addHistory(to: shoe, date: runDate, distance: runDistanceNumber)
                runDistance = ""
                print(runDate)
            } label: {
                Image("button-add-run")
            }
            .padding(8)
        }
        .onPreferenceChange(RowHeightPreferenceKey.self) {
            buttonMaxHeight = $0
        }
    }
}

private extension DateDistanceEntryView {
    struct RowHeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
