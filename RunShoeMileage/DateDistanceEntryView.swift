//  DateDistanceEntryView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/25/23.
//  
//

import SwiftUI

struct DateDistanceEntryView: View {
    @State private var buttonMaxHeight: CGFloat?
    @State private var showHistoryView = false
    @State private var showFavoriteDistances = false
    @State private var favoriteDistanceToAdd = 0.0
    @Binding var runDate: Date
    @Binding var runDistance: String
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    
    private let distanceUtility = DistanceUtility()
    
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
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.shoeCycle)
                .padding([.top], 4)
                .fullScreenCover(isPresented: $showHistoryView) {
                    let viewModel = HistoryListViewModel(shoeStore: shoeStore, shoe: shoe)
                    HistoryListView(listData: viewModel)
                }
            }
            .fixedSize()
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
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                dismissKeyboard()
                            }
                        }
                    }
                
                Button {
                    showFavoriteDistances = true
                } label: {
                    Label("Distances", systemImage: "heart.fill")
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.shoeCycle)
                .padding([.top], 4)
                
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            .fixedSize()
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
            
            VStack {
                Button {
                    dismissKeyboard()
                    shoeStore.addHistory(to: shoe, date: runDate, distance: distanceUtility.distance(from: runDistance))
                    runDistance = ""
                } label: {
                    Image("button-add-run")
                }
                HStack {
                    if settings.isStravaEnabled() {
                        Image("stravaLogo")
                    }
                    // TODO: Tie this to AppleHealth logic
                    Image(systemName: "heart.fill")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                }
            }
            .padding(8)
            .padding([.leading], 16)
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

struct DateDistanceEntryView_Previews: PreviewProvider {
    @State static var runDate = Date()
    @State static var runDistance = "5"
    static var shoe = MockShoeGenerator().generateNewShoeWithData()
    
    static var previews: some View {
        DateDistanceEntryView(runDate: $runDate, runDistance: $runDistance, shoe: shoe)
    }
}
