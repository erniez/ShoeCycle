//  FeatureFlagService.swift
//  ShoeCycle
//
//  Fetches the PUBLIC feature-flag serve endpoint (no auth header) through the shared
//  `RESTService` networking abstraction — the same pattern StravaService / StravaTokenKeeper use
//  — decodes the definitions, and caches the last good response for offline / stale fallback
//  (architecture/feature-toggles.md §4.3).
//

import Foundation
import OSLog

/// Loads feature-flag definitions from the public serve endpoint and persists the last good
/// response so evaluation can degrade gracefully offline.
protocol FeatureFlagLoading {
    /// Fetches fresh definitions from the network and, on success, updates the cache. On any
    /// network/parse failure, returns the last cached definitions (or an empty array if there
    /// is no cache). Never throws — flag loading must never block app launch.
    func loadFlags() async -> [FeatureFlag]

    /// The last successfully-cached definitions, without touching the network. Empty if the
    /// cache has never been populated.
    var cachedFlags: [FeatureFlag] { get }
}

final class FeatureFlagService: FeatureFlagLoading {

    /// Pinned configuration — endpoint path, cache key, refresh interval (no magic numbers, §5).
    enum Constant {
        /// Public serve endpoint (unauthenticated). Path pinned by sub-issue C's OpenAPI.
        static let endpoint = URL(string: "https://api.shoecycleapp.com/api/feature-flags")!
        /// UserDefaults key for the cached last-good definitions.
        static let cacheKey = "com.shoecycle.featureToggles.cachedFlags"
        /// How often `FeatureFlagsStore` re-fetches definitions in the background once the app
        /// has launched (ShoeCycle-Web-54b). This interval IS the staleness bound — there is no
        /// separate freshness check on the cache itself, because a stale-but-present cache must
        /// still be served as the offline fallback regardless of its age (§4.3).
        static let refreshInterval: TimeInterval = 60 * 60 // 1 hour
    }

    private let network: any RESTService
    private let userDefaults: UserDefaults

    /// - Parameters:
    ///   - network: Any object that conforms to RESTService. Defaults to NetworkService().
    ///   - userDefaults: persistence for the cached last-good response.
    init(network: any RESTService = NetworkService(), userDefaults: UserDefaults = .standard) {
        self.network = network
        self.userDefaults = userDefaults
    }

    // MARK: - Loading

    func loadFlags() async -> [FeatureFlag] {
        do {
            // PUBLIC endpoint: getJSONData never attaches an Authorization header.
            let response: FeatureFlagsResponse = try await network.getJSONData(url: Constant.endpoint)
            cache(response.flags)
            return response.flags
        } catch {
            // Network, HTTP-status, or parse failure never crashes and never blocks launch: fall
            // back to the last cached definitions (§4.3). Logged regardless of failure kind so an
            // operator can distinguish "server down" from "payload changed shape" in the field.
            Logger.app.error("Feature flag fetch failed, using cache: \(String(describing: error))")
            return cachedFlags
        }
    }

    // MARK: - Cache

    var cachedFlags: [FeatureFlag] {
        guard let entry = cachedEntry() else { return [] }
        return entry.flags
    }

    /// The cache entry including its timestamp, or nil if none / undecodable.
    private func cachedEntry() -> CacheEntry? {
        guard let data = userDefaults.data(forKey: Constant.cacheKey) else { return nil }
        do {
            return try data.jsonDecode()
        } catch {
            Logger.app.error("Failed to decode cached feature flags: \(String(describing: error))")
            return nil
        }
    }

    private func cache(_ flags: [FeatureFlag]) {
        let entry = CacheEntry(flags: flags, timestamp: Date())
        do {
            userDefaults.set(try entry.jsonEncode(), forKey: Constant.cacheKey)
        } catch {
            Logger.app.error("Failed to cache feature flags: \(String(describing: error))")
        }
    }

    private struct CacheEntry: Codable {
        let flags: [FeatureFlag]
        let timestamp: Date
    }
}
