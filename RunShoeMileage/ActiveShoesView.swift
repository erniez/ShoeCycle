//  ActiveShoesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI

struct ActiveShoesView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    @State var shoes: [ShoeDetailViewModel]
    @State var presentNewShoeView = false
    private var selectedShoeStrategy: SelectedShoeStrategy
    
    init(shoes: [ShoeDetailViewModel], presentNewShoeView: Bool = false, selectedShoeStrategy: SelectedShoeStrategy) {
        self.shoes = shoes
        self.presentNewShoeView = presentNewShoeView
        self.selectedShoeStrategy = selectedShoeStrategy
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(shoeStore.activeShoes, id: \.objectID) { shoe in
                    NavigationLink(value: shoe) {
                        ActiveShoesRowView(viewModel: ActiveShoesRowViewModel(brand: shoe.brand,
                                                                              totalDistance: shoe.totalDistance.doubleValue,
                                                                              shoeURL: shoe.objectID.uriRepresentation()))
                    }
                }
                .onDelete { indexSet in
                    let shoesToRemove = indexSet.map { shoes[$0] }
                    shoesToRemove.forEach { viewModel in
                        if let index = shoes.firstIndex(of: viewModel) {
                            shoes.remove(at: index)
                        }
                    }
                    shoesToRemove.forEach { viewModel in
                        guard let shoe = viewModel.getShoe() else {
                            return
                        }
                        shoeStore.remove(shoe: shoe)
                    }
                    shoes = Self.generateViewModelsFromActiveShoes(from: shoeStore)
                    selectedShoeStrategy.updateSelectedShoe()
                }
            }
            .navigationDestination(for: Shoe.self) { shoe in
                if let viewModel = ShoeDetailViewModel(store: shoeStore, shoeURL: shoe.objectID.uriRepresentation()) {
                    ShoeDetailView(viewModel: viewModel,
                                   selectedShoeStrategy: selectedShoeStrategy)
                }

            }
            .navigationTitle("Active Shoes")
            .toolbar {
                Button("Add Shoe") {
                    let logger = AnalyticsFactory.sharedAnalyticsLogger()
                    logger.logEvent(name: AnalyticsKeys.Event.addShoeEvent, userInfo: nil)
                    presentNewShoeView = true
                }
            }
            .background(.patternedBackground)
        }
        .fullScreenCover(isPresented: $presentNewShoeView, onDismiss: {
            // Update view models to account for an added shoe
            shoes = Self.generateViewModelsFromActiveShoes(from: shoeStore)
        }) {
            let shoe = createShoe()
            ShoeDetailView(viewModel: ShoeDetailViewModel(store: shoeStore, shoeURL: shoe.objectID.uriRepresentation(), newShoe: shoe)!,
                           selectedShoeStrategy: selectedShoeStrategy)
        }
        .onAppear {
            selectedShoeStrategy.updateSelectedShoe()
        }
    }
    
    func createShoe() -> Shoe {
        let shoe = shoeStore.createShoe()
        shoeStore.saveContext()
        return shoe
    }
}

extension ActiveShoesView {
    static func generateViewModelsFromActiveShoes(from store: ShoeStore) -> [ShoeDetailViewModel] {
        return store.activeShoes.compactMap { shoe in
            return ShoeDetailViewModel(store: store, shoeURL: shoe.objectID.uriRepresentation())
        }
    }
}

struct ActiveShoesRowViewModel {
    let brand: String
    let totalDistance: Double
    let shoeURL: URL
}

struct ActiveShoesRowView: View {
    let viewModel: ActiveShoesRowViewModel
    @EnvironmentObject var settings: UserSettings
    var isSelected: Bool {
        settings.isSelected(shoeURL: viewModel.shoeURL)
    }
    
    private let distanceUtility = DistanceUtility()
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.brand)
                    .font(.title2)
                    .bold(isSelected)
                Spacer()
            }
            HStack {
                if isSelected == true {
                    Text("Selected")
                        .padding([.trailing], 8)
                        .foregroundColor(.shoeCycleOrange)
                }
                Text("Distance: \(distanceUtility.displayString(for: viewModel.totalDistance)) \(settings.distanceUnit.displayString())")
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .padding([.trailing], 16)
        .onTapGesture {
            settings.setSelected(shoeUrl: viewModel.shoeURL)
        }
        .animation(.linear, value: settings.selectedShoeURL)
    }
}

struct ActiveShoesView_Previews: PreviewProvider {
    static var shoes = ActiveShoesView.generateViewModelsFromActiveShoes(from: ShoeStore())
    static var shoeStore = ShoeStore()
    
    static var previews: some View {
        ActiveShoesView(shoes: shoes,
                        selectedShoeStrategy: SelectedShoeStrategy(store: shoeStore, settings: UserSettings.shared))
            .environmentObject(shoeStore)
    }
}

