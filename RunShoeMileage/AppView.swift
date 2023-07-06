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
    @State var activeTab: TabIdentifier = InitialTabStrategy().initialTab()
    let shoe = MockShoeGenerator().generateNewShoeWithData()
    
    var body: some View {
        TabView(selection: $activeTab) {
            AddDistanceView(shoe: shoeStore.activeShoes[0])
                .tabItem {
                    Label("Add Distance", image: "tabbar-add")
                }
                .tag(TabIdentifier.addDistance)
            EditShoesView(shoes: EditShoesView.generateViewModelsFromActiveShoes(from: shoeStore))
                .tabItem {
                    Label("Active Shoes", image: "tabbar-shoe")
                }
                .tag(TabIdentifier.activeShoes)
            HallOfFameView()
                .tabItem {
                    Label("Hall of Fame", image: "trophy")
                }
                .tag(TabIdentifier.hallOfFame)
            SettingsView()
                .tabItem {
                    Label("Settings", image: "tabbar-gear")
                }
                .tag(TabIdentifier.settings)
        }
        .environmentObject(shoeStore)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
