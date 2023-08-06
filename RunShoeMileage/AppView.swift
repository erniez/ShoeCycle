//  AppView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/30/23.
//  
//

import SwiftUI

@objc class AppViewFactory: NSObject {
    
    @objc static func create() -> UIViewController {
        let appView = AppView()
        let hostingController = UIHostingController(rootView: appView)
        return hostingController
    }
    
}

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
    
    @StateObject var shoeStore = ShoeStore()
    @StateObject var settings = UserSettings()
    @State var activeTab: TabIdentifier = InitialTabStrategy().initialTab()
    
    var body: some View {
        TabView(selection: $activeTab) {
            if let shoe = shoeStore.selectedShoe, shoeStore.activeShoes.count > 0 {
                AddDistanceView(shoe: shoe)
                    .tabItem {
                        tabBarAddDistanceLabel
                    }
                    .tag(TabIdentifier.addDistance)
            }
            else {
                // TODO: Improve this screen, or make AddDistanceView able to handle an optional
                Text("Please add a shoe")
                    .tabItem {
                        tabBarAddDistanceLabel
                    }
                    .tag(TabIdentifier.addDistance)
            }
            EditShoesView(shoes: EditShoesView.generateViewModelsFromActiveShoes(from: shoeStore))
                .tabItem {
                    Label {
                        Text("Active Shoes")
                    } icon: {
                        Image("tabbar-shoe")
                            .renderingMode(.template)
                    }

                }
                .tag(TabIdentifier.activeShoes)
            HallOfFameView()
                .tabItem {
                    Label("Hall of Fame", systemImage: "trophy.fill")
                }
                .tag(TabIdentifier.hallOfFame)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(TabIdentifier.settings)
        }
        .environmentObject(shoeStore)
        .environmentObject(settings)
        .dynamicTypeSize(.medium ... .xLarge)
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
