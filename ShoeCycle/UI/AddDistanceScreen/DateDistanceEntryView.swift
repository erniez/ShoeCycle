//  DateDistanceEntryView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/25/23.
//  
//

import SwiftUI

struct DateDistanceEntryView: View {
    @Binding var runDate: Date
    @Binding var runDistance: String
    @Binding var shouldBounce: Bool
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    
    @State private var state = DateDistanceEntryState()
    @State private var interactor: DateDistanceEntryInteractor
    private let distanceUtility = DistanceUtility()
    
    init(runDate: Binding<Date>, runDistance: Binding<String>, shouldBounce: Binding<Bool>, shoe: Shoe) {
        self._runDate = runDate
        self._runDistance = runDistance
        self._shouldBounce = shouldBounce
        self.shoe = shoe
        // Initialize interactor with shoe, dependencies will be set in onAppear
        self._interactor = State(initialValue: DateDistanceEntryInteractor(shoe: shoe))
    }
    
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
                .frame(height: state.buttonMaxHeight)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(8)
                
                Button {
                    interactor.handle(state: &state, action: .showHistory)
                } label: {
                    Label("History", systemImage: "calendar")
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.shoeCycle)
                .padding([.top], 4)
                .fullScreenCover(isPresented: $state.showHistoryView) {
                    HistoryListView(shoeStore: shoeStore, shoe: shoe)
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
                    .frame(height: state.buttonMaxHeight)
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
                    .font(.title3)
                
                Button {
                    interactor.handle(state: &state, action: .showFavoriteDistances)
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
            .fullScreenCover(isPresented: $state.showFavoriteDistances) {
                FavoriteDistancesView(distanceToAdd: $state.favoriteDistanceToAdd)
            }
            .onChange(of: state.favoriteDistanceToAdd) { _, newValue in
                if newValue > 0 {
                    runDistance = distanceUtility.displayString(for: newValue)
                }
            }
            
            Spacer(minLength: 0)
            
            VStack {
                ZStack {
                    Button {
                        dismissKeyboard()
                        shouldBounce = true
                        if settings.healthKitEnabled || settings.stravaEnabled {
                            interactor.handle(state: &state, action: .addDistancePressed(runDate: runDate, runDistance: runDistance))
                            // Note: runDistance clearing will be handled by the async success callback in the interactor
                        }
                        else {
                            let distance = distanceUtility.distance(from: runDistance)
                            shoeStore.addHistory(to: shoe, date: runDate, distance: distance)
                            shoeStore.updateActiveShoes()
                            runDistance = ""
                        }
                    } label: {
                        Image("button-add-run")
                    }
                    if state.stravaLoading == true {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // TODO: Filling a shape has become simpler in iOS 17
                        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
                            .background(RoundedRectangle.shoeCycleRoundedRectangle
                                .stroke(Color.shoeCycleGreen, lineWidth: 2)
                                .background(RoundedRectangle.shoeCycleRoundedRectangle
                                    .fill(Color.shoeCycleGreen)))
                            .tint(.shoeCycleOrange)
                    }
                }
                HStack {
                    if settings.stravaEnabled == true {
                        Image("stravaLogo")
                    }
                    if settings.healthKitEnabled == true {
                        Image(systemName: "heart.fill")
                            .renderingMode(.template)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding([.top, .bottom, .trailing], 8)
            .alert("Access to Health App Denied", isPresented: $state.showAuthorizationDeniedAlert) {
                Button("OK") {}
            } message: {
                Text("Please enable access in the health app settings. Go to Settings -> Health -> Data Access & Devices -> Enable Sharing for ShoeCycle")
            }
            .alert("Cannot Access the Internet", isPresented: $state.showReachabilityAlert) {
                Button("OK") {}
            } message: {
                Text("Please check your network settings and try again")
            }
            .alert("Unknown Error", isPresented: $state.showUnknownNetworkErrorAlert) {
                Button("OK") {}
            } message: {
                Text("An unknown network error has occurred. Please try again later, or turn Strava access off then on in the Settings tab")
            }
        }
        .dynamicTypeSize(.medium ... .large)
        .onPreferenceChange(RowHeightPreferenceKey.self) {
            interactor.handle(state: &state, action: .buttonMaxHeightChanged($0))
        }
        .onAppear {
            interactor.setDependencies(shoeStore: shoeStore, settings: settings)
            interactor.handle(state: &state, action: .viewAppeared)
        }
        .onChange(of: state.stravaLoading) { _, loading in
            // Clear distance when async operation completes successfully
            if !loading && runDistance.count > 0 && !state.showAuthorizationDeniedAlert && !state.showReachabilityAlert && !state.showUnknownNetworkErrorAlert {
                runDistance = ""
            }
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
    @State static var shouldBounce = false
    @StateObject static var settings = UserSettings.shared
    static var shoe = MockShoeGenerator().generateNewShoeWithData()
    
    static var previews: some View {
        DateDistanceEntryView(runDate: $runDate, runDistance: $runDistance, shouldBounce: $shouldBounce, shoe: shoe)
            .environmentObject(settings)
            .background(Color.gray)
    }
}
