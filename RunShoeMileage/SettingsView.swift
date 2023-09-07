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
            VStack(spacing: 24) {
                SettingsUnitsView()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.top], 16)
                SettingsFirstDayOfWeekView()
                    .fixedSize(horizontal: false, vertical: true)
                SettingsFavoriteDistancesView()
                    .fixedSize(horizontal: false, vertical: true)
                SettingsStravaView(interactor: StravaInteractor(settings: settings))
                Spacer()
            }
            .background(.patternedBackground
                .onTapGesture {
                    dismissKeyboard()
                })
    }
    
}

struct SettingsUnitsView: View {
    @State var units = UserSettings().distanceUnit
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
    @State var firstDayOfWeek = UserSettings().firstDayOfWeek
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

struct SettingsStravaView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @EnvironmentObject var settings: UserSettings
    @State private var stravaIsOn = UserSettings().stravaEnabled
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
