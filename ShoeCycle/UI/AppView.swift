//  AppView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/30/23.
//  
//

import SwiftUI

//@objc class AppViewFactory: NSObject {
//    
//    @objc static func create() -> UIViewController {
//        let appView = AppView()
//        let hostingController = UIHostingController(rootView: appView)
//        return hostingController
//    }
//    
//}

struct InitialTabStrategy {
    let shoeStore = ShoeStore()
    
    func initialTab() -> AppView.TabIdentifier {
        return shoeStore.activeShoes.count > 0 ? .addDistance : .activeShoes
    }
}

struct AppView: View {
    enum TabIdentifier {
        case addDistance, activeShoes, hallOfFame, settings
    }
    
    @StateObject private var shoeStore = ShoeStore()
    @StateObject private var settings = UserSettings.shared
    @StateObject private var healthKitService = HealthKitService()
    @State private var activeTab: TabIdentifier = InitialTabStrategy().initialTab()
    @State private var shoeFTUHint = false
    
    @ObservedObject var tsCoordinator = TSCoordinator.shared
    
    private let ftuManager = FTUHintManager()

    var body: some View {
        ZStack {
            TabView {
                if tsCoordinator.currentState.rawValue >= 5 {
                    if let shoe = shoeStore.getShoe(from: settings.selectedShoeURL), shoeStore.activeShoes.count > 0 {
                        AddDistanceView(shoe: shoe)
                            .tabItem {
                                tabBarAddDistanceLabel
                            }
                            .tag(TabIdentifier.addDistance)
                    }
                    else {
                        // TODO: Improve this screen, or make AddDistanceView able to handle an optional
                        Text("Please add a shoe in the Active Shoes tab")
                            .padding(48)
                            .multilineTextAlignment(.center)
                            .tabItem {
                                tabBarAddDistanceLabel
                            }
                            .tag(TabIdentifier.addDistance)
                    }
                }
                if tsCoordinator.currentState.rawValue >= 4 {
                    ActiveShoesView(viewModels: ShoeListRowViewModel.generateShoeViewModels(from: shoeStore.activeShoes),
                                    selectedShoeStrategy: SelectedShoeStrategy(store: shoeStore, settings: settings))
                    .tabItem {
                        Label {
                            Text("Active Shoes")
                        } icon: {
                            Image("tabbar-shoe")
                                .renderingMode(.template)
                        }
                        
                    }
                    .tag(TabIdentifier.activeShoes)
                }
                if tsCoordinator.currentState.rawValue >= 3 {
                    HallOfFameView(shoeRowViewModels: ShoeListRowViewModel.generateShoeViewModels(from: shoeStore.hallOfFameShoes))
                        .tabItem {
                            Label("Hall of Fame", systemImage: "trophy.fill")
                        }
                        .tag(TabIdentifier.hallOfFame)
                }
                if tsCoordinator.currentState.rawValue >= 2 {
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(TabIdentifier.settings)
                }
            }
            .environmentObject(shoeStore)
            .environmentObject(settings)
            .environmentObject(healthKitService)
            .dynamicTypeSize(.medium ... .xLarge)
            .onAppear {
                let selectedShoeStrategy = SelectedShoeStrategy(store: shoeStore, settings: settings)
                selectedShoeStrategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
                // These hints are only valuable when there are 2 or more active shoes. This logic will be moved into
                // TipKit when I adopt it.
                if shoeStore.activeShoes.count >= 2, let _ = ftuManager.hintMessage() {
                    shoeFTUHint = true
                }
            }
            .alert("Hint", isPresented: $shoeFTUHint) {
                HStack {
                    Button("Don't show again") {
                        ftuManager.completeHint()
                    }
                    Button("OK") {}
                }
            } message: {
                Text(ftuManager.hintMessage() ?? "")
            }
            
            if tsCoordinator.currentState != .finished {
                TSView(coordinator: tsCoordinator)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: 1, opacity: 0.80))
            }
        }
    }
    
    var tabBarAddDistanceLabel: some View {
        Label {
            Text("Add Distance")
        } icon: {
            Image("tabbar-add")
                .renderingMode(.template)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
