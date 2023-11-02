//  SettingsView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/7/23.
//  
//

import SwiftUI
import AuthenticationServices


struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsUnitsView()
                    .padding([.top], 16)
                SettingsFirstDayOfWeekView()
                SettingsFavoriteDistancesView()
                SettingsHealthKitView()
                SettingsStravaView(interactor: StravaInteractor(settings: settings))
                AboutView()
                    .padding([.bottom])
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(.patternedBackground)
    }
    
}

struct SettingsUnitsView: View {
    @State var units = UserSettings.shared.distanceUnit
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Picker("Please select units for distance", selection: $units) {
            Text(UserSettings.DistanceUnit.miles.displayString().capitalized).tag(UserSettings.DistanceUnit.miles)
            Text(UserSettings.DistanceUnit.km.displayString().capitalized).tag(UserSettings.DistanceUnit.km)
        }
        .pickerStyle(.segmented)
        .onChange(of: units) { newValue in
            settings.set(distanceUnit: units)
        }
        .shoeCycleSection(title: "Units", color: .shoeCycleOrange, image: Image(systemName: "gearshape.fill"))
    }
}

struct SettingsFirstDayOfWeekView: View {
    @State var firstDayOfWeek = UserSettings.shared.firstDayOfWeek
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Picker("Please select the first day of week", selection: $firstDayOfWeek) {
            Text("Sunday").tag(UserSettings.FirstDayOfWeek.sunday)
            Text("Monday").tag(UserSettings.FirstDayOfWeek.monday)
        }
        .pickerStyle(.segmented)
        .onChange(of: firstDayOfWeek) { newValue in
            settings.set(firstDayOfWeek: newValue)
        }
        .shoeCycleSection(title: "First Day of Week", color: .shoeCycleBlue, image: Image(systemName: "calendar"))
    }
}

struct SettingsFavoriteDistancesView: View {
    @ObservedObject var viewModel = SettingsFavoriteDistancesViewModel()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Favorite 1", text: $viewModel.favorite1, prompt: Text("Favorite 1"))
                TextField("Favorite 2", text: $viewModel.favorite2, prompt: Text("Favorite 2"))
            }
            HStack {
                TextField("Favorite 3", text: $viewModel.favorite3, prompt: Text("Favorite 3"))
                TextField("Favorite 4", text: $viewModel.favorite4, prompt: Text("Favorite 4"))
            }
        }
        .textFieldStyle(.numberEntry)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    dismissKeyboard()
                }
            }
        }
        .shoeCycleSection(title: "Favorite Distances", color: .shoeCycleGreen, image: Image("heartPlus"))
    }
}

struct SettingsHealthKitView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var healthKitService: HealthKitService
    @State private var healthKitIsOn = UserSettings.shared.healthKitEnabled
    @State private var showAuthorizationDeniedAlert = false
    @State private var showUnknownErrorAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Connect to Health App")
                    .padding([.leading], 8)
                    .foregroundColor(.shoeCycleBlue)
                    .font(.title2)
                Spacer()
                Toggle("", isOn: $healthKitIsOn)
                    .fixedSize()
                    .foregroundColor(.shoeCycleBlue)
                    .font(.title2)
            }
            Text("Turning this option on will write directly to the Walk + Run Section of the Health App.")
                .foregroundColor(.shoeCycleOrange)
        }
        .padding([.horizontal], 24)
        .padding([.vertical], 16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.shoeCycleBlue, lineWidth: 2)
                .background(Color.sectionBackground, ignoresSafeAreaEdges: [])
                .padding(.horizontal)
        }
        .onChange(of: settings.healthKitEnabled, perform: { newValue in
            healthKitIsOn = newValue
        })
        .onChange(of: healthKitIsOn) { newValue in
            if newValue == true {
                Task {
                    do {
                        try await healthKitService.requestAccessToHealthKitForShoeCycle()
                        if healthKitService.authorizationStatus == .sharingAuthorized {
                            healthKitIsOn = true
                            settings.set(healthKitEnabled: true)
                        }
                        else {
                            showAuthorizationDeniedAlert = true
                            healthKitIsOn = false
                            settings.set(healthKitEnabled: false)
                        }
                    }
                    catch {
                        showUnknownErrorAlert = true
                    }
                }
            }
            else {
                settings.set(healthKitEnabled: false)
            }
        }
        .alert("Access Denied", isPresented: $showAuthorizationDeniedAlert) {
            Button("OK") {}
        } message: {
            Text("Please enable access in the health app settings. Go to Settings -> Health -> Data Access & Devices -> Enable Sharing for ShoeCycle")
        }
        .alert("Unknown Error", isPresented: $showUnknownErrorAlert) {
            Button("OK") {}
        } message: {
            Text("Something went wrong while trying to enable access to the health app. Please try again later.")
        }
    }
}

struct SettingsStravaView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @EnvironmentObject var settings: UserSettings
    @State private var stravaIsOn = UserSettings.shared.stravaEnabled
    private let stravaInteractor: StravaInteractor
    
    init(interactor: StravaInteractor) {
        stravaInteractor = interactor
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("StravaNameLogo")
                    .padding([.leading], 8)
                Spacer()
                Toggle("Enable", isOn: $stravaIsOn)
                    .fixedSize()
                    .foregroundColor(.shoeCycleOrange)
                    .font(.title2)
            }
            Text("Turning on this option will connect you with the Strava login screen.")
                .foregroundColor(.shoeCycleOrange)
        }
        .padding([.horizontal], 24)
        .padding([.vertical], 16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.shoeCycleOrange, lineWidth: 2)
                .background(Color.sectionBackground, ignoresSafeAreaEdges: [])
                .padding(.horizontal)
        }
        .onChange(of: stravaIsOn) { newValue in
            if newValue == true {
                Task {
                    await stravaIsOn = stravaInteractor.fetchToken(with: webAuthenticationSession)
                }
            }
            else {
                settings.set(stravaEnabled: false)
                stravaInteractor.resetStravaToken()
            }
        }
    }
}

struct AboutView: View {
    @State var showAboutInfo = false
    
    var body: some View {
        Button("About") {
            showAboutInfo = true
        }
        .alert("About", isPresented: $showAboutInfo) {
            Button("Done") {}
        } message: {
            Text(aboutMessageText())
        }
    }
    
    func aboutMessageText() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        return "ShoeCycle is programmed by Ernie Zappacosta.\n\nCurrent version is \(version)"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
