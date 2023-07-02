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

struct AppView: View {
    @StateObject var shoeStore = ShoeStore()
    
    var body: some View {
        TabView {
            AddDistanceView(shoe: shoeStore.activeShoes[0])
                .tabItem {
                    Label("Add Distance", image: "tabbar-add")
                }
            EditShoesView(shoes: EditShoesView.generateViewModelsFromActiveShoes(from: shoeStore))
                .tabItem {
                    Label("Add/Edit Shoes", image: "tabbar-shoe")
                }
            HallOfFameView()
                .tabItem {
                    Label("Hall of Fame", image: "trophy")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", image: "tabbar-gear")
                }
        }
        .environmentObject(shoeStore)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
