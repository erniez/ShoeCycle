//  ActiveShoesView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI


struct ActiveShoesView: View {
    @EnvironmentObject private var shoeStore: ShoeStore
    @EnvironmentObject private var settings: UserSettings
    @State private var shoeRowViewModels: [ShoeListRowViewModel]
    @State private var presentNewShoeView = false
    private var selectedShoeStrategy: SelectedShoeStrategy
    
    init(viewModels: [ShoeListRowViewModel], presentNewShoeView: Bool = false, selectedShoeStrategy: SelectedShoeStrategy) {
        self.shoeRowViewModels = viewModels
        self.presentNewShoeView = presentNewShoeView
        self.selectedShoeStrategy = selectedShoeStrategy
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(shoeRowViewModels, id: \.shoeURL) { viewModel in
                    NavigationLink(value: viewModel) {
                        ActiveShoesRowView(viewModel: viewModel)
                    }
                }
                .onDelete { indexSet in
                    let shoesToRemove = indexSet.map { shoeRowViewModels[$0] }
                    shoesToRemove.forEach { shoeStore.removeShoe(with: $0.shoeURL) }
                    selectedShoeStrategy.updateSelectedShoe()
                }
            }
            .navigationDestination(for: ShoeListRowViewModel.self) { viewModel in
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
            shoeRowViewModels = ShoeListRowViewModel.generateShoeViewModels(from: newValue)
        }
    }
    
    func createShoe() -> Shoe {
        let shoe = shoeStore.createShoe()
        return shoe
    }
}

class ShoeListRowViewModel: Hashable {
    private let shoeObserver: CoreDataObserver<Shoe>
    var brand: String
    var totalDistance: Double
    let shoeURL: URL
    
    init(shoeObserver: CoreDataObserver<Shoe>, brand: String, totalDistance: Double, shoeURL: URL) {
        self.shoeObserver = shoeObserver
        self.brand = brand
        self.totalDistance = totalDistance
        self.shoeURL = shoeURL
    }
    
    func startObservingShoe() {
        shoeObserver.startObserving { [weak self] shoe in
            self?.brand = shoe.brand
            self?.totalDistance = shoe.totalDistance.doubleValue
        }
    }
    
    static func == (lhs: ShoeListRowViewModel, rhs: ShoeListRowViewModel) -> Bool {
        lhs.shoeURL == rhs.shoeURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shoeURL)
    }
}

extension ShoeListRowViewModel {
    static func generateShoeViewModels(from shoes: [Shoe]) -> [ShoeListRowViewModel] {
        return shoes.compactMap { shoe in
            let shoeObserver = CoreDataObserver(object: shoe)
            return ShoeListRowViewModel(shoeObserver: shoeObserver,
                                        brand: shoe.brand,
                                        totalDistance: shoe.totalDistance.doubleValue,
                                        shoeURL: shoe.objectID.uriRepresentation())
        }
    }
}


struct ActiveShoesRowView: View {
    @EnvironmentObject var settings: UserSettings
    private let viewModel: ShoeListRowViewModel
    private let distanceUtility = DistanceUtility()
    private var isSelected: Bool {
        settings.isSelected(shoeURL: viewModel.shoeURL)
    }
    
    init(viewModel: ShoeListRowViewModel) {
        viewModel.startObservingShoe()
        self.viewModel = viewModel
    }
    
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
    static var shoes = ShoeListRowViewModel.generateShoeViewModels(from: ShoeStore().activeShoes)
    static var shoeStore = ShoeStore()
    
    static var previews: some View {
        ActiveShoesView(viewModels: shoes,
                        selectedShoeStrategy: SelectedShoeStrategy(store: shoeStore, settings: UserSettings.shared))
            .environmentObject(shoeStore)
    }
}

