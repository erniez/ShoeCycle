//  FeatureFlagsStore.swift
//  ShoeCycle
//
//  App-level owner of feature-flag state (ShoeCycle-Web-54b). Flags are global config, not a
//  per-screen concern: this store loads once at app launch and refreshes on a background timer
//  thereafter, so every gated view shares one fetch, one cache, and one resolved answer for a
//  given key within a session — no two screens can disagree about the same flag.
//
//  Injected once at the app root via `.environmentObject` (AppView.swift), the same way
//  `ShoeStore` / `UserSettings` / `HealthKitService` are shared app-wide. A gated view adds
//  `@EnvironmentObject var featureFlags: FeatureFlagsStore` and calls `isEnabled(_:default:)` —
//  it never owns its own interactor or fetch.
//

import SwiftUI

@MainActor
final class FeatureFlagsStore: ObservableObject {
    @Published fileprivate(set) var state = FeatureFlagsState()

    private let interactor: FeatureFlagsInteractor
    private let refreshInterval: TimeInterval
    private var refreshTask: Task<Void, Never>?

    init(
        interactor: FeatureFlagsInteractor = FeatureFlagsInteractor(),
        refreshInterval: TimeInterval = FeatureFlagService.Constant.refreshInterval
    ) {
        self.interactor = interactor
        self.refreshInterval = refreshInterval
    }

    /// Loads flags immediately (cache-seeded, then network-refreshed), then re-fetches from the
    /// network every `refreshInterval` for as long as the app runs. Idempotent — safe to call
    /// from `onAppear`, which can fire more than once per app session.
    func start() {
        guard refreshTask == nil else { return }
        refreshTask = Task { [weak self] in
            guard let self else { return }
            await self.dispatch(.viewAppeared)
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(self.refreshInterval))
                guard !Task.isCancelled else { return }
                await self.dispatch(.refresh)
            }
        }
    }

    /// Cancels the periodic refresh loop. Not currently called in production (the store lives
    /// for the app's lifetime); exposed for tests that need a clean teardown.
    func stop() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    /// Resolve a tracked flag key to its already-computed boolean. See `FeatureFlagsState.isEnabled`.
    func isEnabled(_ key: String, default defaultValue: Bool = false) -> Bool {
        state.isEnabled(key, default: defaultValue)
    }

    private func dispatch(_ action: FeatureFlagsInteractor.Action) async {
        let binding = Binding(get: { self.state }, set: { self.state = $0 })
        await interactor.handle(state: binding, action: action)
    }
}
