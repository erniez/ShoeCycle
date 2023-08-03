//  SettingsView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/7/23.
//  
//

import SwiftUI

// For testing purposes only. So I can launch from Obj-C
@objc class SettingsViewFactory: NSObject {
    
    @objc static func create() -> UIViewController {
        let settingsView = SettingsView()
        let hostingController = UIHostingController(rootView: settingsView)
        return hostingController
    }
    
}

struct SettingsView: View {
    
    var body: some View {
            VStack(spacing: 24) {
                SettingsUnitsView()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.top], 16)
                SettingsFirstDayOfWeekView()
                    .fixedSize(horizontal: false, vertical: true)
                SettingsFavoriteDistancesView()
                    .fixedSize(horizontal: false, vertical: true)
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
        .shoeCycleSection(title: "Units", color: .shoeCycleOrange, image: Image("gear"))
    }
}

struct SettingsFirstDayOfWeekView: View {
    enum FirstDay: String, CaseIterable, Identifiable {
        case sunday, monday
        
        var id: Self { self }
    }
    @State var firstDay: FirstDay = .monday
    
    var body: some View {
        Picker("Please select the first day of week", selection: $firstDay) {
            Text("Sunday").tag(FirstDay.sunday)
            Text("Monday").tag(FirstDay.monday)
        }
        .pickerStyle(.segmented)
        .onChange(of: firstDay) { newValue in
            print(firstDay.rawValue)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
