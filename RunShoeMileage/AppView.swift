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
    // TODO: Figure out how to change icon colors for light mode.
    var body: some View {
        TabView {
            AddDistanceView()
                .tabItem {
                    Label("Add Distance", image: "tabbar-add")
                }
            EditShoesView()
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
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
