//  SettingsFavoriteDistancesViewModel.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/17/23.
//  
//

import Combine


class SettingsFavoriteDistancesViewModel: ObservableObject {
    @Published var favorite1: String
    @Published var favorite2: String
    @Published var favorite3: String
    @Published var favorite4: String
    private let settings = UserSettings.shared
    private var subscriptions = Set<AnyCancellable>()
    private let formatter: NumberFormatter = .decimal
    
    private let distanceUtility = DistanceUtility()
    
    init() {
        favorite1 = distanceUtility.favoriteDistanceDisplayString(for: settings.favorite1)
        favorite2 = distanceUtility.favoriteDistanceDisplayString(for: settings.favorite2)
        favorite3 = distanceUtility.favoriteDistanceDisplayString(for: settings.favorite3)
        favorite4 = distanceUtility.favoriteDistanceDisplayString(for: settings.favorite4)
        initDebouncers()
    }
    
    private func initDebouncers() {
        let debounceTime = DispatchQueue.SchedulerTimeType.Stride.seconds(2)
        $favorite1
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite1 = self?.distanceUtility.distance(from: newString) ?? 0
            } )
            .store(in: &subscriptions)
        $favorite2
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite2 = self?.distanceUtility.distance(from: newString) ?? 0
            } )
            .store(in: &subscriptions)
        $favorite3
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite3 = self?.distanceUtility.distance(from: newString) ?? 0
            } )
            .store(in: &subscriptions)
        $favorite4
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite4 = self?.distanceUtility.distance(from: newString) ?? 0
            } )
            .store(in: &subscriptions)
    }
}
