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
    @State private var showAuthorizationDeniedAlert = false
    @State private var stravaLoading = false
    @State private var showReachabilityAlert = false
    @State private var showUnknownNetworkErrorAlert = false
    @Binding var runDate: Date
    @Binding var runDistance: String
    @Binding var shouldBounce: Bool
    @ObservedObject var shoe: Shoe
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    
    private let distanceUtility = DistanceUtility()
    private let stravaService = StravaService()
    private let healthService = HealthKitService()
    private let logger = AnalyticsFactory.sharedAnalyticsLogger()
    
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
                    logger.logEvent(name: AnalyticsKeys.Event.showHistoryEvent, userInfo: nil)
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
                    .font(.title3)
                
                Button {
                    logger.logEvent(name: AnalyticsKeys.Event.showFavoriteDistancesEvent,
                                    userInfo: [AnalyticsKeys.UserInfo.numberOfFavoritesUsedKey : settings.favoriteDistanceCount()])
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
                ZStack {
                    Button {
                        dismissKeyboard()
                        shouldBounce = true
                        let distance = distanceUtility.distance(from: runDistance)
                        if settings.healthKitEnabled || settings.stravaEnabled {
                            Task {
                                await handleAsynchronousDistanceAdd(distance: distance)
                                handleAddDistanceAnalytics(for: shoe, distance: distance)
                            }
                        }
                        else {
                            shoeStore.addHistory(to: shoe, date: runDate, distance: distance)
                            shoeStore.updateActiveShoes()
                            handleAddDistanceAnalytics(for: shoe, distance: distance)
                            runDistance = ""
                        }
                    } label: {
                        Image("button-add-run")
                    }
                    if stravaLoading == true {
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
                .fixedSize()
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
                Spacer()
            }
            .padding(8)
            .padding([.leading], 16)
            .alert("Access to Health App Denied", isPresented: $showAuthorizationDeniedAlert) {
                Button("OK") {}
            } message: {
                Text("Please enable access in the health app settings. Go to Settings -> Health -> Data Access & Devices -> Enable Sharing for ShoeCycle")
            }
            .alert("Cannot Access the Internet", isPresented: $showReachabilityAlert) {
                Button("OK") {}
            } message: {
                Text("Please check your network settings and try again")
            }
            .alert("Unknown Error", isPresented: $showUnknownNetworkErrorAlert) {
                Button("OK") {}
            } message: {
                Text("An unknown network error has occurred. Please try again later, or turn Strava access off then on in the Settings tab")
            }
        }
        .onPreferenceChange(RowHeightPreferenceKey.self) {
            buttonMaxHeight = $0
        }
    }
    
    func handleAsynchronousDistanceAdd(distance: Double) async {
        do {
            if settings.healthKitEnabled == true {
                let shoeIdentifier = shoe.objectID.uriRepresentation().absoluteString
                let metadata = ["ShoeCycleShoeIdentifier" : shoeIdentifier]
                try await healthService.saveRun(distance: distance,
                                                date: runDate, metadata: metadata)
                logger.logEvent(name: AnalyticsKeys.Event.healthKitEvent, userInfo: nil)
            }
            
            if settings.stravaEnabled == true {
                let activity = StravaActivity(name: "ShoeCycle Logged Run",
                                              distance: distanceUtility.stravaDistance(for: distance),
                                              startDate: runDate)
                stravaLoading = true
                try await stravaService.send(activity: activity)
                logger.logEvent(name: AnalyticsKeys.Event.stravaEvent, userInfo: nil)
            }
            
            shoeStore.addHistory(to: shoe, date: runDate, distance: distance)
            runDistance = ""
            stravaLoading = false
        }
        catch let error {
            if case HealthKitService.DomainError.healthDataSharingDenied = error {
                showAuthorizationDeniedAlert = true
            }
            else if case StravaService.DomainError.reachability = error {
                showReachabilityAlert = true
            }
            else {
                showUnknownNetworkErrorAlert = true
            }
            stravaLoading = false
        }
    }
    
    func handleAddDistanceAnalytics(for shoe: Shoe, distance: Double) {
        let userInfo: [String : Any] = [ AnalyticsKeys.UserInfo.mileageNumberKey : NSNumber(value: distance),
                                         AnalyticsKeys.UserInfo.totalMileageNumberKey : NSNumber(value: shoe.totalDistance.doubleValue),
                                         AnalyticsKeys.UserInfo.mileageUnitKey : settings.distanceUnit.displayString() ]
        logger.logEvent(name: AnalyticsKeys.Event.logMileageEvent, userInfo: userInfo)
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
    static var shoe = MockShoeGenerator().generateNewShoeWithData()
    
    static var previews: some View {
        DateDistanceEntryView(runDate: $runDate, runDistance: $runDistance, shouldBounce: $shouldBounce, shoe: shoe)
    }
}
