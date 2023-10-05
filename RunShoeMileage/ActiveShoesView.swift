//  ActiveShoesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI
import Combine

class ShoeDataObserver: ObservableObject {
    @Published var shoe: Shoe
    
    init(shoe: Shoe) {
        self.shoe = shoe
    }
}

struct ActiveShoesView: View {
    @EnvironmentObject private var shoeStore: ShoeStore
    @EnvironmentObject private var settings: UserSettings
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
                ForEach(shoeRowViewModels, id: \.shoeURL) { shoe in
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
        // Monitor active shoes for deletions and additions.
        // Individual shoe detail changes are observed from within the view model
        .onChange(of: shoeStore.activeShoes) { newValue in
            shoeRowViewModels = Self.generateActiveShoeViewModels(from: newValue)
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
            let shoeObserver = ShoeDataObserver(shoe: shoe)
            return ActiveShoesRowViewModel(shoeObserver: shoeObserver,
                                           brand: shoe.brand,
                                           totalDistance: shoe.totalDistance.doubleValue,
                                           shoeURL: shoe.objectID.uriRepresentation())
        }
    }
}

class ActiveShoesRowViewModel: Hashable {
    
    private let shoeObserver: ShoeDataObserver
    private var shoeCancellabe: AnyCancellable?
    var brand: String
    var totalDistance: Double
    let shoeURL: URL
    
    init(shoeObserver: ShoeDataObserver, brand: String, totalDistance: Double, shoeURL: URL) {
        self.shoeObserver = shoeObserver
        self.brand = brand
        self.totalDistance = totalDistance
        self.shoeURL = shoeURL
    }
    
    func startObservingShoe() {
        shoeCancellabe = shoeObserver.$shoe.sink(receiveValue: { [weak self] shoe in
            self?.brand = shoe.brand
            self?.totalDistance = shoe.totalDistance.doubleValue
        })
    }
    
    static func == (lhs: ActiveShoesRowViewModel, rhs: ActiveShoesRowViewModel) -> Bool {
        lhs.shoeURL == rhs.shoeURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shoeURL)
    }
}

struct ActiveShoesRowView: View {
    let viewModel: ActiveShoesRowViewModel
    @EnvironmentObject var settings: UserSettings
    var isSelected: Bool {
        settings.isSelected(shoeURL: viewModel.shoeURL)
    }
    
    init(viewModel: ActiveShoesRowViewModel) {
        viewModel.startObservingShoe()
        self.viewModel = viewModel
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

