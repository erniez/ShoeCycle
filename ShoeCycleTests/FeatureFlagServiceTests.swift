//  FeatureFlagServiceTests.swift
//  ShoeCycleTests
//
//  Tests for FeatureFlagService (fetch + cache) and the interactor's default-fallback path.
//  Covers the network → cache write, cached/offline fallback, unknown-key default, the kill
//  switch's fail-closed decode, and per-flag isolation (one malformed flag must not poison its
//  siblings in the same batch).
//

import XCTest
import SwiftUI
@testable import ShoeCycle

/// `@MainActor` because `FeatureFlagService`, `FeatureFlagIdentityProvider`, and
/// `FeatureFlagsInteractor` are all main-actor-isolated (ShoeCycle-Web-54b) — matching how these
/// types are actually driven in the app avoids sprinkling `await` on every synchronous call.
@MainActor
final class FeatureFlagServiceTests: XCTestCase {

    // Isolated UserDefaults per test — never pollute real user data.
    private func makeTestDefaults() -> UserDefaults {
        UserDefaults(suiteName: "com.shoecycle.tests.featureFlags.\(UUID().uuidString)")!
    }

    // MARK: - Fetch + cache

    // Given: The serve endpoint returns a valid FeatureFlagsResponse
    // When: loadFlags() is called
    // Then: Definitions are returned AND written to the UserDefaults cache
    func testLoadFlagsFetchesAndCaches() async {
        let network = StubRESTService()
        network.stub(data: Self.validPayload)
        let defaults = makeTestDefaults()
        let service = FeatureFlagService(network: network, userDefaults: defaults)

        let flags = await service.loadFlags()

        XCTAssertEqual(flags.count, 2)
        XCTAssertEqual(flags.first?.key, "alpha")
        // Cache was populated.
        XCTAssertEqual(service.cachedFlags.count, 2)
        XCTAssertNotNil(defaults.data(forKey: FeatureFlagService.Constant.cacheKey))
    }

    // MARK: - Offline / stale fallback (§4.3)

    // Given: A previously-cached good response, then the server becomes unreachable
    // When: loadFlags() is called and the network fails
    // Then: It degrades to the last cached definitions and never crashes
    func testOfflineFallbackUsesCache() async {
        let defaults = makeTestDefaults()

        // First: a successful fetch populates the cache.
        let primingNetwork = StubRESTService()
        primingNetwork.stub(data: Self.validPayload)
        _ = await FeatureFlagService(network: primingNetwork, userDefaults: defaults).loadFlags()

        // Then: the network fails (offline). A new service instance shares the same cache.
        let offlineNetwork = StubRESTService()
        offlineNetwork.stub(error: URLError(.notConnectedToInternet))
        let offlineService = FeatureFlagService(network: offlineNetwork, userDefaults: defaults)
        let flags = await offlineService.loadFlags()

        XCTAssertEqual(flags.count, 2, "Should fall back to last cached definitions")
        XCTAssertEqual(flags.first?.key, "alpha")
    }

    // Given: No cache has ever been written and the server is unreachable
    // When: loadFlags() is called
    // Then: It returns an empty array (evaluation then falls to caller defaults), no crash
    func testFirstLaunchOfflineReturnsEmpty() async {
        let network = StubRESTService()
        network.stub(error: URLError(.notConnectedToInternet))
        let service = FeatureFlagService(network: network, userDefaults: makeTestDefaults())

        let flags = await service.loadFlags()

        XCTAssertTrue(flags.isEmpty)
    }

    // Given: An empty (no-cache) service and an unknown flag key
    // When: The VSI state resolves the key with a caller default
    // Then: It returns the caller default rather than crashing
    func testDefaultFallbackForUnknownKeyOffline() async {
        let network = StubRESTService()
        network.stub(error: URLError(.notConnectedToInternet))
        let service = FeatureFlagService(network: network, userDefaults: makeTestDefaults())
        let interactor = FeatureFlagsInteractor(
            service: service,
            identityProvider: FeatureFlagIdentityProvider(userDefaults: makeTestDefaults())
        )

        let box = Box(FeatureFlagsState())
        let binding = Binding<FeatureFlagsState>(get: { box.value }, set: { box.value = $0 })
        await interactor.handle(state: binding, action: .viewAppeared)

        let state = box.value
        XCTAssertTrue(state.flags.isEmpty)
        XCTAssertFalse(state.isEnabled("anything"))
        XCTAssertTrue(state.isEnabled("anything", default: true))
        XCTAssertFalse(state.bucketingId.isEmpty, "Identity must be resolved before evaluation")
    }

    // Given: A successful viewAppeared resolves the demo badge ON, then the network fails on a
    //        later refresh (e.g. FeatureFlagsStore's periodic background timer hits a network blip)
    // When: .refresh is dispatched again against the now-offline service
    // Then: resolvedFlags is unchanged — a failed refresh must never wipe the last-good resolved
    //       state, only FeatureFlagService.loadFlags()'s cache-degrade contract keeps this true,
    //       and nothing previously pinned that one level up, through the interactor (code review)
    func testFailedRefreshPreservesLastGoodResolvedFlags() async {
        let defaults = makeTestDefaults()
        let network = StubRESTService()
        network.stub(data: Self.demoBadgeOnPayload)
        let service = FeatureFlagService(network: network, userDefaults: defaults)
        let interactor = FeatureFlagsInteractor(
            service: service,
            identityProvider: FeatureFlagIdentityProvider(userDefaults: makeTestDefaults())
        )

        let box = Box(FeatureFlagsState())
        let binding = Binding<FeatureFlagsState>(get: { box.value }, set: { box.value = $0 })
        await interactor.handle(state: binding, action: .viewAppeared)

        XCTAssertTrue(
            box.value.isEnabled(FeatureFlagKey.settingsDemoBadge),
            "Sanity: flag must resolve ON from the good fetch before the offline refresh"
        )

        // Same network stub instance, now failing — service.loadFlags() degrades to its own
        // cache (populated by the successful viewAppeared above), not to empty.
        network.stub(error: URLError(.notConnectedToInternet))
        await interactor.handle(state: binding, action: .refresh)

        XCTAssertTrue(
            box.value.isEnabled(FeatureFlagKey.settingsDemoBadge),
            "A failed refresh must preserve the last-good resolved value, not wipe it"
        )
    }

    private static let demoBadgeOnPayload = """
    { "flags": [
        { "key": "ios-settings-demo-badge", "enabled": true, "rolloutPercentage": 100 }
    ] }
    """.data(using: .utf8)!

    // MARK: - Kill switch fails CLOSED on malformed `enabled` (ShoeCycle-Web-rae, AC3)

    // Given: A served payload whose only flag's `enabled` kill switch is JSON null at 100% rollout
    // When: loadFlags() decodes it
    // Then: The malformed element is dropped (per-flag lenient decode, §54b) leaving an empty,
    //       successfully-decoded result — the killed flag NEVER resolves ON (fail-safe OFF)
    func testNullEnabledFailsClosedNotOpen() async {
        let network = StubRESTService()
        network.stub(data: Self.nullEnabledPayload)
        let service = FeatureFlagService(network: network, userDefaults: makeTestDefaults())

        let flags = await service.loadFlags()

        // The one malformed flag is dropped → no definitions → nothing resolves ON.
        XCTAssertTrue(flags.isEmpty, "A null `enabled` must not decode to a live ON flag")
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "kill-me", in: flags, bucketingId: Self.anyId),
            "Kill switch must fail safe-OFF, never OPEN"
        )
    }

    // Given: A served payload whose `enabled` is a type-mismatched string at 100% rollout
    // When: loadFlags() decodes it
    // Then: It fails safe-OFF (the element is dropped), never ON, never crash
    func testTypeMismatchedEnabledFailsClosedNotOpen() async {
        let network = StubRESTService()
        network.stub(data: Self.stringEnabledPayload)
        let service = FeatureFlagService(network: network, userDefaults: makeTestDefaults())

        let flags = await service.loadFlags()

        XCTAssertTrue(flags.isEmpty, "A wrong-typed `enabled` must not decode to a live ON flag")
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "kill-me", in: flags, bucketingId: Self.anyId)
        )
    }

    // MARK: - Per-flag isolation (ShoeCycle-Web-54b): one bad flag must not poison its siblings

    // Given: A batch containing one healthy flag and one malformed flag
    // When: loadFlags() decodes the mixed payload
    // Then: The malformed flag is dropped but the healthy sibling survives with FRESH data and
    //       is cached — a single corrupt definition does not take the rest of the batch down
    //       with it (this is the exact bug fixed on Android's twin implementation)
    func testOneMalformedFlagDoesNotPoisonHealthySiblingsInSameBatch() async {
        let defaults = makeTestDefaults()

        // Prime a STALE cache so a later assertion can tell "fresh from this fetch" apart from
        // "served from the old cache" — proves the healthy flag wasn't merely falling back.
        let primingNetwork = StubRESTService()
        primingNetwork.stub(data: Self.validPayload) // alpha: enabled=true, rollout=100
        _ = await FeatureFlagService(network: primingNetwork, userDefaults: defaults).loadFlags()

        // Next fetch: alpha flips to OFF (fresh value), alongside one malformed sibling.
        let mixedPayload = """
        { "flags": [
            { "key": "alpha", "enabled": false, "rolloutPercentage": 100 },
            { "key": "kill-me", "enabled": null, "rolloutPercentage": 100 }
        ] }
        """.data(using: .utf8)!
        let network = StubRESTService()
        network.stub(data: mixedPayload)
        let service = FeatureFlagService(network: network, userDefaults: defaults)

        let flags = await service.loadFlags()

        XCTAssertEqual(flags.count, 1, "The malformed 'kill-me' element must be dropped, not poison the whole batch")
        XCTAssertEqual(flags.first?.key, "alpha")
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "alpha", in: flags, bucketingId: Self.anyId),
            "alpha must reflect the FRESH value from this fetch, not the stale cached one"
        )
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "kill-me", in: flags, bucketingId: Self.anyId),
            "The dropped flag resolves via the unknown-key default, which is OFF"
        )
        XCTAssertEqual(service.cachedFlags.count, 1, "The fresh (post-drop) result must be what gets cached")
    }

    // Given: A good cache, then a later fetch's payload contains ONLY a malformed flag
    // When: loadFlags() decodes it
    // Then: The malformed element is dropped, leaving an empty but SUCCESSFULLY decoded result
    //       (not a thrown error) — and that empty result overwrites the cache. This matches
    //       Android's LenientFeatureFlagListSerializer: "every flag in this batch was corrupt" is
    //       treated the same as "the server legitimately sent zero flags" — self-healing on the
    //       next good fetch, and no less safe than the old whole-payload rejection (still
    //       fail-closed OFF either way).
    func testBatchWhereEveryFlagIsMalformedDecodesToEmptyAndOverwritesCache() async {
        let defaults = makeTestDefaults()

        let primingNetwork = StubRESTService()
        primingNetwork.stub(data: Self.validPayload)
        _ = await FeatureFlagService(network: primingNetwork, userDefaults: defaults).loadFlags()

        let network = StubRESTService()
        network.stub(data: Self.nullEnabledPayload) // the ONLY element is malformed
        let service = FeatureFlagService(network: network, userDefaults: defaults)

        let flags = await service.loadFlags()

        XCTAssertTrue(flags.isEmpty)
        XCTAssertTrue(
            service.cachedFlags.isEmpty,
            "A fully-malformed batch is itself a successful (empty) decode, and caches like any other successful fetch"
        )
    }

    // MARK: - Payloads

    private static let anyId = "a1b2c3d4-0000-4000-8000-000000000001"

    private static let validPayload = """
    { "flags": [
        { "key": "alpha", "enabled": true, "rolloutPercentage": 100 },
        { "key": "beta", "enabled": false, "rolloutPercentage": 50 }
    ] }
    """.data(using: .utf8)!

    // Hostile: the master kill switch is JSON null but rollout is 100% — must NOT resolve ON.
    private static let nullEnabledPayload = """
    { "flags": [
        { "key": "kill-me", "enabled": null, "rolloutPercentage": 100 }
    ] }
    """.data(using: .utf8)!

    // Hostile: `enabled` is a type-mismatched string — must fail safe, not crash or fail open.
    private static let stringEnabledPayload = """
    { "flags": [
        { "key": "kill-me", "enabled": "true", "rolloutPercentage": 100 }
    ] }
    """.data(using: .utf8)!
}

// MARK: - Test helpers

/// Reference box so an async interactor can mutate state through a Binding in a test.
private final class Box<T> {
    var value: T
    init(_ value: T) { self.value = value }
}

/// Minimal `RESTService` stub for deterministic, network-free tests. Replaces a bespoke
/// `URLProtocol` harness now that `FeatureFlagService` goes through the shared `RESTService`
/// abstraction (ShoeCycle-Web-54b) — matching how Strava's services are tested. Each test
/// creates its own instance, so (unlike a static-state `URLProtocol` stub) nothing here requires
/// serial test execution to stay deterministic.
///
/// `@MainActor`-isolated deliberately, not coincidentally: this stub's mutable `stubbedData` /
/// `stubbedError` are plain (non-`Sendable`) `var`s, unlike the real `NetworkService`, which is
/// safe to call from any isolation. Confining the stub to the same actor as the `@MainActor` test
/// class that owns it makes that safety structural instead of relying on every test happening to
/// call it single-threaded.
@MainActor
private final class StubRESTService: RESTService {
    enum DomainError: Error {
        case unknown
    }

    private var stubbedData: Data?
    private var stubbedError: Error?

    func stub(data: Data) {
        stubbedData = data
        stubbedError = nil
    }

    func stub(error: Error) {
        stubbedError = error
        stubbedData = nil
    }

    func getJSONData<T: Decodable>(url: URL) async throws -> T {
        if let error = stubbedError { throw error }
        guard let data = stubbedData else { throw DomainError.unknown }
        return try data.jsonDecode()
    }

    func getData(url: URL) async throws -> Data {
        if let error = stubbedError { throw error }
        return stubbedData ?? Data()
    }

    func postJSON(dto: Encodable, url: URL, authToken: String?) async throws -> Data {
        Data()
    }

    func post(request: URLRequest, data: Data) async throws -> Data {
        Data()
    }
}
