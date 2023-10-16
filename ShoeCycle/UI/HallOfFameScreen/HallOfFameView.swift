//  HallOfFameView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/7/23.
//  
//

import SwiftUI


struct HallOfFameView: View {
    @EnvironmentObject var shoeStore: ShoeStore
    @EnvironmentObject var settings: UserSettings
    @State var shoeRowViewModels: [ShoeListRowViewModel]
    
    var body: some View {
        Group {
            if shoeStore.hallOfFameShoes.isEmpty {
                Text("You have no shoes in the Hall of Fame. Please go to the Active Shoes tab and edit the shoe you want to add.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            else {
                NavigationStack {
                    List {
                        ForEach(shoeRowViewModels, id: \.shoeURL) { viewModel in
                            NavigationLink(value: viewModel) {
                                HallOfFameRowView(viewModel: viewModel)
                            }
                        }
                        .onDelete { indexSet in
                            let shoesToRemove = indexSet.map { shoeRowViewModels[$0] }
                            shoesToRemove.forEach { shoeStore.removeShoe(with: $0.shoeURL) }
                        }
                        .onMove { fromOffsets, toOffset in
                            let urls = shoeRowViewModels.getShoeURLs(fromOffsets: fromOffsets, toOffset: toOffset)
                            // Short circuiting the UDF here to allow for smooth UI
                            shoeRowViewModels.move(fromOffsets: fromOffsets, toOffset: toOffset)
                            Task {
                                // We don't want to interrupt the UI, so we put this operation in a background thread.
                                shoeStore.adjustShoeOrderingValue(fromOffsetURL: urls.fromURL, toOffsetURL: urls.toURL)
                            }
                        }
                    }
                    .navigationDestination(for: ShoeListRowViewModel.self) { viewModel in
                        if let detailViewModel = ShoeDetailViewModel(store: shoeStore, shoeURL: viewModel.shoeURL) {
                            ShoeDetailView(viewModel: detailViewModel)
                        }
                    }
                    .navigationTitle("Hall of Fame Shoes")
                }
            }
        }
        // Monitor hall of fame shoes for deletions and additions.
        // Individual shoe detail changes are observed from within the view model
        .onChange(of: shoeStore.hallOfFameShoes) { newValue in
            shoeRowViewModels = ShoeListRowViewModel.generateShoeViewModels(from: newValue)
        }
    }
}



struct HallOfFameRowView: View {
    @EnvironmentObject var settings: UserSettings
    private let viewModel: ShoeListRowViewModel
    private let distanceUtility = DistanceUtility()
    
    init(viewModel: ShoeListRowViewModel) {
        viewModel.startObservingShoe()
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.brand)
                Spacer()
            }
            HStack {
                Text("Distance: \(distanceUtility.displayString(for: viewModel.totalDistance)) \(settings.distanceUnit.displayString())")
                Spacer()
            }
        }
        .contentShape(Rectangle())
    }
}

