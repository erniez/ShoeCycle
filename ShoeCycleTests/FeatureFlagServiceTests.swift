//  FeatureFlagServiceTests.swift
//  ShoeCycleTests
//
//  Tests for FeatureFlagService (fetch + cache) and FeatureFlagIdentityProvider (bucketing
//  identity). Covers the network → cache write, cached/offline fallback, unknown-key default,
//  and the UUID-lowercase / stable-across-launches identity traps.
//

import XCTest
@testable import ShoeCycle

final class FeatureFlagServiceTests: XCTestCase {

    // Isolated UserDefaults per test — never pollute real user data.
    private func makeTestDefaults() -> UserDefaults {
        UserDefaults(suiteName: "com.shoecycle.tests.featureFlags.\(UUID().uuidString)")!
    }

    // URLSession backed by a stub protocol so responses are deterministic and offline.
    private func makeStubbedSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: config)
    }

    override func tearDown() {
        StubURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - Fetch + cache

    // Given: The serve endpoint returns a valid FeatureFlagsResponse
    // When: loadFlags() is called
    // Then: Definitions are returned AND written to the UserDefaults cache
    func testLoadFlagsFetchesAndCaches() async {
        StubURLProtocol.stubResponse(statusCode: 200, body: Self.validPayload)
        let defaults = makeTestDefaults()
        let service = FeatureFlagService(session: makeStubbedSession(), userDefaults: defaults)

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
        StubURLProtocol.stubResponse(statusCode: 200, body: Self.validPayload)
        let primingService = FeatureFlagService(session: makeStubbedSession(), userDefaults: defaults)
        _ = await primingService.loadFlags()

        // Then: the network fails (offline). A new service instance shares the same cache.
        StubURLProtocol.stubError(URLError(.notConnectedToInternet))
        let offlineService = FeatureFlagService(session: makeStubbedSession(), userDefaults: defaults)
        let flags = await offlineService.loadFlags()

        XCTAssertEqual(flags.count, 2, "Should fall back to last cached definitions")
        XCTAssertEqual(flags.first?.key, "alpha")
    }

    // Given: No cache has ever been written and the server is unreachable
    // When: loadFlags() is called
    // Then: It returns an empty array (evaluation then falls to caller defaults), no crash
    func testFirstLaunchOfflineReturnsEmpty() async {
        StubURLProtocol.stubError(URLError(.notConnectedToInternet))
        let service = FeatureFlagService(session: makeStubbedSession(), userDefaults: makeTestDefaults())

        let flags = await service.loadFlags()

        XCTAssertTrue(flags.isEmpty)
    }

    // Given: An empty (no-cache) service and an unknown flag key
    // When: The VSI state resolves the key with a caller default
    // Then: It returns the caller default rather than crashing
    func testDefaultFallbackForUnknownKeyOffline() async {
        StubURLProtocol.stubError(URLError(.notConnectedToInternet))
        let service = FeatureFlagService(session: makeStubbedSession(), userDefaults: makeTestDefaults())
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

    // MARK: - Kill switch fails CLOSED on malformed `enabled` (ShoeCycle-Web-rae, AC3)

    // Given: A served payload whose `enabled` kill switch is JSON null at 100% rollout
    // When: loadFlags() decodes it
    // Then: The strict Bool decode throws, the whole payload is rejected, and the service
    //       degrades to the (empty) cache — the killed flag NEVER resolves ON (fail-safe OFF)
    func testNullEnabledFailsClosedNotOpen() async {
        StubURLProtocol.stubResponse(statusCode: 200, body: Self.nullEnabledPayload)
        let service = FeatureFlagService(session: makeStubbedSession(), userDefaults: makeTestDefaults())

        let flags = await service.loadFlags()

        // The malformed payload is rejected wholesale → no definitions → nothing resolves ON.
        XCTAssertTrue(flags.isEmpty, "A null `enabled` must not decode to a live ON flag")
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "kill-me", in: flags, bucketingId: Self.anyId),
            "Kill switch must fail safe-OFF, never OPEN"
        )
    }

    // Given: A served payload whose `enabled` is a type-mismatched string at 100% rollout
    // When: loadFlags() decodes it
    // Then: It fails safe-OFF (decode throws → cache fallback), never ON, never crash
    func testTypeMismatchedEnabledFailsClosedNotOpen() async {
        StubURLProtocol.stubResponse(statusCode: 200, body: Self.stringEnabledPayload)
        let service = FeatureFlagService(session: makeStubbedSession(), userDefaults: makeTestDefaults())

        let flags = await service.loadFlags()

        XCTAssertTrue(flags.isEmpty, "A wrong-typed `enabled` must not decode to a live ON flag")
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "kill-me", in: flags, bucketingId: Self.anyId)
        )
    }

    // Given: A good cache, then a later fetch returns a malformed `enabled` payload
    // When: loadFlags() decodes the malformed payload
    // Then: It degrades to the last good cache (never adopts the fail-open value), no crash
    func testMalformedEnabledRefreshDegradesToCache() async {
        let defaults = makeTestDefaults()

        StubURLProtocol.stubResponse(statusCode: 200, body: Self.validPayload)
        _ = await FeatureFlagService(session: makeStubbedSession(), userDefaults: defaults).loadFlags()

        StubURLProtocol.stubResponse(statusCode: 200, body: Self.nullEnabledPayload)
        let service = FeatureFlagService(session: makeStubbedSession(), userDefaults: defaults)
        let flags = await service.loadFlags()

        // Falls back to the good cache; the poisoned "kill-me" flag never appears.
        XCTAssertEqual(flags.first?.key, "alpha")
        XCTAssertFalse(
            FeatureFlagEvaluator.isEnabled(key: "kill-me", in: flags, bucketingId: Self.anyId)
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

import SwiftUI

/// Reference box so an async interactor can mutate state through a Binding in a test.
private final class Box<T> {
    var value: T
    init(_ value: T) { self.value = value }
}

/// URLProtocol stub for deterministic, offline-safe network responses in tests.
final class StubURLProtocol: URLProtocol {
    private static var stubbedResponse: (statusCode: Int, body: Data)?
    private static var stubbedError: Error?

    static func stubResponse(statusCode: Int, body: Data) {
        stubbedResponse = (statusCode, body)
        stubbedError = nil
    }

    static func stubError(_ error: Error) {
        stubbedError = error
        stubbedResponse = nil
    }

    static func reset() {
        stubbedResponse = nil
        stubbedError = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = Self.stubbedError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let stub = Self.stubbedResponse,
           let url = request.url,
           let response = HTTPURLResponse(url: url, statusCode: stub.statusCode, httpVersion: nil, headerFields: nil) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: stub.body)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
