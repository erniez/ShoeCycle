//  FeatureFlagsStoreTests.swift
//  ShoeCycleTests
//
//  Tests for FeatureFlagsStore: start()'s re-entrancy guard, stop()'s cancellation, and that
//  isEnabled reflects the loaded state. Flagged by code review as untested (ShoeCycle-Web-54b) —
//  a "hardening" PR shipping a new app-level store with zero coverage of its own lifecycle is
//  exactly the kind of gap this branch exists to close.
//

import XCTest
import SwiftUI
@testable import ShoeCycle

@MainActor
final class FeatureFlagsStoreTests: XCTestCase {

    private func makeTestDefaults() -> UserDefaults {
        UserDefaults(suiteName: "com.shoecycle.tests.featureFlagsStore.\(UUID().uuidString)")!
    }

    private func makeStore(network: CountingStubRESTService, refreshInterval: TimeInterval) -> FeatureFlagsStore {
        let service = FeatureFlagService(network: network, userDefaults: makeTestDefaults())
        let interactor = FeatureFlagsInteractor(
            service: service,
            identityProvider: FeatureFlagIdentityProvider(userDefaults: makeTestDefaults())
        )
        return FeatureFlagsStore(interactor: interactor, refreshInterval: refreshInterval)
    }

    // Given: A store that has never been started
    // When: start() is called twice in a row (e.g. onAppear firing more than once per session)
    // Then: Only ONE initial fetch happens — the second call is a no-op via the re-entrancy guard
    func testStartTwiceDoesNotDuplicateInitialDispatch() async throws {
        let network = CountingStubRESTService()
        network.stub(data: Self.demoBadgeOnPayload)
        let store = makeStore(network: network, refreshInterval: 3600)

        store.start()
        store.start()

        // Let the first dispatch's Task actually run before asserting.
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(network.fetchCount, 1, "start() called twice must not duplicate the initial fetch")
        store.stop()
    }

    // Given: A running store on a very short refresh interval
    // When: stop() is called
    // Then: No further scheduled refresh fires, even after waiting past the interval — the sleep
    //       loop exits on cancellation rather than blocking until the full duration elapses
    func testStopCancelsTheRefreshLoopPromptly() async throws {
        let network = CountingStubRESTService()
        network.stub(data: Self.demoBadgeOnPayload)
        let store = makeStore(network: network, refreshInterval: 0.05)

        store.start()
        try await Task.sleep(for: .milliseconds(50)) // let the initial dispatch complete
        XCTAssertEqual(network.fetchCount, 1)

        store.stop()
        // Long enough for at least one more scheduled refresh (0.05s interval) if stop() failed
        // to cancel the loop.
        try await Task.sleep(for: .milliseconds(250))

        XCTAssertEqual(network.fetchCount, 1, "stop() must prevent any further scheduled refresh")
    }

    // Given: A store loaded against a payload with the demo badge flag ON
    // When: isEnabled is read after start() completes its initial load
    // Then: It reflects the resolved value — the store's public read API works end-to-end
    func testIsEnabledReflectsLoadedState() async throws {
        let network = CountingStubRESTService()
        network.stub(data: Self.demoBadgeOnPayload)
        let store = makeStore(network: network, refreshInterval: 3600)

        store.start()
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertTrue(store.isEnabled(FeatureFlagKey.settingsDemoBadge))
        store.stop()
    }

    private static let demoBadgeOnPayload = """
    { "flags": [
        { "key": "ios-settings-demo-badge", "enabled": true, "rolloutPercentage": 100 }
    ] }
    """.data(using: .utf8)!
}

// MARK: - Test helpers

/// `RESTService` stub that counts how many times a fetch was attempted, so re-entrancy /
/// cancellation tests can assert on call counts instead of just final state.
@MainActor
private final class CountingStubRESTService: RESTService {
    enum DomainError: Error {
        case unknown
    }

    private(set) var fetchCount = 0
    private var stubbedData: Data?

    func stub(data: Data) {
        stubbedData = data
    }

    func getJSONData<T: Decodable>(url: URL) async throws -> T {
        fetchCount += 1
        guard let data = stubbedData else { throw DomainError.unknown }
        return try data.jsonDecode()
    }

    func getData(url: URL) async throws -> Data {
        fetchCount += 1
        return stubbedData ?? Data()
    }

    func postJSON(dto: Encodable, url: URL, authToken: String?) async throws -> Data {
        Data()
    }

    func post(request: URLRequest, data: Data) async throws -> Data {
        Data()
    }
}
