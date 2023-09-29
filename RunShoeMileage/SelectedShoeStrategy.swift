//  SelectedShoeStrategy.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/20/23.
//  
//

import Foundation


struct SelectedShoeStrategy {
    let store: ShoeStore
    let settings: UserSettings
    
    init(store: ShoeStore, settings: UserSettings) {
        self.store = store
        self.settings = settings
    }
    
    func updateSelectedShoe() {
        guard store.activeShoes.count > 0 else {
            settings.setSelected(shoeUrl: nil)
            return
        }
        // If we have a selected shoe URL, then find the first match.
        if let selectedShoeURL = settings.selectedShoeURL {
            let selectedShoe = store.activeShoes.first { shoe in
                selectedShoeURL == shoe.objectID.uriRepresentation()
            }
            if selectedShoe != nil {
                // We have a selectedShoe URL within activeShoes that matches what is saved in settings.
                // All is right in the world, so no need to take any action
                return
            }
            else {
                // ... If not, then select the first shoe.
                selectFirstActiveShoe()
            }
        }
        else {
            selectFirstActiveShoe()
        }
    }
    
    private func selectFirstActiveShoe() {
        if let shoe = store.activeShoes.first {
            settings.setSelected(shoeUrl: shoe.objectID.uriRepresentation())
        }
    }
}
