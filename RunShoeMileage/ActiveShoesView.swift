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
    // Need the following array to keep track of deletions and additions, otherwise
    // we will get out of sink of the actually datasource, activeShoes
    @State private var shoeRowViewModels: [ActiveShoesRowViewModel]
    @State private var presentNewShoeView = false
    private var selectedShoeStrategy: SelectedShoeStrategy
    
    init(viewModels: [ActiveShoesRowViewModel], presentNewShoeView: Bool = false, selectedShoeStrategy: SelectedShoeStrategy) {
        self.shoeRowViewModels = viewModels
        self.presentNewShoeView = presentNewShoeView
        self.selectedShoeStrategy = selectedShoeStrategy
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Self.generateActiveShoeViewModels(from: shoeStore.activeShoes), id: \.shoeURL) { shoe in
                    // TODO: Ideally we want to only deal with view models (as below)
//                ForEach(shoeRowViewModels, id: \.shoeURL) { shoe in
                    // Unfortunately, we can't key off of onChange: activeShoes, because when we only modify the shoe, the
                    // activeShoes array doesn't publish a change, because the shoes are reference types. I need to come back to this
                    // once I have a better idea.
                    NavigationLink(value: shoe) {
                        ActiveShoesRowView(viewModel: shoe)
                    }
                }
                .onDelete { indexSet in
                    let shoesToRemove = indexSet.map { shoeRowViewModels[$0] }
                    shoesToRemove.forEach { viewModel in
                        if let index = shoeRowViewModels.firstIndex(of: viewModel) {
                            shoeRowViewModels.remove(at: index)
                        }
                    }
                    shoesToRemove.forEach { shoeStore.removeShoe(with: $0.shoeURL) }
                    shoeRowViewModels = Self.generateActiveShoeViewModels(from: shoeStore.activeShoes)
                    selectedShoeStrategy.updateSelectedShoe()
                }
            }
            .navigationDestination(for: ActiveShoesRowViewModel.self) { viewModel in
                if let viewModel = ShoeDetailViewModel(store: shoeStore, shoeURL: viewModel.shoeURL) {
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
        .fullScreenCover(isPresented: $presentNewShoeView) {
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
    static func generateActiveShoeViewModels(from shoes: [Shoe]) -> [ActiveShoesRowViewModel] {
        return shoes.compactMap { shoe in
            return ActiveShoesRowViewModel(brand: shoe.brand,
                                           totalDistance: shoe.totalDistance.doubleValue,
                                           shoeURL: shoe.objectID.uriRepresentation())
        }
    }
}

struct ActiveShoesRowViewModel: Hashable {
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
    static var shoes = ActiveShoesView.generateActiveShoeViewModels(from: ShoeStore().activeShoes)
    static var shoeStore = ShoeStore()
    
    static var previews: some View {
        ActiveShoesView(viewModels: shoes,
                        selectedShoeStrategy: SelectedShoeStrategy(store: shoeStore, settings: UserSettings.shared))
            .environmentObject(shoeStore)
    }
}

