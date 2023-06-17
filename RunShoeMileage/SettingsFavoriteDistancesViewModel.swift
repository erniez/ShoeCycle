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
    private let settings = UserSettings()
    private var subscriptions = Set<AnyCancellable>()
    private let formatter: NumberFormatter = .decimal
    
    init() {
        // TODO: Need to take into account the unit of measure setting.
        favorite1 = formatter.string(from: NSNumber(value: settings.favorite1)) ?? ""
        favorite2 = formatter.string(from: NSNumber(value: settings.favorite2)) ?? ""
        favorite3 = formatter.string(from: NSNumber(value: settings.favorite3)) ?? ""
        favorite4 = formatter.string(from: NSNumber(value: settings.favorite4)) ?? ""
        initDebouncers()
    }
    
    private func initDebouncers() {
        let debounceTime = DispatchQueue.SchedulerTimeType.Stride.seconds(2)
        $favorite1
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite1 = Float(newString) ?? 0
            } )
            .store(in: &subscriptions)
        $favorite2
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite2 = Float(newString) ?? 0
            } )
            .store(in: &subscriptions)
        $favorite3
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite3 = Float(newString) ?? 0
            } )
            .store(in: &subscriptions)
        $favorite4
            .debounce(for: debounceTime, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newString in
                self?.settings.favorite4 = Float(newString) ?? 0
            } )
            .store(in: &subscriptions)
    }
}
