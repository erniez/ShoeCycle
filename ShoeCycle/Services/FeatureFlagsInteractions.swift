//  FeatureFlagsInteractions.swift
//  ShoeCycle
//
//  VSI layer for feature toggles: an interactor owns the fetch + evaluation, a FeatureFlags
//  state struct carries only the RESOLVED boolean results, and views observe those via
//  `isEnabled(_:default:)` — never the raw service or evaluation logic
//  (architecture/vsi-pattern.md).
//

import SwiftUI

// MARK: - State (data only)

/// Feature-flag feature state. Views never mutate this directly and never re-implement
/// evaluation — `isEnabled` is a trivial dictionary lookup, not a computation (VSI: "State is
/// data, no methods that perform work"). The evaluator + hashing run once in the interactor
/// whenever flags/identity are (re)loaded, not on every read.
struct FeatureFlagsState {
    /// The raw definitions from the last successful load/cache seed. Exposed for
    /// debugging/tests; views should read `isEnabled`, never this.
    fileprivate(set) var flags: [FeatureFlag] = []

    /// The bucketing identity resolved once at load time and reused for every evaluation so a
    /// caller stays in / out of a cohort consistently within a session.
    fileprivate(set) var bucketingId: String = ""

    /// Resolved boolean values for `FeatureFlagsInteractor.trackedKeys`, computed once by the
    /// interactor per load/refresh. A key absent from this map was never tracked; `isEnabled`
    /// falls back to the caller's `default` for it, same as an unknown server key (§4.2).
    fileprivate(set) var resolvedFlags: [String: Bool] = [:]

    /// Resolve a tracked flag key to its already-computed boolean. Untracked/unknown key → the
    /// supplied `default` (else `false`). Never crashes, never hashes.
    func isEnabled(_ key: String, default defaultValue: Bool = false) -> Bool {
        resolvedFlags[key] ?? defaultValue
    }
}

// MARK: - Interactor (all logic + side effects)

/// Owns feature-flag fetch, caching fallback, identity resolution, and evaluation. The only
/// place that touches `FeatureFlagService`, `FeatureFlagIdentityProvider`, and
/// `FeatureFlagEvaluator`.
///
/// `handle` is `@MainActor`-isolated (ShoeCycle-Web-54b): it mutates a SwiftUI-observed
/// `Binding`, and every other async interactor in this codebase (e.g. `StravaInteractor`)
/// explicitly hops to the main actor before touching UI state. Isolating `handle` gets the same
/// guarantee — the network fetch inside `service.loadFlags()` still runs on its own
/// (non-isolated) executor, but every line that writes `state.wrappedValue` runs back on the
/// main actor after the `await` resumes. The initializer is deliberately left nonisolated so its
/// default parameter values (which construct other types' plain initializers) keep working —
/// Swift evaluates default-argument expressions in a synchronous nonisolated context regardless
/// of the callee's own isolation.
struct FeatureFlagsInteractor {

    enum Action {
        /// Load flags: seed from cache immediately for a non-flickering launch, then refresh
        /// from the network in the background.
        case viewAppeared
        /// Refresh definitions from the network (cache fallback on failure). Called by
        /// `FeatureFlagsStore`'s periodic background timer once the app has launched.
        case refresh
    }

    private let service: FeatureFlagLoading
    private let identityProvider: FeatureFlagIdentityProviding
    private let trackedKeys: [String]

    init(
        service: FeatureFlagLoading = FeatureFlagService(),
        identityProvider: FeatureFlagIdentityProviding = FeatureFlagIdentityProvider(),
        trackedKeys: [String] = FeatureFlagKey.allKeys
    ) {
        self.service = service
        self.identityProvider = identityProvider
        self.trackedKeys = trackedKeys
    }

    /// Async because the network fetch is async; the interactor owns the Task/await, not the
    /// caller. Callers dispatch and re-render when state changes.
    @MainActor
    func handle(state: Binding<FeatureFlagsState>, action: Action) async {
        switch action {
        case .viewAppeared:
            // Resolve identity up front (generates + persists the anon UUID synchronously if
            // needed — never an empty bucketing id).
            state.wrappedValue.bucketingId = identityProvider.bucketingId()
            // Seed from last-good cache immediately so evaluation works offline / pre-fetch.
            resolve(flags: service.cachedFlags, into: state)
            await handle(state: state, action: .refresh)

        case .refresh:
            if state.wrappedValue.bucketingId.isEmpty {
                state.wrappedValue.bucketingId = identityProvider.bucketingId()
            }
            let flags = await service.loadFlags()
            resolve(flags: flags, into: state)
        }
    }

    /// Evaluates every tracked key ONCE against `flags`/the current bucketing id and writes the
    /// resolved booleans into state. This is the only place `FeatureFlagEvaluator` is called —
    /// views read the result, they never hash. Always called from `handle`, so it inherits the
    /// same main-actor guarantee; marked explicitly for clarity and so a future nonisolated
    /// caller would be caught at compile time.
    @MainActor
    private func resolve(flags: [FeatureFlag], into state: Binding<FeatureFlagsState>) {
        let bucketingId = state.wrappedValue.bucketingId
        let resolved = Dictionary(uniqueKeysWithValues: trackedKeys.map { key in
            (key, FeatureFlagEvaluator.isEnabled(key: key, in: flags, bucketingId: bucketingId))
        })
        state.wrappedValue.flags = flags
        state.wrappedValue.resolvedFlags = resolved
    }
}

// MARK: - Known flag keys

/// Central registry of flag keys so views reference constants, not string literals.
enum FeatureFlagKey {
    /// Trivial reversible demo flag proving end-to-end wiring (gates a badge in Settings).
    static let settingsDemoBadge = "ios-settings-demo-badge"

    /// All flag keys the app currently resolves at load time. Add a new key here so
    /// `FeatureFlagsInteractor` tracks it — an untracked key always falls back to the caller's
    /// `default` in `isEnabled`, as if the server didn't know about it either.
    static let allKeys: [String] = [settingsDemoBadge]
}
